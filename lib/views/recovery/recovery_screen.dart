import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/recovery_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../widgets/muscle_heatmap.dart';
import '../../widgets/recommendation_card.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecoveryViewModel>().loadRecoveryDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RecoveryViewModel, DashboardViewModel>(
      builder: (context, rvm, dvm, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Recovery Details')),
          body: rvm.isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── HRV History Chart ──────────────────────────────
                      const _SectionTitle('HRV History (14 days)'),
                      const SizedBox(height: 12),
                      _HRVChart(history: dvm.getRecoveryHistory()),

                      const SizedBox(height: 24),

                      // ── Muscle Heatmap ─────────────────────────────────
                      const _SectionTitle('Muscle Group Status'),
                      const SizedBox(height: 12),
                      rvm.muscleRecovery.isNotEmpty
                          ? MuscleHeatmap(muscleData: rvm.muscleRecovery)
                          : const Text('Muscle data loading...'),

                      const SizedBox(height: 24),

                      // ── Next Workout Suggestion ────────────────────────
                      if (rvm.recommendation?.nextWorkoutSuggestion != null)
                        _NextWorkoutCard(
                          suggestion:
                              rvm.recommendation!.nextWorkoutSuggestion!,
                        ),

                      const SizedBox(height: 24),

                      // ── All Recommendations ────────────────────────────
                      if (rvm.recommendation != null) ...[
                        const _SectionTitle('All Recommendations'),
                        const SizedBox(height: 12),
                        ...rvm.recommendation!.recommendations
                            .map((r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: RecommendationCard(recommendation: r),
                                )),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }
}

class _HRVChart extends StatelessWidget {
  final List history;
  const _HRVChart({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child:
            const Text('No history yet', style: TextStyle(color: Colors.grey)),
      );
    }

    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.hrv.clamp(0.0, 100.0));
    }).toList();

    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primaryBlue,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryBlue.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextWorkoutCard extends StatelessWidget {
  final Map<String, dynamic> suggestion;
  const _NextWorkoutCard({required this.suggestion});

  Color get _intensityColor {
    switch (suggestion['intensity']) {
      case 'light':
        return AppTheme.accentGreen;
      case 'moderate':
        return AppTheme.primaryBlue;
      case 'high':
        return AppTheme.warningOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_intensityColor, _intensityColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏋️ Next Workout Suggestion',
            style: TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            suggestion['name'] ?? '',
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            suggestion['reason'] ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${suggestion['intensity']?.toString().toUpperCase() ?? ''} INTENSITY',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
