import 'package:latlong2/latlong.dart';

import '../../core/database/app_database.dart';
import '../../domain/entities/video_pitch.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/marketplace_repository.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final AppDatabase _database;
  final Distance _distance = const Distance();

  MarketplaceRepositoryImpl({AppDatabase? database})
    : _database = database ?? AppDatabase();

  @override
  Future<List<VideoPitch>> getVideoPitches() async {
    final db = await _database.database;
    final rows = await db.query('video_pitches', orderBy: 'created_at DESC');
    return rows.map((r) => VideoPitch.fromMap(r)).toList();
  }

  @override
  Future<void> toggleLike(String pitchId) async {
    final db = await _database.database;
    final rows = await db.query(
      'video_pitches',
      where: 'id = ?',
      whereArgs: [pitchId],
      limit: 1,
    );
    if (rows.isEmpty) return;

    final current = VideoPitch.fromMap(rows.first);
    final newIsLiked = !current.isLiked;
    final newCount = newIsLiked
        ? current.likesCount + 1
        : current.likesCount - 1;

    await db.update(
      'video_pitches',
      {
        'is_liked': newIsLiked ? 1 : 0,
        'likes_count': newCount < 0 ? 0 : newCount,
      },
      where: 'id = ?',
      whereArgs: [pitchId],
    );
  }

  @override
  Future<void> toggleBookmark(String pitchId) async {
    final db = await _database.database;
    final rows = await db.query(
      'video_pitches',
      where: 'id = ?',
      whereArgs: [pitchId],
      limit: 1,
    );
    if (rows.isEmpty) return;

    final current = VideoPitch.fromMap(rows.first);
    final newIsBookmarked = !current.isBookmarked;
    final newCount = newIsBookmarked
        ? current.bookmarksCount + 1
        : current.bookmarksCount - 1;

    await db.update(
      'video_pitches',
      {
        'is_bookmarked': newIsBookmarked ? 1 : 0,
        'bookmarks_count': newCount < 0 ? 0 : newCount,
      },
      where: 'id = ?',
      whereArgs: [pitchId],
    );
  }

  @override
  Future<void> addVideoPitch(VideoPitch pitch) async {
    final db = await _database.database;
    await db.insert('video_pitches', pitch.toMap());
  }

  @override
  Future<List<Comment>> getComments(String pitchId) async {
    final db = await _database.database;
    final rows = await db.query(
      'comments',
      where: 'pitch_id = ?',
      whereArgs: [pitchId],
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => Comment.fromMap(r)).toList();
  }

  @override
  Future<void> addComment(Comment comment) async {
    final db = await _database.database;
    await db.insert('comments', comment.toMap());
  }

  @override
  Future<List<VideoPitch>> searchPitches({
    String? query,
    String? category,
    double? maxRadiusKm,
    double? userLat,
    double? userLng,
    double? maxHourlyRate,
  }) async {
    final allPitches = await getVideoPitches();
    return allPitches.where((pitch) {
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        final match =
            pitch.title.toLowerCase().contains(q) ||
            pitch.creatorName.toLowerCase().contains(q) ||
            pitch.role.toLowerCase().contains(q) ||
            pitch.skills.any((s) => s.toLowerCase().contains(q)) ||
            pitch.locationName.toLowerCase().contains(q);
        if (!match) return false;
      }

      if (category != null && category.isNotEmpty && category != 'All') {
        if (pitch.category.toLowerCase() != category.toLowerCase()) {
          return false;
        }
      }

      if (maxHourlyRate != null && maxHourlyRate > 0) {
        if (pitch.hourlyRate > maxHourlyRate) {
          return false;
        }
      }

      if (maxRadiusKm != null && userLat != null && userLng != null) {
        final dist = _distance.as(
          LengthUnit.Kilometer,
          LatLng(userLat, userLng),
          LatLng(pitch.latitude, pitch.longitude),
        );
        if (dist > maxRadiusKm) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
