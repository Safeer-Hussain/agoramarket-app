import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_feedback.dart';
import '../video_feed_provider.dart';

class PublishPitchModal extends StatefulWidget {
  const PublishPitchModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const PublishPitchModal(),
    );
  }

  @override
  State<PublishPitchModal> createState() => _PublishPitchModalState();
}

class _PublishPitchModalState extends State<PublishPitchModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _roleController = TextEditingController();
  final _rateController = TextEditingController();
  final _locationController = TextEditingController(
    text: 'Gulberg III, Lahore',
  );
  final _scriptController = TextEditingController();
  final _skillsController = TextEditingController(
    text: 'Flutter, Dart, Clean Architecture',
  );
  String _selectedCategory = 'Freelancer';

  @override
  void dispose() {
    _titleController.dispose();
    _roleController.dispose();
    _rateController.dispose();
    _locationController.dispose();
    _scriptController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final feed = Provider.of<VideoFeedProvider>(context, listen: false);
    final rate = double.tryParse(_rateController.text.trim()) ?? 80.0;
    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    feed.createVideoPitch(
      title: _titleController.text.trim(),
      role: _roleController.text.trim(),
      hourlyRate: rate,
      currency: 'USD',
      locationName: _locationController.text.trim(),
      category: _selectedCategory,
      pitchScript: _scriptController.text.trim(),
      skills: skills,
    );

    Navigator.of(context).pop();
    AppFeedback.showSuccess(
      context,
      'Video pitch published to sub-second live feed',
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
                    'Publish Video Pitch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Present your engineering expertise or open role with custom canvas reels.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pitch Title
                  Text(
                    'Pitch Title',
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
                      hintText: 'e.g. Architecting 120FPS Vertical Video Feed',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 8) {
                        return 'Title must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Category Selection
                  Text(
                    'Listing Type',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Freelancer',
                        label: Text('Freelancer'),
                      ),
                      ButtonSegment(value: 'Job', label: Text('Job Role')),
                      ButtonSegment(value: 'Agency', label: Text('Agency')),
                    ],
                    selected: {_selectedCategory},
                    onSelectionChanged: (val) {
                      setState(() {
                        _selectedCategory = val.first;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Role & Hourly Rate
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Specialist Role',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _roleController,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 13,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Principal Flutter Architect',
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Role is required';
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
                              'Hourly Rate (USD)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _rateController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 13,
                              ),
                              decoration: const InputDecoration(
                                hintText: '95',
                                prefixText: '\$ ',
                              ),
                              validator: (v) {
                                final n = double.tryParse(v ?? '');
                                if (n == null || n <= 0) {
                                  return 'Enter valid rate';
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

                  // Location
                  Text(
                    'Location Hub',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _locationController,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Gulberg III, Lahore',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Location is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Skills
                  Text(
                    'Skills & Tech Stack (comma-separated)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _skillsController,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Flutter, Dart, Clean Architecture',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Provide at least one skill';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Pitch Script
                  Text(
                    'Video Script & Value Proposition',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _scriptController,
                    maxLines: 3,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Outline what you demonstrate in this technical pitch reel',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 15) {
                        return 'Script must be at least 15 characters';
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
                      onPressed: _submit,
                      icon: const Icon(Icons.videocam_rounded, size: 20),
                      label: const Text(
                        'Publish to Feed',
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
