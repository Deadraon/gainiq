import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../core/providers/workout_provider.dart';
import '../../models/workout_model.dart';

class LiveWorkoutScreen extends StatefulWidget {
  const LiveWorkoutScreen({super.key});

  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen>
    with TickerProviderStateMixin {
  int _seconds = 0;
  Timer? _timer;
  bool _isPlaying = true;
  int? _restSeconds;
  Timer? _restTimer;

  // Per-set weight/reps input: exerciseIndex → setIndex → {'weight', 'reps'}
  final Map<int, Map<int, Map<String, String>>> _inputs = {};
  // Completed sets: exerciseIndex → setIndex → bool
  final Map<int, Map<int, bool>> _completed = {};

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPlaying && mounted) setState(() => _seconds++);
    });
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() => _restSeconds = 90);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_restSeconds! > 0) {
          _restSeconds = _restSeconds! - 1;
        } else {
          _restTimer?.cancel();
          _restSeconds = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  double _calculateProgress(List<ExerciseModel> exercises) {
    int total = 0, done = 0;
    for (int i = 0; i < exercises.length; i++) {
      total += exercises[i].sets;
      done += (_completed[i]?.values.where((v) => v).length ?? 0);
    }
    return total == 0 ? 0 : done / total;
  }

  bool _isSetCompleted(int exIdx, int setIdx) =>
      _completed[exIdx]?[setIdx] ?? false;

  void _toggleSet(int exIdx, int setIdx) {
    setState(() {
      _completed[exIdx] ??= {};
      final current = _completed[exIdx]![setIdx] ?? false;
      _completed[exIdx]![setIdx] = !current;
      if (!current) _startRestTimer(); // start rest when marking complete
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final plan = workoutProvider.activePlan;
    final exercises = plan?.exercises ?? [];
    final progress = _calculateProgress(exercises);
    final completedSets = exercises.fold<int>(
        0, (sum, _) => sum) == 0
        ? 0
        : _completed.values.fold<int>(
            0, (sum, m) => sum + m.values.where((v) => v).length);
    final totalSets = exercises.fold<int>(0, (sum, e) => sum + e.sets);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Column(
        children: [
          // ── HEADER ──────────────────────────────────────────────────
          _buildHeader(context, plan?.title ?? 'Workout', progress),

          // ── REST TIMER BANNER ────────────────────────────────────────
          if (_restSeconds != null) _buildRestBanner(),

          // ── EXERCISE LIST ────────────────────────────────────────────
          Expanded(
            child: exercises.isEmpty
                ? const Center(
                    child: Text('No exercises found',
                        style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: exercises.length,
                    itemBuilder: (ctx, i) =>
                        _buildExerciseCard(exercises[i], i),
                  ),
          ),

          // ── BOTTOM BAR ───────────────────────────────────────────────
          _buildBottomBar(context, completedSets, totalSets),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, double progress) {
    return Container(
      color: const Color(0xFF0D0D0D),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => _confirmEnd(context),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        // Animated timer
                        ScaleTransition(
                          scale: _isPlaying ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                          child: Text(
                            _formatTime(_seconds),
                            style: const TextStyle(
                              color: Color(0xFFE5FF00),
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isPlaying = !_isPlaying),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Progress bar
            ClipRRect(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white10,
                color: const Color(0xFFE5FF00),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestBanner() {
    final pct = (_restSeconds! / 90).clamp(0.0, 1.0);
    final color = _restSeconds! > 30 ? Colors.greenAccent : Colors.redAccent;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Text('Rest Time',
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const Spacer(),
          SizedBox(
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.white10,
                color: color,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(_formatTime(_restSeconds!),
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()])),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() {
              _restTimer?.cancel();
              _restSeconds = null;
            }),
            child: Icon(Icons.close, color: color, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise, int exIdx) {
    final completedCount = _completed[exIdx]?.values.where((v) => v).length ?? 0;
    final allDone = completedCount == exercise.sets;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: allDone
              ? const Color(0xFFE5FF00).withOpacity(0.4)
              : Colors.white.withOpacity(0.06),
          width: allDone ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Exercise header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: allDone
                        ? const Color(0xFFE5FF00).withOpacity(0.15)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    allDone ? Icons.check_rounded : Icons.fitness_center_rounded,
                    color: allDone ? const Color(0xFFE5FF00) : Colors.white38,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: allDone
                                ? const Color(0xFFE5FF00)
                                : Colors.white,
                          )),
                      if (exercise.targetMuscle.isNotEmpty)
                        Text(exercise.targetMuscle,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completedCount / ${exercise.sets} sets',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const SizedBox(width: 36),
                const SizedBox(width: 12),
                Expanded(child: Text('SET', style: _headerStyle())),
                SizedBox(width: 72, child: Text('WEIGHT (kg)', style: _headerStyle(), textAlign: TextAlign.center)),
                const SizedBox(width: 8),
                SizedBox(width: 60, child: Text('REPS', style: _headerStyle(), textAlign: TextAlign.center)),
                const SizedBox(width: 44),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, color: Colors.white10),

          // Set rows
          ...List.generate(exercise.sets, (setIdx) =>
              _buildSetRow(exercise, exIdx, setIdx)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(
    color: Colors.white.withOpacity(0.3),
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  Widget _buildSetRow(ExerciseModel exercise, int exIdx, int setIdx) {
    final isDone = _isSetCompleted(exIdx, setIdx);
    _inputs[exIdx] ??= {};
    _inputs[exIdx]![setIdx] ??= {'weight': '', 'reps': ''};

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: isDone ? const Color(0xFFE5FF00).withOpacity(0.04) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Set number bubble
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFFE5FF00)
                  : Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${setIdx + 1}',
                style: TextStyle(
                  color: isDone ? Colors.black : Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Previous best
          Expanded(
            child: Text(
              'Prev: —',
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
            ),
          ),

          // Weight input
          _setInput(
            width: 72,
            hint: 'kg',
            isDone: isDone,
            onChanged: (v) => _inputs[exIdx]![setIdx]!['weight'] = v,
          ),
          const SizedBox(width: 8),

          // Reps input
          _setInput(
            width: 60,
            hint: exercise.reps,
            isDone: isDone,
            onChanged: (v) => _inputs[exIdx]![setIdx]!['reps'] = v,
          ),
          const SizedBox(width: 8),

          // Done button
          GestureDetector(
            onTap: () => _toggleSet(exIdx, setIdx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFFE5FF00)
                    : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDone
                      ? const Color(0xFFE5FF00)
                      : Colors.white.withOpacity(0.15),
                ),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : Icons.check_rounded,
                color: isDone ? Colors.black : Colors.white24,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _setInput({
    required double width,
    required String hint,
    required bool isDone,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: width,
      height: 36,
      child: TextField(
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        enabled: !isDone,
        style: TextStyle(
          color: isDone ? const Color(0xFFE5FF00) : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12),
          isDense: true,
          filled: true,
          fillColor: isDone
              ? const Color(0xFFE5FF00).withOpacity(0.08)
              : Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5FF00), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int done, int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          // Sets done
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$done / $total sets done',
                    style: const TextStyle(
                        color: Color(0xFFE5FF00),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text('Time: ${_formatTime(_seconds)}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // End button
          ElevatedButton.icon(
            onPressed: () => _confirmEnd(context),
            icon: const Icon(Icons.stop_circle_rounded, size: 18),
            label: const Text('End Workout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.85),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmEnd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('End Workout?',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text('Time: ${_formatTime(_seconds)}',
                style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Continue', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('End', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
