class VideoPitch {
  final String id;
  final String title;
  final String creatorName;
  final String creatorAvatar;
  final String role;
  final double hourlyRate;
  final String currency;
  final String locationName;
  final double latitude;
  final double longitude;
  final String category; // 'Freelancer', 'Job', 'Agency'
  final String videoAsset;
  final String thumbnailAsset;
  final int likesCount;
  final int bookmarksCount;
  final bool isLiked;
  final bool isBookmarked;
  final String pitchScript;
  final List<String> skills;
  final String createdAt;

  const VideoPitch({
    required this.id,
    required this.title,
    required this.creatorName,
    required this.creatorAvatar,
    required this.role,
    required this.hourlyRate,
    required this.currency,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.videoAsset,
    required this.thumbnailAsset,
    required this.likesCount,
    required this.bookmarksCount,
    required this.isLiked,
    required this.isBookmarked,
    required this.pitchScript,
    required this.skills,
    required this.createdAt,
  });

  VideoPitch copyWith({
    String? id,
    String? title,
    String? creatorName,
    String? creatorAvatar,
    String? role,
    double? hourlyRate,
    String? currency,
    String? locationName,
    double? latitude,
    double? longitude,
    String? category,
    String? videoAsset,
    String? thumbnailAsset,
    int? likesCount,
    int? bookmarksCount,
    bool? isLiked,
    bool? isBookmarked,
    String? pitchScript,
    List<String>? skills,
    String? createdAt,
  }) {
    return VideoPitch(
      id: id ?? this.id,
      title: title ?? this.title,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatar: creatorAvatar ?? this.creatorAvatar,
      role: role ?? this.role,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      currency: currency ?? this.currency,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      videoAsset: videoAsset ?? this.videoAsset,
      thumbnailAsset: thumbnailAsset ?? this.thumbnailAsset,
      likesCount: likesCount ?? this.likesCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      pitchScript: pitchScript ?? this.pitchScript,
      skills: skills ?? this.skills,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'creator_name': creatorName,
      'creator_avatar': creatorAvatar,
      'role': role,
      'hourly_rate': hourlyRate,
      'currency': currency,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'video_asset': videoAsset,
      'thumbnail_asset': thumbnailAsset,
      'likes_count': likesCount,
      'bookmarks_count': bookmarksCount,
      'is_liked': isLiked ? 1 : 0,
      'is_bookmarked': isBookmarked ? 1 : 0,
      'pitch_script': pitchScript,
      'skills': skills.join(','),
      'created_at': createdAt,
    };
  }

  factory VideoPitch.fromMap(Map<String, dynamic> map) {
    return VideoPitch(
      id: map['id'] as String,
      title: map['title'] as String,
      creatorName: map['creator_name'] as String,
      creatorAvatar: map['creator_avatar'] as String,
      role: map['role'] as String,
      hourlyRate: (map['hourly_rate'] as num).toDouble(),
      currency: map['currency'] as String,
      locationName: map['location_name'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      category: map['category'] as String,
      videoAsset: map['video_asset'] as String,
      thumbnailAsset: map['thumbnail_asset'] as String,
      likesCount: map['likes_count'] as int,
      bookmarksCount: map['bookmarks_count'] as int,
      isLiked: (map['is_liked'] as int) == 1,
      isBookmarked: (map['is_bookmarked'] as int) == 1,
      pitchScript: map['pitch_script'] as String,
      skills: (map['skills'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .toList(),
      createdAt: map['created_at'] as String,
    );
  }
}
