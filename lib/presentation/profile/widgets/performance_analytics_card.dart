import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/performance/render_latency_monitor.dart';

class PerformanceAnalyticsCard extends StatelessWidget {
  const PerformanceAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monitor = Provider.of<RenderLatencyMonitor>(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Client Engagement & Telemetry',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${monitor.averageMs.toStringAsFixed(1)}ms Frame',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Key metrics row
          Row(
            children: [
              _buildStat(
                context: context,
                label: 'Pitch Views',
                value: '4,280',
                delta: '+34%',
                isPositive: true,
              ),
              _buildStat(
                context: context,
                label: 'Completion',
                value: '88.4%',
                delta: '+12%',
                isPositive: true,
              ),
              _buildStat(
                context: context,
                label: 'Savings',
                value: '52.1%',
                delta: 'Sub-8ms',
                isPositive: true,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // FlChart Line Chart (Edge-to-edge, reservedSize: 0 on hidden axes)
          SizedBox(
            height: 100,
            width: double.infinity,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 18,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        final idx = value.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Text(
                            days[idx],
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3.2),
                      FlSpot(1, 4.5),
                      FlSpot(2, 6.8),
                      FlSpot(3, 5.9),
                      FlSpot(4, 8.4),
                      FlSpot(5, 7.8),
                      FlSpot(6, 9.6),
                    ],
                    isCurved: true,
                    color: colorScheme.primary,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 5.0),
                      FlSpot(1, 4.8),
                      FlSpot(2, 4.2),
                      FlSpot(3, 3.8),
                      FlSpot(4, 3.1),
                      FlSpot(5, 2.9),
                      FlSpot(6, 2.4),
                    ],
                    isCurved: true,
                    color: colorScheme.secondary,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              _buildLegend(
                color: colorScheme.primary,
                label: 'Pitch Views / Conversions',
              ),
              _buildLegend(
                color: colorScheme.secondary,
                label: 'Render Latency (ms)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStat({
    required BuildContext context,
    required String label,
    required String value,
    required String delta,
    required bool isPositive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 9, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            delta,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isPositive ? colorScheme.primary : colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
