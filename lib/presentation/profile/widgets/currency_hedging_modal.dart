import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../core/utils/currency_converter.dart';
import '../profile_provider.dart';

class CurrencyHedgingModal extends StatefulWidget {
  const CurrencyHedgingModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CurrencyHedgingModal(),
    );
  }

  @override
  State<CurrencyHedgingModal> createState() => _CurrencyHedgingModalState();
}

class _CurrencyHedgingModalState extends State<CurrencyHedgingModal> {
  double _baseAmountUsd = 3500.0;
  String _selectedTarget = 'PKR';
  int _durationDays = 14;
  double _hedgeRatioPercent = 80.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final profileProvider = Provider.of<ProfileProvider>(context);

    final hedging = CurrencyConverter.calculateHedging(
      baseAmountUsd: _baseAmountUsd,
      targetCurrency: _selectedTarget,
      durationDays: _durationDays,
      hedgeRatioPercent: _hedgeRatioPercent,
    );

    final targetInfo =
        CurrencyConverter.currencies[_selectedTarget] ??
        CurrencyConverter.currencies['USD']!;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
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
                      Icons.currency_exchange_rounded,
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
                          'Multi-Peg FX & Hedging Calculator',
                          style: TextStyle(
                            fontSize: isLandscape ? 15 : 17,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Escrow foreign exchange volatility and forward hedge simulator',
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
              const SizedBox(height: 16),

              // Target Currency Selector Chips
              Text(
                'Target Settlement Currency',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: CurrencyConverter.currencies.keys.map((code) {
                  final isSel = _selectedTarget == code;
                  final info = CurrencyConverter.currencies[code]!;
                  return ChoiceChip(
                    label: Text(
                      '${info.code} (${info.symbol.trim()})',
                      style: TextStyle(
                        fontSize: 12,
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
                      if (val) setState(() => _selectedTarget = code);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Base Escrow Amount Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contract Escrow Principal',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '\$${_baseAmountUsd.toStringAsFixed(0)} USD',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _baseAmountUsd,
                min: 500.0,
                max: 20000.0,
                divisions: 39,
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.surfaceContainerHighest,
                onChanged: (val) => setState(() => _baseAmountUsd = val),
              ),

              // Duration Horizon Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Horizon',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '$_durationDays Days',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _durationDays.toDouble(),
                min: 7.0,
                max: 90.0,
                divisions: 83,
                activeColor: colorScheme.secondary,
                inactiveColor: colorScheme.surfaceContainerHighest,
                onChanged: (val) => setState(() => _durationDays = val.round()),
              ),

              // Forward Hedging Protection Ratio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Forward Contract Hedge Ratio',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${_hedgeRatioPercent.round()}% Protected',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _hedgeRatioPercent,
                min: 0.0,
                max: 100.0,
                divisions: 20,
                activeColor: colorScheme.tertiary,
                inactiveColor: colorScheme.surfaceContainerHighest,
                onChanged: (val) => setState(() => _hedgeRatioPercent = val),
              ),
              const SizedBox(height: 12),

              // Telemetry Calculation Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _buildTelemetryRow(
                      context,
                      label: 'Nominal Spot Value',
                      value:
                          '${targetInfo.symbol}${hedging.standardValue.toStringAsFixed(1)}',
                      textColor: colorScheme.onSurface,
                    ),
                    const SizedBox(height: 8),
                    _buildTelemetryRow(
                      context,
                      label:
                          'Unhedged Downside (${hedging.projectedVolatilityPercent.toStringAsFixed(1)}% Volatility)',
                      value:
                          '${targetInfo.symbol}${hedging.worstCaseValue.toStringAsFixed(1)}',
                      textColor: colorScheme.error,
                    ),
                    const SizedBox(height: 8),
                    _buildTelemetryRow(
                      context,
                      label:
                          'Hedged Floor Value (${_hedgeRatioPercent.round()}% Coverage)',
                      value:
                          '${targetInfo.symbol}${hedging.protectedValue.toStringAsFixed(1)}',
                      textColor: colorScheme.primary,
                      isBold: true,
                    ),
                    const Divider(height: 16),
                    _buildTelemetryRow(
                      context,
                      label: 'Downside Value Protected',
                      value:
                          '+${targetInfo.symbol}${hedging.riskMitigated.toStringAsFixed(1)}',
                      textColor: colorScheme.primary,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Button to set active currency
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
                  onPressed: () {
                    profileProvider.setCurrency(_selectedTarget);
                    Navigator.of(context).pop();
                    AppFeedback.showSuccess(
                      context,
                      'Default marketplace currency updated to $_selectedTarget (${targetInfo.symbol.trim()})',
                    );
                  },
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                  ),
                  label: Text(
                    'Set $_selectedTarget as Active Marketplace Currency',
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
    );
  }

  Widget _buildTelemetryRow(
    BuildContext context, {
    required String label,
    required String value,
    required Color textColor,
    bool isBold = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: textColor,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
