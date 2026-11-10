import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_feedback.dart';
import '../chat_provider.dart';

class SendContractModal extends StatefulWidget {
  final String conversationId;

  const SendContractModal({super.key, required this.conversationId});

  static void show(BuildContext context, String conversationId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SendContractModal(conversationId: conversationId),
    );
  }

  @override
  State<SendContractModal> createState() => _SendContractModalState();
}

class _SendContractModalState extends State<SendContractModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _daysController = TextEditingController(text: '14');
  final _termsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    _daysController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final budget = double.tryParse(_budgetController.text.trim()) ?? 1500.0;
    final days = int.tryParse(_daysController.text.trim()) ?? 14;

    chatProvider.sendContractOffer(
      conversationId: widget.conversationId,
      title: _titleController.text.trim(),
      budget: budget,
      currency: 'USD',
      deliveryDays: days,
      terms: _termsController.text.trim(),
    );

    Navigator.of(context).pop();
    AppFeedback.showSuccess(
      context,
      'Contract proposal embedded in chat stream',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    'Draft Milestone Proposal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create structured escrow deliverables directly inside this conversation.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Milestone Title',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText:
                          'e.g. Phase 1: Real-Time Chat Engine & SQLite DB',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 5) {
                        return 'Title must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Budget & Timeline
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget (USD)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _budgetController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 13,
                              ),
                              decoration: const InputDecoration(
                                hintText: '2500',
                                prefixText: '\$ ',
                              ),
                              validator: (v) {
                                final n = double.tryParse(v ?? '');
                                if (n == null || n <= 0) {
                                  return 'Enter budget';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Days',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _daysController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 13,
                              ),
                              decoration: const InputDecoration(
                                hintText: '14',
                                suffixText: 'days',
                              ),
                              validator: (v) {
                                final d = int.tryParse(v ?? '');
                                if (d == null || d <= 0) {
                                  return 'Enter days';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Terms
                  Text(
                    'Milestone Deliverable Terms',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _termsController,
                    maxLines: 3,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Describe acceptance criteria, repository PRs, and verification',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 15) {
                        return 'Terms must be at least 15 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submit,
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text(
                        'Dispatch Proposal',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
