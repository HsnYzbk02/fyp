import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Visual heatmap showing recovery % per muscle group
class MuscleHeatmap extends StatelessWidget {
  final Map<String, double> muscleData;

  const MuscleHeatmap({super.key, required this.muscleData});

  Color _colorForValue(double value) {
    if (value >= 80) return AppTheme.recoveryFull;
    if (value >= 60) return AppTheme.primaryBlue;
    if (value >= 40) return AppTheme.recoveryMid;
    return AppTheme.recoveryLow;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sorted = muscleData.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...sorted.map((entry) {
            final color = _colorForValue(entry.value);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: entry.value / 100,
                        minHeight: 10,
                        backgroundColor: color.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 38,
                    child: Text(
                      '${entry.value.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppTheme.recoveryLow, label: 'Fatigued'),
              const SizedBox(width: 16),
              _LegendDot(color: AppTheme.recoveryMid, label: 'Recovering'),
              const SizedBox(width: 16),
              _LegendDot(color: AppTheme.recoveryFull, label: 'Ready'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}
