import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_feedback.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/video_pitch.dart';
import 'profile_provider.dart';
import 'widgets/add_portfolio_modal.dart';
import 'widgets/edit_profile_modal.dart';
import 'widgets/performance_analytics_card.dart';
import 'widgets/settings_sheet.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        final profile = provider.profile;

        if (provider.isLoading && profile == null) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        if (profile == null) {
          return const Center(child: Text('Profile not initialized'));
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            toolbarHeight: isLandscape ? 36 : 56,
            title: Text(
              'Architect Profile',
              style: TextStyle(
                fontSize: isLandscape ? 14 : 18,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Edit Profile',
                onPressed: () => EditProfileModal.show(context),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 20),
                tooltip: 'Settings',
                onPressed: () => SettingsSheet.show(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'fab_profile_portfolio',
            tooltip: 'Add new verified case study portfolio item',
            mini: isLandscape,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            onPressed: () => AddPortfolioModal.show(context),
            child: const Icon(Icons.add_photo_alternate_outlined),
          ),
          body: isLandscape
              ? _buildLandscapeLayout(context, provider, profile)
              : _buildPortraitLayout(context, provider, profile),
        );
      },
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    ProfileProvider provider,
    UserProfile profile,
  ) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context, provider, profile),
          const SizedBox(height: 16),
          const PerformanceAnalyticsCard(),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Published Video Pitches'),
          const SizedBox(height: 10),
          _buildPitchGrid(context, provider.myPitches),
          const SizedBox(height: 20),
          _buildSectionTitle(
            context,
            'Verified Portfolio & Architecture Case Studies',
          ),
          const SizedBox(height: 10),
          _buildPortfolioList(context, provider.portfolioItems),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    ProfileProvider provider,
    UserProfile profile,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Left Pane: Profile Header & Analytics (independent SingleChildScrollView)
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, provider, profile),
                const SizedBox(height: 12),
                const PerformanceAnalyticsCard(),
              ],
            ),
          ),
        ),

        // Vertical divider
        VerticalDivider(width: 1, color: colorScheme.outlineVariant),

        // Right Pane: Pitches & Portfolio Showcase (independent SingleChildScrollView)
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'Published Video Pitches'),
                const SizedBox(height: 8),
                _buildPitchGrid(context, provider.myPitches),
                const SizedBox(height: 16),
                _buildSectionTitle(context, 'Verified Case Studies'),
                const SizedBox(height: 8),
                _buildPortfolioList(context, provider.portfolioItems),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ProfileProvider provider,
    UserProfile profile,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage: AssetImage(profile.avatarAsset),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.headline,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            profile.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bio
          Text(
            profile.bio,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // Rating & Stats Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatChip(
                context,
                icon: Icons.star_rounded,
                iconColor: colorScheme.tertiary,
                label: '${profile.rating} (${profile.reviewsCount} reviews)',
              ),
              _buildStatChip(
                context,
                icon: Icons.verified_user_outlined,
                iconColor: colorScheme.primary,
                label: '${profile.completedContracts} Escrows Paid',
              ),
              _buildStatChip(
                context,
                icon: Icons.payments_outlined,
                iconColor: colorScheme.secondary,
                label: '\$${profile.hourlyRate.toStringAsFixed(0)}/hr',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Available for Contracts Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: profile.isAvailable
                              ? colorScheme.primary
                              : colorScheme.outline,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          profile.isAvailable
                              ? 'Available for New Contracts'
                              : 'Currently Fully Booked',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  toggled: profile.isAvailable,
                  label:
                      'Toggle contract availability status. Currently ${profile.isAvailable ? "Open for contracts" : "Booked"}',
                  child: Switch(
                    value: profile.isAvailable,
                    activeThumbColor: colorScheme.primary,
                    onChanged: (val) {
                      provider.toggleAvailability(val);
                      AppFeedback.showSuccess(
                        context,
                        val
                            ? 'Availability set to Open'
                            : 'Availability set to Booked',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Skills Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: profile.skills.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildPitchGrid(BuildContext context, List<VideoPitch> pitches) {
    final colorScheme = Theme.of(context).colorScheme;

    if (pitches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No video pitches published yet.',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ),
      );
    }

    // CRITICAL: Explicit mainAxisExtent: 145 so cards never trigger RenderFlex overflow!
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pitches.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 145,
      ),
      itemBuilder: (context, idx) {
        final p = pitches[idx];
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(p.thumbnailAsset, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      colorScheme.surface.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      p.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${p.hourlyRate.toStringAsFixed(0)}/hr',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 10,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              p.likesCount.toString(),
                              style: TextStyle(
                                fontSize: 9,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortfolioList(BuildContext context, List<PortfolioItem> items) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final item = items[idx];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.code_rounded,
                  size: 24,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.metric,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
