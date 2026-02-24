import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../widgets/recovery_score_ring.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/recommendation_card.dart';
import '../../widgets/muscle_heatmap.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('MuscleRecovery AI'),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.refresh),
                onPressed: vm.loadDashboard,
              ),
            ],
          ),
          body: vm.isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : vm.errorMessage != null
                  ? _ErrorState(message: vm.errorMessage!, onRetry: vm.loadDashboard)
                  : _DashboardContent(vm: vm),
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardViewModel vm;
  const _DashboardContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: vm.loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Recovery Score Hero ──────────────────────────────────────
            Center(
              child: RecoveryScoreRing(
                score: vm.recoveryScore,
                statusLabel: vm.recoveryStatusLabel,
              ),
            ),

            const SizedBox(height: 28),

            // ── AI Summary ───────────────────────────────────────────────
            if (vm.todayRecommendation != null) ...[
              _SectionHeader(title: "Today's Insight 🤖"),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, Color(0xFF5E9BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  vm.todayRecommendation!.summary,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Biometric Metrics Grid ───────────────────────────────────
            _SectionHeader(title: 'Apple Watch Metrics'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                MetricCard(
                  icon: CupertinoIcons.heart_fill,
                  iconColor: Colors.red,
                  label: 'Heart Rate',
                  value: vm.latestHeartRate != null
                      ? '${vm.latestHeartRate!.toStringAsFixed(0)} bpm'
                      : '-- bpm',
                ),
                MetricCard(
                  icon: CupertinoIcons.waveform,
                  iconColor: AppTheme.accentGreen,
                  label: 'HRV (SDNN)',
                  value: vm.hrv != null
                      ? '${vm.hrv!.toStringAsFixed(0)} ms'
                      : '-- ms',
                  subtitle: vm.hrv != null
                      ? (vm.hrv! > 60 ? '✓ Good' : vm.hrv! > 40 ? 'Moderate' : 'Low')
                      : null,
                ),
                MetricCard(
                  icon: CupertinoIcons.zzz,
                  iconColor: const Color(0xFF9B59B6),
                  label: 'Sleep',
                  value: vm.sleepData['totalHours'] != null
                      ? '${vm.sleepData['totalHours']!.toStringAsFixed(1)}h'
                      : '--',
                  subtitle: vm.sleepData['qualityScore'] != null
                      ? 'Quality: ${vm.sleepData['qualityScore']!.toStringAsFixed(0)}%'
                      : null,
                ),
                MetricCard(
                  icon: CupertinoIcons.flame_fill,
                  iconColor: AppTheme.warningOrange,
                  label: 'Steps Today',
                  value: '${_formatNumber(vm.todaySteps)}',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Muscle Heatmap ───────────────────────────────────────────
            if (vm.todayRecommendation != null) ...[
              _SectionHeader(title: 'Muscle Recovery Status'),
              const SizedBox(height: 12),
              MuscleHeatmap(
                muscleData: Map<String, double>.from(
                  vm.todayRecommendation!.muscleRecoveryEstimate
                      .map((k, v) => MapEntry(k, (v as num).toDouble())),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Recommendations ──────────────────────────────────────────
            if (vm.todayRecommendation != null &&
                vm.todayRecommendation!.recommendations.isNotEmpty) ...[
              _SectionHeader(title: 'Recovery Recommendations'),
              const SizedBox(height: 12),
              ...vm.todayRecommendation!.recommendations
                  .take(4)
                  .map((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RecommendationCard(recommendation: rec),
                      )),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.exclamationmark_circle,
                size: 64, color: AppTheme.warningOrange),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(CupertinoIcons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
