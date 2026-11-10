import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/video_pitch.dart';
import '../../domain/repositories/marketplace_repository.dart';

class MapFilterProvider extends ChangeNotifier {
  final MarketplaceRepository repository;
  final Distance _distance = const Distance();

  List<VideoPitch> _allPitches = [];
  List<VideoPitch> _filteredPitches = [];
  VideoPitch? _selectedPitch;
  bool _isLoading = false;

  // Filters
  String _searchQuery = '';
  String _selectedCategory = 'All';
  double _radiusKm = 25.0;
  double _maxHourlyRate = 150.0;

  // Location center
  double _userLat = AppConstants.defaultLat;
  double _userLng = AppConstants.defaultLng;
  bool _showRoute = false;
  bool _disposed = false;

  MapFilterProvider({required this.repository}) {
    loadMapData();
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

  List<VideoPitch> get filteredPitches => _filteredPitches;
  VideoPitch? get selectedPitch => _selectedPitch;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  double get radiusKm => _radiusKm;
  double get maxHourlyRate => _maxHourlyRate;
  double get userLat => _userLat;
  double get userLng => _userLng;
  bool get showRoute => _showRoute;
  LatLng get userLatLng => LatLng(_userLat, _userLng);

  Future<void> loadMapData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allPitches = await repository.getVideoPitches();
      _applyFilters();
      if (_filteredPitches.isNotEmpty && _selectedPitch == null) {
        _selectedPitch = _filteredPitches.first;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setRadiusKm(double km) {
    _radiusKm = km;
    _applyFilters();
    notifyListeners();
  }

  void setMaxHourlyRate(double rate) {
    _maxHourlyRate = rate;
    _applyFilters();
    notifyListeners();
  }

  void selectPitch(VideoPitch pitch) {
    _selectedPitch = pitch;
    _showRoute = false;
    notifyListeners();
  }

  void toggleRoute() {
    _showRoute = !_showRoute;
    notifyListeners();
  }

  void recenterToTechHub({double? lat, double? lng}) {
    _userLat = lat ?? AppConstants.defaultLat;
    _userLng = lng ?? AppConstants.defaultLng;
    _showRoute = false;
    _applyFilters();
    notifyListeners();
  }

  double calculateDistanceTo(VideoPitch pitch) {
    return _distance.as(
      LengthUnit.Kilometer,
      LatLng(_userLat, _userLng),
      LatLng(pitch.latitude, pitch.longitude),
    );
  }

  String getTravelEstimate(VideoPitch pitch) {
    final distKm = calculateDistanceTo(pitch);
    final minutes = ((distKm / 25.0) * 60).round().clamp(2, 180);
    return '$minutes min drive • ${distKm.toStringAsFixed(1)} km';
  }

  void _applyFilters() {
    _filteredPitches = _allPitches.where((pitch) {
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match =
            pitch.title.toLowerCase().contains(q) ||
            pitch.creatorName.toLowerCase().contains(q) ||
            pitch.role.toLowerCase().contains(q) ||
            pitch.locationName.toLowerCase().contains(q) ||
            pitch.skills.any((s) => s.toLowerCase().contains(q));
        if (!match) return false;
      }

      if (_selectedCategory != 'All' &&
          pitch.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      if (pitch.hourlyRate > _maxHourlyRate) {
        return false;
      }

      final dist = calculateDistanceTo(pitch);
      if (dist > _radiusKm) {
        return false;
      }

      return true;
    }).toList();

    if (_selectedPitch != null && !_filteredPitches.contains(_selectedPitch)) {
      _selectedPitch = _filteredPitches.isNotEmpty
          ? _filteredPitches.first
          : null;
    }
  }
}
