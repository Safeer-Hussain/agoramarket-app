import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/chat_entities.dart';
import '../chat_provider.dart';

class ArbitrationResolutionModal extends StatefulWidget {
  final ContractOffer offer;
  final EscrowDispute dispute;

  const ArbitrationResolutionModal({
    super.key,
    required this.offer,
    required this.dispute,
  });

  static Future<void> show(
    BuildContext context, {
    required ContractOffer offer,
    required EscrowDispute dispute,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ArbitrationResolutionModal(offer: offer, dispute: dispute),
    );
  }

  @override
  State<ArbitrationResolutionModal> createState() =>
      _ArbitrationResolutionModalState();
}

class _ArbitrationResolutionModalState
    extends State<ArbitrationResolutionModal> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController(
    text: 'Tribunal reviewed deliverable git commits and performance logs. Settlement executed under AgoraMarket arbitration guidelines.',
  );

  String _selectedRuling = 'RESOLVED_SPLIT'; // 'RESOLVED_SPLIT', 'RESOLVED_REFUND', 'RESOLVED_PAYOUT'
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _issueRuling() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    try {
      await chatProvider.resolveDispute(
        contractId: widget.offer.id,
        resolutionStatus: _selectedRuling,
        resolutionNotes: _notesController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      AppFeedback.showSuccess(
        context,
        'Tribunal Ruling Executed. Escrow disbursed according to resolution.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppFeedback.showError(context, 'Failed to execute ruling: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Modal Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.balance_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tribunal Adjudication Desk',
                            style: TextStyle(
                              fontSize: isLandscape ? 15 : 17,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Binding Dispute Ruling: ${widget.dispute.id}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dispute Evidence Dossier Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Claimant: ${widget.dispute.claimantName}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '\$${widget.dispute.claimAmount.toStringAsFixed(0)} ${widget.offer.currency}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reason: ${widget.dispute.reason}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Evidence: ${widget.dispute.evidenceNotes}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Initial Proposed Refund: ${widget.dispute.proposedRefundPercent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Binding Ruling Options
                Text(
                  'Select Binding Arbitration Ruling',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                _buildRulingTile(
                  context,
                  id: 'RESOLVED_SPLIT',
                  title: '50/50 Compromise Settlement',
                  subtitle:
                      'Splits \$${widget.offer.budget.toStringAsFixed(0)} equally: \$${(widget.offer.budget * 0.5).toStringAsFixed(0)} refunded, \$${(widget.offer.budget * 0.5).toStringAsFixed(0)} paid to talent.',
                  icon: Icons.pie_chart_outline_rounded,
                ),
                const SizedBox(height: 8),
                _buildRulingTile(
                  context,
                  id: 'RESOLVED_REFUND',
                  title: '100% Full Refund to Client',
                  subtitle:
                      'Deliverables deemed unacceptable. All \$${widget.offer.budget.toStringAsFixed(0)} refunded to client escrow balance.',
                  icon: Icons.undo_rounded,
                ),
                const SizedBox(height: 8),
                _buildRulingTile(
                  context,
                  id: 'RESOLVED_PAYOUT',
                  title: '100% Full Payout to Talent',
                  subtitle:
                      'Specifications verified complete. Full \$${widget.offer.budget.toStringAsFixed(0)} disbursed to talent.',
                  icon: Icons.check_circle_outline_rounded,
                ),
                const SizedBox(height: 16),

                // Tribunal Notes
                Text(
                  'Tribunal Adjudication Remarks',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Enter tribunal rationale and execution log...',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Adjudication remarks are required for audit trail.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Execute Ruling Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _issueRuling,
                    icon: _isSubmitting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.gavel_rounded, size: 18),
                    label: Text(
                      _isSubmitting
                          ? 'Enforcing Ruling...'
                          : 'Issue Binding Tribunal Ruling',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRulingTile(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedRuling == id;

    return InkWell(
      onTap: () => setState(() => _selectedRuling = id),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2, right: 8),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
