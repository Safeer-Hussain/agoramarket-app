import 'package:agora_market_app/core/theme/app_theme.dart';
import 'package:agora_market_app/core/theme/theme_provider.dart';
import 'package:agora_market_app/presentation/profile/profile_provider.dart';
import 'package:agora_market_app/presentation/profile/widgets/currency_hedging_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Sprint 27: Currency hedging modal renders and is 800x360 landscape safe',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final profileProvider = ProfileProvider(
        profileRepository: MockProfileRepository(),
        marketplaceRepository: MockMarketplaceRepository(),
        prefs: prefs,
      );

      // Verify on 800x360 landscape viewport
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider(prefs: prefs),
            ),
            ChangeNotifierProvider<ProfileProvider>.value(
              value: profileProvider,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Center(
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () => CurrencyHedgingModal.show(context),
                      child: const Text('Open Hedging Calculator'),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open the modal
      await tester.tap(find.text('Open Hedging Calculator'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Verify modal title and telemetry cards render
      expect(find.byType(CurrencyHedgingModal), findsOneWidget);
      expect(find.text('Multi-Peg FX & Hedging Calculator'), findsOneWidget);
      expect(find.text('Target Settlement Currency'), findsOneWidget);
      expect(find.text('Contract Escrow Principal'), findsOneWidget);
      expect(find.text('Delivery Horizon'), findsOneWidget);
      expect(find.text('Forward Contract Hedge Ratio'), findsOneWidget);

      // 2. Verify all 6 currency choice chips exist
      expect(find.text('USD (\$)'), findsOneWidget);
      expect(find.text('PKR (Rs)'), findsOneWidget);
      expect(find.text('EUR (€)'), findsOneWidget);
      expect(find.text('GBP (£)'), findsOneWidget);
      expect(find.text('AED (AED)'), findsOneWidget);
      expect(find.text('SAR (SAR)'), findsOneWidget);

      // 3. Switch currency to EUR and scroll down to tap the submit button
      await tester.tap(find.text('EUR (€)'));
      await tester.pump();

      final buttonFinder = find.text('Set EUR as Active Marketplace Currency');
      await tester.scrollUntilVisible(
        buttonFinder,
        150.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pump();

      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify ProfileProvider active currency updated
      expect(profileProvider.selectedCurrency, 'EUR');

      // 4. Zero RenderFlex overflow exceptions
      expect(tester.takeException(), isNull);
    },
  );
}
