import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../database/app_database.dart';

class MockApiInterceptor extends Interceptor {
  final SharedPreferences? prefs;
  final AppDatabase _database;
  final Random _random = Random();

  MockApiInterceptor({this.prefs, AppDatabase? database})
    : _database = database ?? AppDatabase();

  int get _latencyMs {
    final custom = prefs?.getInt(AppConstants.prefSimulatedLatency);
    if (custom != null && custom > 0) return custom;
    return 400 + _random.nextInt(500);
  }

  bool get _force503 {
    return prefs?.getBool(AppConstants.prefForce503) ?? false;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final latency = _latencyMs;
    await Future.delayed(Duration(milliseconds: latency));

    if (_force503 && !options.path.contains('/health')) {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 503,
            statusMessage: 'Service Temporarily Unavailable (Simulated 503)',
            data: {
              'error': 'Service Unavailable',
              'message': 'Simulated Recruiter Debug Fault Injected',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );
    }

    try {
      final db = await _database.database;
      final path = options.path;

      if (path.contains('/api/pitches')) {
        final rows = await db.query(
          'video_pitches',
          orderBy: 'created_at DESC',
        );
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'data': rows, 'total': rows.length},
          ),
        );
      }

      if (path.contains('/api/conversations')) {
        final rows = await db.query('chat_conversations');
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'data': rows},
          ),
        );
      }

      if (path.contains('/api/profile')) {
        final profileRows = await db.query('user_profile', limit: 1);
        final portfolioRows = await db.query('portfolio_items');
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'success': true,
              'profile': profileRows.isNotEmpty ? profileRows.first : {},
              'portfolio': portfolioRows,
            },
          ),
        );
      }

      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true, 'message': 'Mock endpoint resolved'},
        ),
      );
    } catch (e) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }
}
