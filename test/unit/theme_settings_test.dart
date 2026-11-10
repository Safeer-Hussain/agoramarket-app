import 'package:agora_market_app/core/constants/app_constants.dart';
import 'package:agora_market_app/core/theme/theme_provider.dart';
import 'package:agora_market_app/presentation/profile/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Theme and Preferences Unit Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test(
      'ThemeProvider toggles mode and persists to SharedPreferences',
      () async {
        final themeProvider = ThemeProvider(prefs: prefs);
        expect(themeProvider.themeMode, ThemeMode.dark);

        await themeProvider.toggleTheme();
        expect(themeProvider.themeMode, ThemeMode.light);
        expect(prefs.getString(AppConstants.prefThemeMode), 'light');

        await themeProvider.toggleTheme();
        expect(themeProvider.themeMode, ThemeMode.dark);
        expect(prefs.getString(AppConstants.prefThemeMode), 'dark');
      },
    );

    test('ProfileProvider toggles currency USD/PKR and persists', () async {
      final mockProfileRepo = MockProfileRepository();
      final mockMarketplaceRepo = MockMarketplaceRepository();
      final profileProvider = ProfileProvider(
        profileRepository: mockProfileRepo,
        marketplaceRepository: mockMarketplaceRepo,
        prefs: prefs,
      );

      expect(profileProvider.selectedCurrency, 'USD');

      await profileProvider.toggleCurrency();
      expect(profileProvider.selectedCurrency, 'PKR');
      expect(prefs.getString(AppConstants.prefCurrency), 'PKR');

      await profileProvider.toggleCurrency();
      expect(profileProvider.selectedCurrency, 'USD');
    });

    test('ProfileProvider toggles distance unit km/mi and persists', () async {
      final mockProfileRepo = MockProfileRepository();
      final mockMarketplaceRepo = MockMarketplaceRepository();
      final profileProvider = ProfileProvider(
        profileRepository: mockProfileRepo,
        marketplaceRepository: mockMarketplaceRepo,
        prefs: prefs,
      );

      expect(profileProvider.distanceUnit, 'km');

      await profileProvider.toggleDistanceUnit();
      expect(profileProvider.distanceUnit, 'mi');
      expect(prefs.getString(AppConstants.prefDistanceUnit), 'mi');
    });

    test('ProfileProvider toggles availability and updates state', () async {
      final mockProfileRepo = MockProfileRepository();
      final mockMarketplaceRepo = MockMarketplaceRepository();
      final profileProvider = ProfileProvider(
        profileRepository: mockProfileRepo,
        marketplaceRepository: mockMarketplaceRepo,
        prefs: prefs,
      );

      await profileProvider.loadProfileData();
      expect(profileProvider.profile?.isAvailable, true);

      await profileProvider.toggleAvailability(false);
      expect(profileProvider.profile?.isAvailable, false);
      expect(prefs.getBool(AppConstants.prefAvailability), false);
    });
  });
}
