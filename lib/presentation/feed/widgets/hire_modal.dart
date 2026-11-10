import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/video_pitch.dart';
import '../../chat/chat_provider.dart';

class HireModal extends StatefulWidget {
  final VideoPitch pitch;

  const HireModal({super.key, required this.pitch});

  static void show(BuildContext context, VideoPitch pitch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => HireModal(pitch: pitch),
    );
  }

  @override
  State<HireModal> createState() => _HireModalState();
}

class _HireModalState extends State<HireModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _daysController = TextEditingController(text: '14');
  final _termsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = 'Contract: ${widget.pitch.title}';
    _budgetController.text = (widget.pitch.hourlyRate * 40).toStringAsFixed(0);
    _termsController.text = 'Full architecture implementation, clean unit tests, 120 FPS performance verification, and handover documentation.';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    _daysController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  void _submitProposal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;
    final days = int.tryParse(_daysController.text.trim()) ?? 7;

    chatProvider.sendContractOffer(
      conversationId: 'conv_ayesha', // Connected negotiation channel
      title: _titleController.text.trim(),
      budget: budget,
      currency: widget.pitch.currency,
      deliveryDays: days,
      terms: _termsController.text.trim(),
    );

    Navigator.of(context).pop();
    AppFeedback.showSuccess(
      context,
      'Contract proposal dispatched to ${widget.pitch.creatorName}',
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        backgroundImage: AssetImage(widget.pitch.creatorAvatar),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hire ${widget.pitch.creatorName}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${widget.pitch.role} • ${widget.pitch.currency} \$${widget.pitch.hourlyRate.toStringAsFixed(0)}/hr',
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
                  const SizedBox(height: 20),

                  // Contract Title
                  Text(
                    'Contract Title',
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
                      hintText: 'Enter specific project deliverable title',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 5) {
                        return 'Title must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Budget & Timeline Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fixed Budget (${widget.pitch.currency})',
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
                                hintText: '3800',
                                prefixText: '\$ ',
                              ),
                              validator: (v) {
                                final n = double.tryParse(v ?? '');
                                if (n == null || n <= 0) {
                                  return 'Enter valid budget';
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
                  const SizedBox(height: 14),

                  // Deliverable Terms
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
                      hintText:
                          'Describe scope, acceptance tests, and milestones',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 15) {
                        return 'Provide detailed terms (minimum 15 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
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
                      onPressed: _submitProposal,
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text(
                        'Dispatch Contract Offer',
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
