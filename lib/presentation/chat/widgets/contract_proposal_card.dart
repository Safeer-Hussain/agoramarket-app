import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../core/utils/currency_converter.dart';
import '../../../domain/entities/chat_entities.dart';
import '../../profile/profile_provider.dart';
import '../chat_provider.dart';
import 'arbitration_resolution_modal.dart';
import 'dispute_resolution_modal.dart';

class ContractProposalCard extends StatelessWidget {
  final ContractOffer offer;

  const ContractProposalCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final isPending = offer.status == 'PENDING';
    final isAccepted = offer.status == 'ACCEPTED';
    final isCountered = offer.status == 'COUNTERED';
    final isDisputed = offer.status == 'DISPUTED';
    final isResolved = offer.status == 'RESOLVED';

    Color statusColor;
    if (isAccepted || isResolved) {
      statusColor = colorScheme.primary;
    } else if (isDisputed) {
      statusColor = colorScheme.error;
    } else if (isCountered) {
      statusColor = colorScheme.tertiary;
    } else {
      statusColor = colorScheme.secondary;
    }

    String activeCurrency = 'PKR';
    try {
      final profileProvider = Provider.of<ProfileProvider>(context);
      activeCurrency = profileProvider.selectedCurrency;
    } catch (_) {
      activeCurrency = 'PKR';
    }

    final convertedDisplay = (offer.currency == activeCurrency)
        ? (activeCurrency == 'PKR'
              ? CurrencyConverter.format(offer.budget, 'USD')
              : CurrencyConverter.format(offer.budget, 'PKR'))
        : CurrencyConverter.format(offer.budget, activeCurrency);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? colorScheme.secondary : colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Badge
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Milestone Escrow Contract',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.6)),
                ),
                child: Text(
                  offer.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            offer.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Budget & Timeline
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Escrow Value',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${offer.budget.toStringAsFixed(0)} ${offer.currency}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.secondary,
                        ),
                      ),
                      Text(
                        '~ $convertedDisplay',
                        style: TextStyle(
                          fontSize: 9,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Timeline',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${offer.deliveryDays} Days',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Structured milestones',
                        style: TextStyle(
                          fontSize: 9,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Terms
          Text(
            'Deliverable Scope:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            offer.terms,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface,
              height: 1.35,
            ),
          ),

          // Action Buttons if pending
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label:
                        'Accept milestone escrow contract offer of \$${offer.budget.toStringAsFixed(0)}',
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        chatProvider.updateContractStatus(offer.id, 'ACCEPTED');
                        AppFeedback.showSuccess(
                          context,
                          'Contract Accepted. Escrow milestone locked.',
                        );
                      },
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                      ),
                      label: const Text(
                        'Accept Offer',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Counter contract terms for proposal',
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(color: colorScheme.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        chatProvider.updateContractStatus(
                          offer.id,
                          'COUNTERED',
                        );
                        AppFeedback.showInfo(
                          context,
                          'Counter-offer signal sent to client.',
                        );
                      },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                      label: const Text(
                        'Counter Offer',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Action Buttons if accepted
          if (isAccepted) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Milestone locked in escrow. Open tribunal dispute if deliverables are incomplete',
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(
                          color: colorScheme.error.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        DisputeResolutionModal.show(context, offer);
                      },
                      icon: const Icon(Icons.gavel_rounded, size: 16),
                      label: const Text(
                        'Open Tribunal Dispute',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Dispute Banner if in arbitration
          if (isDisputed) ...[
            const SizedBox(height: 14),
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                final dispute = provider.getDisputeForContract(offer.id);
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: colorScheme.error,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'ARBITRATION TRIBUNAL ACTIVE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.error,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (dispute != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Claim: ${dispute.reason}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Requested: ${dispute.proposedRefundPercent.toStringAsFixed(0)}% Refund',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            final currentDispute =
                                dispute ??
                                EscrowDispute(
                                  id: 'disp_auto',
                                  contractId: offer.id,
                                  conversationId: offer.conversationId,
                                  claimantName: 'Client',
                                  reason: 'Milestone Deliverable Incomplete',
                                  evidenceNotes:
                                      'Scope discrepancies reported.',
                                  claimAmount: offer.budget,
                                  proposedRefundPercent: 50.0,
                                  status: 'OPEN',
                                  resolutionNotes: 'Pending tribunal review.',
                                  createdAt: DateTime.now().toIso8601String(),
                                );
                            ArbitrationResolutionModal.show(
                              context,
                              offer: offer,
                              dispute: currentDispute,
                            );
                          },
                          icon: const Icon(Icons.balance_rounded, size: 16),
                          label: const Text(
                            'Adjudicate Tribunal Dispute',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],

          // Resolution Banner if resolved
          if (isResolved) ...[
            const SizedBox(height: 14),
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                final dispute = provider.getDisputeForContract(offer.id);
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TRIBUNAL RULING ENFORCED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dispute?.resolutionNotes ?? 'Settlement disbursed according to protocol ruling.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
