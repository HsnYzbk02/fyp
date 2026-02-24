import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/workout_viewmodel.dart';
import '../../theme/app_theme.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Workout Log')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showLogWorkoutSheet(context, vm),
            icon: const Icon(CupertinoIcons.add),
            label: const Text('Log Workout'),
            backgroundColor: AppTheme.primaryBlue,
          ),
          body: vm.sessions.isEmpty
              ? _EmptyState(onTap: () => _showLogWorkoutSheet(context, vm))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: vm.sessions.length,
                  itemBuilder: (ctx, i) {
                    final s = vm.sessions[i];
                    return _WorkoutTile(session: s);
                  },
                ),
        );
      },
    );
  }

  void _showLogWorkoutSheet(BuildContext context, WorkoutViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: const _LogWorkoutForm(),
      ),
    );
  }
}

class _LogWorkoutForm extends StatefulWidget {
  const _LogWorkoutForm();

  @override
  State<_LogWorkoutForm> createState() => _LogWorkoutFormState();
}

class _LogWorkoutFormState extends State<_LogWorkoutForm> {
  String? _selectedType;
  List<String> _selectedMuscles = [];
  int _duration = 45;
  int _rpe = 6;
  double _avgHR = 140;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<WorkoutViewModel>();
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      expand: false,
      builder: (_, controller) {
        return SingleChildScrollView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Log Workout',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),

              // Workout Type
              const Text('Workout Type', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WorkoutViewModel.workoutTypes.map((type) {
                  final selected = _selectedType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: selected,
                    selectedColor: AppTheme.primaryBlue,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => _selectedType = type),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Duration
              _SliderSection(
                label: 'Duration',
                value: _duration.toDouble(),
                min: 10,
                max: 180,
                displayValue: '$_duration min',
                onChanged: (v) => setState(() => _duration = v.round()),
              ),

              // Average HR
              _SliderSection(
                label: 'Avg Heart Rate',
                value: _avgHR,
                min: 60,
                max: 200,
                displayValue: '${_avgHR.round()} bpm',
                onChanged: (v) => setState(() => _avgHR = v),
              ),

              // RPE
              _SliderSection(
                label: 'Effort (RPE)',
                value: _rpe.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                displayValue: '$_rpe / 10',
                onChanged: (v) => setState(() => _rpe = v.round()),
              ),

              const SizedBox(height: 16),

              // Muscle Groups
              const Text('Muscles Worked', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WorkoutViewModel.muscleGroups.map((m) {
                  final selected = _selectedMuscles.contains(m);
                  return FilterChip(
                    label: Text(m),
                    selected: selected,
                    selectedColor: AppTheme.accentGreen,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() {
                      selected
                          ? _selectedMuscles.remove(m)
                          : _selectedMuscles.add(m);
                    }),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _selectedType == null || _isSaving ? null : () async {
                    setState(() => _isSaving = true);
                    await vm.logManualWorkout(
                      workoutType: _selectedType!,
                      durationMinutes: _duration,
                      avgHeartRate: _avgHR,
                      maxHeartRate: _avgHR + 20,
                      calories: _duration * 8.5,
                      muscleGroups: _selectedMuscles,
                      perceivedExertion: _rpe,
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  child: _isSaving
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : const Text('Save Workout'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliderSection extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderSection({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(displayValue,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions ?? (max - min).round(),
          activeColor: AppTheme.primaryBlue,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  final dynamic session;
  const _WorkoutTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(CupertinoIcons.flame_fill,
                  color: AppTheme.primaryBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.workoutType,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(
                    '${session.durationMinutes} min · ${session.muscleGroupsWorked.join(", ")}',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Fatigue',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  '${session.fatigueScore.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: session.fatigueScore > 70
                        ? AppTheme.recoveryLow
                        : session.fatigueScore > 40
                            ? AppTheme.recoveryMid
                            : AppTheme.accentGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.flame, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No workouts logged yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Log your first workout to start tracking recovery',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          TextButton(
              onPressed: onTap, child: const Text('Log Workout Now')),
        ],
      ),
    );
  }
}
