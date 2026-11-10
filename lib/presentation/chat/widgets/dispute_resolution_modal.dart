import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/chat_entities.dart';
import '../chat_provider.dart';

class DisputeResolutionModal extends StatefulWidget {
  final ContractOffer offer;

  const DisputeResolutionModal({super.key, required this.offer});

  static Future<void> show(BuildContext context, ContractOffer offer) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DisputeResolutionModal(offer: offer),
    );
  }

  @override
  State<DisputeResolutionModal> createState() => _DisputeResolutionModalState();
}

class _DisputeResolutionModalState extends State<DisputeResolutionModal> {
  final _formKey = GlobalKey<FormState>();
  final _evidenceController = TextEditingController();

  static const List<String> _disputeReasons = [
    'Milestone Deliverable Incomplete',
    'Specification Scope Drift',
    'Deadline Exceeded',
    'Quality Standards Not Met',
  ];

  late String _selectedReason;
  double _refundPercent = 50.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedReason = _disputeReasons.first;
  }

  @override
  void dispose() {
    _evidenceController.dispose();
    super.dispose();
  }

  Future<void> _submitDispute() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    try {
      await chatProvider.initiateDispute(
        contractId: widget.offer.id,
        reason: _selectedReason,
        evidenceNotes: _evidenceController.text.trim(),
        proposedRefundPercent: _refundPercent,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      AppFeedback.showWarning(
        context,
        'Escrow Dispute Filed. Milestone payout frozen for arbitration.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppFeedback.showError(context, 'Failed to file dispute: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final refundAmount = widget.offer.budget * (_refundPercent / 100.0);
    final payoutAmount = widget.offer.budget - refundAmount;

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
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.gavel_rounded,
                        color: colorScheme.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Escrow Dispute & Arbitration',
                            style: TextStyle(
                              fontSize: isLandscape ? 15 : 17,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            widget.offer.title,
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

                // Contract Summary Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Frozen Escrow Value',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${widget.offer.budget.toStringAsFixed(0)} ${widget.offer.currency}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'FUNDS FROZEN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Reason Selection
                Text(
                  'Primary Dispute Reason',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedReason,
                      items: _disputeReasons.map((r) {
                        return DropdownMenuItem<String>(
                          value: r,
                          child: Text(r, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedReason = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Proposed Refund Allocation Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Proposed Settlement Allocation',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${_refundPercent.round()}% Refund',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _refundPercent,
                  min: 0.0,
                  max: 100.0,
                  divisions: 20,
                  activeColor: colorScheme.error,
                  inactiveColor: colorScheme.surfaceContainerHighest,
                  onChanged: (val) {
                    setState(() => _refundPercent = val);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Client Refund: \$${refundAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Talent Payout: \$${payoutAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Evidence Notes Input
                Text(
                  'Arbitration Evidence & Defect Notes',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _evidenceController,
                  maxLines: 3,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Detail the missing deliverables, broken specification commits, or deadline discrepancies...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length < 10) {
                      return 'Please provide at least 10 characters of evidence description.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitDispute,
                    icon: _isSubmitting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onError,
                            ),
                          )
                        : const Icon(Icons.shield_outlined, size: 18),
                    label: Text(
                      _isSubmitting
                          ? 'Submitting to Tribunal...'
                          : 'Submit Escrow Dispute to Tribunal',
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
}
