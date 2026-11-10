import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import '../network/mock_api_interceptor.dart';
import '../performance/render_latency_monitor.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/marketplace_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';

final sl = GetIt.instance;

Future<void> initDependencies({SharedPreferences? mockPrefs}) async {
  // SharedPreferences
  final prefs = mockPrefs ?? await SharedPreferences.getInstance();
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerSingleton<SharedPreferences>(prefs);
  }

  // Database
  if (!sl.isRegistered<AppDatabase>()) {
    sl.registerSingleton<AppDatabase>(AppDatabase());
  }

  // Performance Monitor
  if (!sl.isRegistered<RenderLatencyMonitor>()) {
    sl.registerSingleton<RenderLatencyMonitor>(RenderLatencyMonitor());
  }

  // Network / Dio
  if (!sl.isRegistered<Dio>()) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.agoramarket.local',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(MockApiInterceptor(prefs: sl(), database: sl()));
    sl.registerSingleton<Dio>(dio);
  }

  // Repositories
  if (!sl.isRegistered<MarketplaceRepository>()) {
    sl.registerLazySingleton<MarketplaceRepository>(
      () => MarketplaceRepositoryImpl(database: sl()),
    );
  }

  if (!sl.isRegistered<ChatRepository>()) {
    sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(database: sl()),
    );
  }

  if (!sl.isRegistered<ProfileRepository>()) {
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(database: sl(), prefs: sl()),
    );
  }
}
