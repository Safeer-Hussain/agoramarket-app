import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/currency_converter.dart';
import '../../debug/recruiter_debug_drawer.dart';
import '../profile_provider.dart';
import 'currency_hedging_modal.dart';

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

            // Multi-Currency Peg Switch
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.currency_exchange_rounded,
                          color: colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Marketplace Currency Peg',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      profileProvider.selectedCurrency,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Select settlement currency across 6 dynamic offline currency pegs',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: CurrencyConverter.currencies.keys.map((code) {
                    final isSel = profileProvider.selectedCurrency == code;
                    final info = CurrencyConverter.currencies[code]!;
                    return ChoiceChip(
                      label: Text(
                        '$code ${info.symbol.trim()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          color: isSel
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      onSelected: (val) {
                        if (val) profileProvider.setCurrency(code);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Currency Hedging & Forward FX Calculator
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.analytics_outlined,
                color: colorScheme.tertiary,
              ),
              title: Text(
                'FX Hedging & Volatility Calculator',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Simulate forward contracts and currency risk mitigation',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                  CurrencyHedgingModal.show(context);
                },
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
