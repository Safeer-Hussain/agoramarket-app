class UserProfile {
  final String id;
  final String name;
  final String headline;
  final String bio;
  final double hourlyRate;
  final String currency;
  final String location;
  final bool isAvailable;
  final double rating;
  final int reviewsCount;
  final List<String> skills;
  final int completedContracts;
  final String avatarAsset;

  const UserProfile({
    required this.id,
    required this.name,
    required this.headline,
    required this.bio,
    required this.hourlyRate,
    required this.currency,
    required this.location,
    required this.isAvailable,
    required this.rating,
    required this.reviewsCount,
    required this.skills,
    required this.completedContracts,
    required this.avatarAsset,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? headline,
    String? bio,
    double? hourlyRate,
    String? currency,
    String? location,
    bool? isAvailable,
    double? rating,
    int? reviewsCount,
    List<String>? skills,
    int? completedContracts,
    String? avatarAsset,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      currency: currency ?? this.currency,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      skills: skills ?? this.skills,
      completedContracts: completedContracts ?? this.completedContracts,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'headline': headline,
      'bio': bio,
      'hourly_rate': hourlyRate,
      'currency': currency,
      'location': location,
      'is_available': isAvailable ? 1 : 0,
      'rating': rating,
      'reviews_count': reviewsCount,
      'skills': skills.join(','),
      'completed_contracts': completedContracts,
      'avatar_asset': avatarAsset,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      headline: map['headline'] as String,
      bio: map['bio'] as String,
      hourlyRate: (map['hourly_rate'] as num).toDouble(),
      currency: map['currency'] as String,
      location: map['location'] as String,
      isAvailable: (map['is_available'] as int) == 1,
      rating: (map['rating'] as num).toDouble(),
      reviewsCount: map['reviews_count'] as int,
      skills: (map['skills'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .toList(),
      completedContracts: map['completed_contracts'] as int,
      avatarAsset: map['avatar_asset'] as String,
    );
  }
}

class PortfolioItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String metric;
  final String thumbnailAsset;

  const PortfolioItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.metric,
    required this.thumbnailAsset,
  });

  PortfolioItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? metric,
    String? thumbnailAsset,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      metric: metric ?? this.metric,
      thumbnailAsset: thumbnailAsset ?? this.thumbnailAsset,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'metric': metric,
      'thumbnail_asset': thumbnailAsset,
    };
  }

  factory PortfolioItem.fromMap(Map<String, dynamic> map) {
    return PortfolioItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      metric: map['metric'] as String,
      thumbnailAsset: map['thumbnail_asset'] as String,
    );
  }
}
