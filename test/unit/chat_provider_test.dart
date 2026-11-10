import 'package:agora_market_app/presentation/chat/chat_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock_repositories.dart';

void main() {
  group('ChatProvider Unit Tests', () {
    late MockChatRepository mockRepo;
    late ChatProvider provider;

    setUp(() {
      mockRepo = MockChatRepository();
      provider = ChatProvider(repository: mockRepo);
    });

    test('Loads conversations and sets first active conversation', () async {
      await provider.loadConversations();
      expect(provider.conversations.isNotEmpty, true);
      expect(provider.activeConversationId, 'conv_01');
      expect(provider.messages.length, 2);
    });

    test(
      'sendTextMessage adds message and updates conversation preview',
      () async {
        await provider.loadConversations();
        final initialCount = provider.messages.length;

        await provider.sendTextMessage('Let us finalize the contract terms.');
        expect(provider.messages.length, initialCount + 1);
        expect(
          provider.messages.last.text,
          'Let us finalize the contract terms.',
        );
        expect(
          provider.activeConversation?.lastMessage,
          'Let us finalize the contract terms.',
        );
      },
    );

    test(
      'sendContractOffer creates structured contract proposal in pending state',
      () async {
        await provider.loadConversations();

        await provider.sendContractOffer(
          conversationId: 'conv_01',
          title: 'Phase 2: Custom Canvas Video Engine',
          budget: 4200.0,
          currency: 'USD',
          deliveryDays: 14,
          terms:
              'Complete sub-8ms rendering implementation with test coverage.',
        );

        final contractMsg = provider.messages.last;
        expect(contractMsg.isContract, true);
        expect(contractMsg.contractId != null, true);

        final offer = provider.getContractOffer(contractMsg.contractId);
        expect(offer != null, true);
        expect(offer?.title, 'Phase 2: Custom Canvas Video Engine');
        expect(offer?.budget, 4200.0);
        expect(offer?.status, 'PENDING');
      },
    );

    test('updateContractStatus mutates contract status to ACCEPTED', () async {
      await provider.loadConversations();
      const contractId = 'contract_01';

      final initialOffer = provider.getContractOffer(contractId);
      expect(initialOffer?.status, 'PENDING');

      await provider.updateContractStatus(contractId, 'ACCEPTED');
      final updatedOffer = provider.getContractOffer(contractId);
      expect(updatedOffer?.status, 'ACCEPTED');
    });

    test('initiateDispute creates EscrowDispute and transitions contract to DISPUTED', () async {
      await provider.loadConversations();
      const contractId = 'contract_01';
      await provider.updateContractStatus(contractId, 'ACCEPTED');

      await provider.initiateDispute(
        contractId: contractId,
        reason: 'Milestone Deliverable Incomplete',
        evidenceNotes: 'Missing automated unit tests and benchmark suite.',
        proposedRefundPercent: 50.0,
      );

      final updatedOffer = provider.getContractOffer(contractId);
      expect(updatedOffer?.status, 'DISPUTED');

      final dispute = provider.getDisputeForContract(contractId);
      expect(dispute != null, true);
      expect(dispute?.reason, 'Milestone Deliverable Incomplete');
      expect(dispute?.proposedRefundPercent, 50.0);
      expect(dispute?.status, 'OPEN');
    });

    test('resolveDispute enforces binding settlement and transitions contract to RESOLVED', () async {
      await provider.loadConversations();
      const contractId = 'contract_01';
      await provider.updateContractStatus(contractId, 'ACCEPTED');

      await provider.initiateDispute(
        contractId: contractId,
        reason: 'Specification Scope Drift',
        evidenceNotes: 'Scope deviation in video player canvas.',
        proposedRefundPercent: 50.0,
      );

      await provider.resolveDispute(
        contractId: contractId,
        resolutionStatus: 'RESOLVED_SPLIT',
        resolutionNotes: 'Mutual 50/50 compromise settlement approved.',
      );

      final updatedOffer = provider.getContractOffer(contractId);
      expect(updatedOffer?.status, 'RESOLVED');

      final dispute = provider.getDisputeForContract(contractId);
      expect(dispute?.status, 'RESOLVED_SPLIT');
      expect(
        dispute?.resolutionNotes,
        'Mutual 50/50 compromise settlement approved.',
      );
      expect(dispute?.resolvedAt != null, true);
    });

    test(
      'isTyping indicator simulation resets cleanly inside try-finally',
      () async {
        await provider.loadConversations();
        expect(provider.isTyping, false);

        await provider.sendTextMessage('Inquiry test message');
        expect(provider.isTyping, true);

        // Wait for timer to complete and execute finally block
        await Future.delayed(const Duration(milliseconds: 1600));
        expect(provider.isTyping, false);
      },
    );
  });
}
