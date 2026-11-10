import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/video_pitch.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/marketplace_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository profileRepository;
  final MarketplaceRepository marketplaceRepository;
  final SharedPreferences? prefs;
  final Uuid _uuid = const Uuid();

  UserProfile? _profile;
  List<PortfolioItem> _portfolioItems = [];
  List<VideoPitch> _myPitches = [];
  bool _isLoading = false;

  // Settings
  String _selectedCurrency = AppConstants.defaultCurrency;
  String _distanceUnit = 'km';
  bool _disposed = false;

  ProfileProvider({
    required this.profileRepository,
    required this.marketplaceRepository,
    this.prefs,
  }) {
    _loadSettings();
    loadProfileData();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  UserProfile? get profile => _profile;
  List<PortfolioItem> get portfolioItems => _portfolioItems;
  List<VideoPitch> get myPitches => _myPitches;
  bool get isLoading => _isLoading;
  String get selectedCurrency => _selectedCurrency;
  String get distanceUnit => _distanceUnit;

  void _loadSettings() {
    final localPrefs = prefs;
    if (localPrefs == null) return;
    _selectedCurrency =
        localPrefs.getString(AppConstants.prefCurrency) ??
        AppConstants.defaultCurrency;
    _distanceUnit = localPrefs.getString(AppConstants.prefDistanceUnit) ?? 'km';
  }

  Future<void> toggleCurrency() async {
    _selectedCurrency = (_selectedCurrency == AppConstants.defaultCurrency)
        ? AppConstants.altCurrency
        : AppConstants.defaultCurrency;
    notifyListeners();
    final localPrefs = prefs;
    if (localPrefs != null) {
      await localPrefs.setString(AppConstants.prefCurrency, _selectedCurrency);
    }
  }

  Future<void> toggleDistanceUnit() async {
    _distanceUnit = (_distanceUnit == 'km') ? 'mi' : 'km';
    notifyListeners();
    final localPrefs = prefs;
    if (localPrefs != null) {
      await localPrefs.setString(AppConstants.prefDistanceUnit, _distanceUnit);
    }
  }

  Future<void> loadProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await profileRepository.getUserProfile();
      _portfolioItems = await profileRepository.getPortfolioItems();
      final allPitches = await marketplaceRepository.getVideoPitches();
      _myPitches = allPitches
          .where((p) => p.creatorName == 'Safeer Hussain')
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleAvailability(bool isAvailable) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(isAvailable: isAvailable);
    notifyListeners();

    final localPrefs = prefs;
    if (localPrefs != null) {
      await localPrefs.setBool(AppConstants.prefAvailability, isAvailable);
    }

    await profileRepository.toggleAvailability(isAvailable);
  }

  Future<void> updateProfile({
    required String name,
    required String headline,
    required String bio,
    required double hourlyRate,
    required String location,
    required List<String> skills,
  }) async {
    if (_profile == null) return;

    final updated = _profile!.copyWith(
      name: name,
      headline: headline,
      bio: bio,
      hourlyRate: hourlyRate,
      location: location,
      skills: skills,
    );

    _profile = updated;
    notifyListeners();

    await profileRepository.updateUserProfile(updated);
  }

  Future<void> addPortfolioItem({
    required String title,
    required String description,
    required String category,
    required String metric,
  }) async {
    final newItem = PortfolioItem(
      id: 'port_${_uuid.v4()}',
      title: title,
      description: description,
      category: category,
      metric: metric,
      thumbnailAsset: 'assets/images/thumb_mobile_arch.png',
    );

    _portfolioItems.insert(0, newItem);
    notifyListeners();

    await profileRepository.addPortfolioItem(newItem);
  }
}
