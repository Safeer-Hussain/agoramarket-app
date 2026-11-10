import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_feedback.dart';
import '../profile_provider.dart';

class EditProfileModal extends StatefulWidget {
  const EditProfileModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const EditProfileModal(),
    );
  }

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _headlineController;
  late TextEditingController _bioController;
  late TextEditingController _rateController;
  late TextEditingController _locationController;
  late TextEditingController _skillsController;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile;
    _nameController = TextEditingController(
      text: profile?.name ?? 'Safeer Hussain',
    );
    _headlineController = TextEditingController(
      text: profile?.headline ?? 'Principal Mobile & Marketplace Architect',
    );
    _bioController = TextEditingController(
      text: profile?.bio ?? 'Architecting high-concurrency vertical video marketplaces and offline-first systems.',
    );
    _rateController = TextEditingController(
      text: profile?.hourlyRate.toStringAsFixed(0) ?? '95',
    );
    _locationController = TextEditingController(
      text: profile?.location ?? 'Lahore, Pakistan (Global Remote)',
    );
    _skillsController = TextEditingController(
      text:
          profile?.skills.join(', ') ??
          'Flutter, Dart, Clean Architecture, SQLite',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _rateController.dispose();
    _locationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final rate = double.tryParse(_rateController.text.trim()) ?? 95.0;
    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    provider.updateProfile(
      name: _nameController.text.trim(),
      headline: _headlineController.text.trim(),
      bio: _bioController.text.trim(),
      hourlyRate: rate,
      location: _locationController.text.trim(),
      skills: skills,
    );

    Navigator.of(context).pop();
    AppFeedback.showSuccess(
      context,
      'Profile information updated successfully',
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
                    'Edit Professional Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Safeer Hussain',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Headline
                  Text(
                    'Professional Headline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _headlineController,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Principal Mobile & Marketplace Architect',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 5) {
                        return 'Headline must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Hourly Rate & Location
                  Row(
                    children: [
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
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
                                hintText: 'Lahore, Pakistan',
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Location is required';
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

                  // Skills
                  Text(
                    'Skills & Core Technologies',
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
                      hintText: 'Flutter, Dart, Clean Architecture, SQLite',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Provide at least one skill';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Bio
                  Text(
                    'Professional Summary',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Summarize your architecture achievements and offerings',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 15) {
                        return 'Bio must be at least 15 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submit,
                      child: const Text(
                        'Save Changes',
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
