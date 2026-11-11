class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final double rateToUsd;
  final double volatilityPercent;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.rateToUsd,
    required this.volatilityPercent,
  });
}

class HedgingResult {
  final String targetCurrency;
  final double standardValue;
  final double worstCaseValue;
  final double bestCaseValue;
  final double protectedValue;
  final double riskMitigated;
  final double projectedVolatilityPercent;

  const HedgingResult({
    required this.targetCurrency,
    required this.standardValue,
    required this.worstCaseValue,
    required this.bestCaseValue,
    required this.protectedValue,
    required this.riskMitigated,
    required this.projectedVolatilityPercent,
  });
}

class CurrencyConverter {
  static const Map<String, CurrencyInfo> currencies = {
    'USD': CurrencyInfo(
      code: 'USD',
      name: 'United States Dollar',
      symbol: '\$',
      rateToUsd: 1.0,
      volatilityPercent: 0.1,
    ),
    'PKR': CurrencyInfo(
      code: 'PKR',
      name: 'Pakistani Rupee',
      symbol: 'Rs ',
      rateToUsd: 278.50,
      volatilityPercent: 1.8,
    ),
    'EUR': CurrencyInfo(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      rateToUsd: 0.92,
      volatilityPercent: 0.4,
    ),
    'GBP': CurrencyInfo(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      rateToUsd: 0.79,
      volatilityPercent: 0.5,
    ),
    'AED': CurrencyInfo(
      code: 'AED',
      name: 'UAE Dirham',
      symbol: 'AED ',
      rateToUsd: 3.67,
      volatilityPercent: 0.05,
    ),
    'SAR': CurrencyInfo(
      code: 'SAR',
      name: 'Saudi Riyal',
      symbol: 'SAR ',
      rateToUsd: 3.75,
      volatilityPercent: 0.05,
    ),
  };

  static double convert(double amountInUsd, String targetCurrency) {
    final info = currencies[targetCurrency] ?? currencies['USD']!;
    return amountInUsd * info.rateToUsd;
  }

  static String format(double amountInUsd, String targetCurrency) {
    final info = currencies[targetCurrency] ?? currencies['USD']!;
    final converted = convert(amountInUsd, targetCurrency);
    if (targetCurrency == 'PKR') {
      return '${info.symbol}${converted.toStringAsFixed(0)}';
    } else if (targetCurrency == 'USD' ||
        targetCurrency == 'EUR' ||
        targetCurrency == 'GBP') {
      return '${info.symbol}${converted.toStringAsFixed(2)}';
    } else {
      return '${info.symbol}${converted.toStringAsFixed(1)}';
    }
  }

  static HedgingResult calculateHedging({
    required double baseAmountUsd,
    required String targetCurrency,
    required int durationDays,
    required double hedgeRatioPercent,
  }) {
    final info = currencies[targetCurrency] ?? currencies['USD']!;
    final standardConverted = baseAmountUsd * info.rateToUsd;

    final timeFactor = (durationDays / 30.0).clamp(0.2, 4.0);
    final projectedShift = (info.volatilityPercent / 100.0) * timeFactor;
    final worstCaseRate = info.rateToUsd * (1.0 - projectedShift);
    final bestCaseRate = info.rateToUsd * (1.0 + projectedShift);

    final unhedgedWorstValue = baseAmountUsd * worstCaseRate;

    final hedgedPortion = (hedgeRatioPercent / 100.0).clamp(0.0, 1.0);
    final protectedValue =
        (baseAmountUsd * hedgedPortion * info.rateToUsd) +
        (baseAmountUsd * (1.0 - hedgedPortion) * worstCaseRate);
    final riskMitigated = protectedValue - unhedgedWorstValue;

    return HedgingResult(
      targetCurrency: targetCurrency,
      standardValue: standardConverted,
      worstCaseValue: unhedgedWorstValue,
      bestCaseValue: baseAmountUsd * bestCaseRate,
      protectedValue: protectedValue,
      riskMitigated: riskMitigated,
      projectedVolatilityPercent: projectedShift * 100.0,
    );
  }
}
