import 'package:agora_market_app/core/constants/app_constants.dart';
import 'package:agora_market_app/core/utils/currency_converter.dart';
import 'package:agora_market_app/presentation/profile/profile_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CurrencyConverter Unit Tests', () {
    test('Calculates exact conversion rates for all supported currencies', () {
      const baseUsd = 100.0;

      expect(CurrencyConverter.convert(baseUsd, 'USD'), 100.0);
      expect(CurrencyConverter.convert(baseUsd, 'PKR'), 27850.0);
      expect(CurrencyConverter.convert(baseUsd, 'EUR'), 92.0);
      expect(CurrencyConverter.convert(baseUsd, 'GBP'), 79.0);
      expect(CurrencyConverter.convert(baseUsd, 'AED'), 367.0);
      expect(CurrencyConverter.convert(baseUsd, 'SAR'), 375.0);
    });

    test(
      'Formats currency strings with accurate symbols and decimal precision',
      () {
        expect(CurrencyConverter.format(100.0, 'USD'), '\$100.00');
        expect(CurrencyConverter.format(100.0, 'PKR'), 'Rs 27850');
        expect(CurrencyConverter.format(100.0, 'EUR'), '€92.00');
        expect(CurrencyConverter.format(100.0, 'GBP'), '£79.00');
        expect(CurrencyConverter.format(100.0, 'AED'), 'AED 367.0');
        expect(CurrencyConverter.format(100.0, 'SAR'), 'SAR 375.0');
      },
    );

    test('Computes forward hedging risk and downside floor mitigation', () {
      final hedging = CurrencyConverter.calculateHedging(
        baseAmountUsd: 1000.0,
        targetCurrency: 'PKR',
        durationDays: 30,
        hedgeRatioPercent: 80.0,
      );

      expect(hedging.targetCurrency, 'PKR');
      expect(hedging.standardValue, 278500.0);
      expect(hedging.worstCaseValue, lessThan(hedging.standardValue));
      expect(hedging.protectedValue, greaterThan(hedging.worstCaseValue));
      expect(hedging.riskMitigated, greaterThan(0));
      expect(hedging.projectedVolatilityPercent, greaterThan(0));
    });

    test(
      'ProfileProvider sets currency and persists to SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final provider = ProfileProvider(
          profileRepository: MockProfileRepository(),
          marketplaceRepository: MockMarketplaceRepository(),
          prefs: prefs,
        );

        expect(provider.selectedCurrency, 'USD');
        expect(provider.supportedCurrencies.length, 6);

        await provider.setCurrency('AED');
        expect(provider.selectedCurrency, 'AED');
        expect(prefs.getString(AppConstants.prefCurrency), 'AED');

        await provider.setCurrency('UNKNOWN_CURRENCY');
        expect(provider.selectedCurrency, 'AED');
      },
    );
  });
}
