import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/database/app_database.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AppDatabase _database;
  final SharedPreferences? prefs;

  ProfileRepositoryImpl({AppDatabase? database, this.prefs})
    : _database = database ?? AppDatabase();

  @override
  Future<UserProfile> getUserProfile() async {
    final db = await _database.database;
    final rows = await db.query('user_profile', limit: 1);
    if (rows.isEmpty) {
      throw Exception('User profile not found in local database');
    }

    final profile = UserProfile.fromMap(rows.first);
    final isAvailablePref = prefs?.getBool(AppConstants.prefAvailability);
    if (isAvailablePref != null) {
      return profile.copyWith(isAvailable: isAvailablePref);
    }
    return profile;
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    final db = await _database.database;
    await db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  @override
  Future<void> toggleAvailability(bool isAvailable) async {
    final db = await _database.database;
    await db.update('user_profile', {'is_available': isAvailable ? 1 : 0});
    final localPrefs = prefs;
    if (localPrefs != null) {
      await localPrefs.setBool(AppConstants.prefAvailability, isAvailable);
    }
  }

  @override
  Future<List<PortfolioItem>> getPortfolioItems() async {
    final db = await _database.database;
    final rows = await db.query('portfolio_items');
    return rows.map((r) => PortfolioItem.fromMap(r)).toList();
  }

  @override
  Future<void> addPortfolioItem(PortfolioItem item) async {
    final db = await _database.database;
    await db.insert('portfolio_items', item.toMap());
  }
}
