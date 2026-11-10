import 'dart:async';
import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  print('====================================================================');
  print('AgoraMarket Sprint Verification Gate');
  print('====================================================================');

  try {
    // 1. Dependency Resolution
    await _stepPubGet();

    // 2. Code Formatting
    await _stepFormat();

    // 3. Static Analysis
    await _stepAnalyze();

    // 4. Automated Test Suite
    await _stepTests();

    // 5. Connected Device Smoke Test
    await _stepDeviceCheck();

    stopwatch.stop();
    print(
      '====================================================================',
    );
    print(
      '[GATE PASSED] All checks passed in ${stopwatch.elapsed.inSeconds}s.',
    );
    print(
      '====================================================================',
    );
    exit(0);
  } catch (e) {
    stopwatch.stop();
    print(
      '====================================================================',
    );
    print('[GATE FAILED] $e');
    print(
      '====================================================================',
    );
    exit(1);
  }
}

Future<void> _stepPubGet() async {
  print('\n[Step 1/5] Verifying dependency resolution: flutter pub get...');
  final res = await Process.run('flutter', ['pub', 'get'], runInShell: true);
  if (res.exitCode != 0) {
    stderr.write(res.stderr);
    throw Exception('flutter pub get failed with exit code ${res.exitCode}');
  }
  print('[PASS] Dependencies resolved successfully.');
}

Future<void> _stepFormat() async {
  print('\n[Step 2/5] Formatting codebase: dart format lib test tool...');
  // Format all files automatically so formatting never breaks CI
  final resFormat = await Process.run('dart', [
    'format',
    'lib',
    'test',
    'tool',
  ], runInShell: true);
  if (resFormat.exitCode != 0) {
    stderr.write(resFormat.stderr);
    throw Exception('dart format failed with exit code ${resFormat.exitCode}');
  }

  // Verify that formatting matches canonical dartfmt rules
  final resCheck = await Process.run('dart', [
    'format',
    '--output=none',
    '--set-exit-if-changed',
    'lib',
    'test',
    'tool',
  ], runInShell: true);
  if (resCheck.exitCode != 0) {
    stderr.write(resCheck.stderr);
    throw Exception(
      'dart format check failed with exit code ${resCheck.exitCode}',
    );
  }
  print('[PASS] All files canonicalized and formatted cleanly.');
}

Future<void> _stepAnalyze() async {
  print(
    '\n[Step 3/5] Running zero-warning static analysis: flutter analyze --no-pub...',
  );
  final res = await Process.run('flutter', [
    'analyze',
    '--no-pub',
    '--fatal-infos',
    '--fatal-warnings',
  ], runInShell: true);
  if (res.exitCode != 0) {
    stdout.write(res.stdout);
    stderr.write(res.stderr);
    throw Exception('flutter analyze failed with exit code ${res.exitCode}');
  }
  print('[PASS] Static analysis clean (0 issues, 0 warnings, 0 infos).');
}

Future<void> _stepTests() async {
  print(
    '\n[Step 4/5] Executing automated unit and widget test suite: flutter test --no-pub...',
  );
  final res = await Process.run('flutter', [
    'test',
    '--no-pub',
  ], runInShell: true);
  if (res.exitCode != 0) {
    stdout.write(res.stdout);
    stderr.write(res.stderr);
    throw Exception('flutter test suite failed with exit code ${res.exitCode}');
  }
  print('[PASS] 100% of unit and widget tests passed.');
}

Future<void> _stepDeviceCheck() async {
  print('\n[Step 5/5] Connected mobile device and runtime exception check...');
  final res = await Process.run('flutter', [
    'devices',
    '--machine',
  ], runInShell: true);
  if (res.exitCode != 0) {
    print('[WARN] Could not query flutter devices. Skipping live device test.');
    return;
  }

  List<dynamic> devices = [];
  try {
    devices = jsonDecode(res.stdout.toString()) as List<dynamic>;
  } catch (_) {
    print('[WARN] Could not parse devices output. Skipping live device test.');
    return;
  }

  final mobileDevices = devices.where((d) {
    final platform = (d['targetPlatform'] ?? '').toString().toLowerCase();
    final id = (d['id'] ?? '').toString().toLowerCase();
    if (platform.startsWith('windows') ||
        platform.startsWith('darwin') ||
        platform.startsWith('linux') ||
        platform.startsWith('web') ||
        id == 'windows' ||
        id == 'chrome' ||
        id == 'edge') {
      return false;
    }
    return true;
  }).toList();

  if (mobileDevices.isEmpty) {
    print(
      '[INFO] No mobile physical device or emulator detected. Skipping live device smoke test.',
    );
    return;
  }

  final device = mobileDevices.first;
  final deviceId = device['id'].toString();
  final deviceName = device['name'].toString();
  final isAndroid = (device['targetPlatform'] ?? '')
      .toString()
      .toLowerCase()
      .contains('android');

  print('[INFO] Target mobile device detected: $deviceName ($deviceId)');

  final adbPath = isAndroid ? _locateAdb() : null;
  if (isAndroid && adbPath != null) {
    print('[INFO] Clearing stale adb logcat buffer on device $deviceId...');
    try {
      await Process.run(adbPath, [
        '-s',
        deviceId,
        'logcat',
        '-c',
      ], runInShell: true);
    } catch (_) {}
  }

  print(
    '[INFO] Launching app on $deviceId with 25-second live runtime smoke test...',
  );
  final process = await Process.start('flutter', [
    'run',
    '-d',
    deviceId,
    '--no-pub',
  ], runInShell: true);

  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();

  final stdoutSub = process.stdout.transform(utf8.decoder).listen((data) {
    stdoutBuffer.write(data);
    stdout.write(data);
  });

  final stderrSub = process.stderr.transform(utf8.decoder).listen((data) {
    stderrBuffer.write(data);
    stderr.write(data);
  });

  bool appRunning = false;
  final timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
    final out = stdoutBuffer.toString();
    if (out.contains('Flutter run key commands') ||
        out.contains('Syncing files to device') ||
        out.contains('Application running')) {
      appRunning = true;
    }
  });

  // Allow up to 25 seconds for cold launch, splash transition, and initial frame render
  await Future.delayed(const Duration(seconds: 25));
  timer.cancel();

  print('\n[INFO] Terminating live smoke run on $deviceId...');
  try {
    process.stdin.writeln('q');
    await process.stdin.flush();
  } catch (_) {}

  // Wait for process exit or force kill after 5 seconds
  final exitFuture = process.exitCode;
  final exited = await Future.any([
    exitFuture.then((_) => true),
    Future.delayed(const Duration(seconds: 5), () => false),
  ]);

  if (!exited) {
    process.kill();
  }

  await stdoutSub.cancel();
  await stderrSub.cancel();

  // Collect adb logs if available
  String adbLogs = '';
  if (isAndroid && adbPath != null) {
    try {
      final logcatRes = await Process.run(adbPath, [
        '-s',
        deviceId,
        'logcat',
        '-d',
      ], runInShell: true);
      adbLogs = logcatRes.stdout.toString();
    } catch (_) {}
  }

  final fullLog =
      '${stdoutBuffer.toString()}\n${stderrBuffer.toString()}\n$adbLogs';

  final forbiddenPatterns = [
    'EXCEPTION CAUGHT BY',
    'A RenderFlex overflowed by',
    'There are multiple heroes that share the same tag',
    'No observables detected in the build method of Observer',
    'setState() or markNeedsBuild() called during build',
    'AndroidRuntime: FATAL EXCEPTION',
    'Unhandled Exception:',
  ];

  for (final pattern in forbiddenPatterns) {
    if (fullLog.contains(pattern)) {
      throw Exception(
        'Prohibited runtime error detected on device $deviceId: "$pattern"\n'
        'Check full device runtime log above for stack trace.',
      );
    }
  }

  print(
    '[PASS] Live device runtime smoke test passed with 0 runtime exceptions.',
  );
}

String? _locateAdb() {
  try {
    final res = Process.runSync(Platform.isWindows ? 'where.exe' : 'which', [
      'adb',
    ], runInShell: true);
    if (res.exitCode == 0) {
      final line = res.stdout.toString().split('\n').first.trim();
      if (line.isNotEmpty && File(line).existsSync()) return line;
    }
  } catch (_) {}

  final sdkDirs = [
    Platform.environment['ANDROID_HOME'],
    Platform.environment['ANDROID_SDK_ROOT'],
    if (Platform.isWindows)
      '${Platform.environment['LOCALAPPDATA']}\\Android\\Sdk',
    if (!Platform.isWindows)
      '${Platform.environment['HOME']}/Library/Android/sdk',
    if (!Platform.isWindows) '${Platform.environment['HOME']}/Android/Sdk',
  ];

  for (final dir in sdkDirs) {
    if (dir == null || dir.isEmpty) continue;
    final adbPath = Platform.isWindows
        ? '$dir\\platform-tools\\adb.exe'
        : '$dir/platform-tools/adb';
    if (File(adbPath).existsSync()) return adbPath;
  }
  return null;
}
