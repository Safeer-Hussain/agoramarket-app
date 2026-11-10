import 'package:agora_market_app/core/theme/app_theme.dart';
import 'package:agora_market_app/core/theme/theme_provider.dart';
import 'package:agora_market_app/domain/entities/chat_entities.dart';
import 'package:agora_market_app/presentation/chat/chat_provider.dart';
import 'package:agora_market_app/presentation/chat/widgets/contract_proposal_card.dart';
import 'package:agora_market_app/presentation/chat/widgets/dispute_resolution_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_repositories.dart';

void main() {
  testWidgets(
    'Sprint 26: Escrow dispute tribunal UI and landscape 360dp safety test',
    (tester) async {
      final mockRepo = MockChatRepository();
      final chatProvider = ChatProvider(repository: mockRepo);
      await chatProvider.loadConversations();

      const acceptedOffer = ContractOffer(
        id: 'contract_test_disp',
        conversationId: 'conv_01',
        title: 'Phase 2: Custom Canvas Video Engine',
        budget: 4200.0,
        currency: 'USD',
        deliveryDays: 14,
        status: 'ACCEPTED',
        terms: 'Complete sub-8ms rendering implementation with test coverage.',
        createdAt: '2026-11-06T00:00:00Z',
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
              create: (_) => ThemeProvider(),
            ),
            ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ContractProposalCard(offer: acceptedOffer),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Verify accepted contract card contains Open Tribunal Dispute button
      expect(find.text('Open Tribunal Dispute'), findsOneWidget);

      // 2. Tap to open DisputeResolutionModal
      await tester.tap(find.text('Open Tribunal Dispute'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 3. Verify modal contents
      expect(find.byType(DisputeResolutionModal), findsOneWidget);
      expect(find.text('Escrow Dispute & Arbitration'), findsOneWidget);
      expect(find.text('Proposed Settlement Allocation'), findsOneWidget);
      expect(find.text('Submit Escrow Dispute to Tribunal'), findsOneWidget);

      // 4. Verify no RenderFlex overflow exceptions occurred
      expect(tester.takeException(), isNull);
    },
  );
}
