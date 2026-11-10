import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../debug/recruiter_debug_drawer.dart';
import '../profile_provider.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
              'Marketplace Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Dark Mode Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                themeProvider.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: colorScheme.primary,
              ),
              title: Text(
                'Dark Mode Appearance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Obsidian & Electric Teal theme parity',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: themeProvider.isDarkMode,
              activeThumbColor: colorScheme.primary,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
            const Divider(height: 16),

            // Currency Switch
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.currency_exchange_rounded,
                color: colorScheme.secondary,
              ),
              title: Text(
                'Primary Currency',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Toggle between USD and Pakistani Rupee (PKR)',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: FilledButton.tonal(
                onPressed: () => profileProvider.toggleCurrency(),
                child: Text(
                  profileProvider.selectedCurrency,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(height: 16),

            // Distance Unit
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.straighten_rounded,
                color: colorScheme.tertiary,
              ),
              title: Text(
                'Spatial Distance Unit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Kilometers (km) or Miles (mi)',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: FilledButton.tonal(
                onPressed: () => profileProvider.toggleDistanceUnit(),
                child: Text(
                  profileProvider.distanceUnit.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(height: 24),

            // App Version with long-press to open recruiter drawer
            Center(
              child: GestureDetector(
                onLongPress: () {
                  Navigator.of(context).pop();
                  RecruiterDebugDrawer.show(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${AppConstants.appName} ${AppConstants.appVersion} • Long press for Recruiter Drawer',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
