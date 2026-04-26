import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/services/workout_generator.dart';
import '../../models/workout_model.dart';

class EditWorkoutScreen extends StatefulWidget {
  final WorkoutPlanModel plan;
  const EditWorkoutScreen({super.key, required this.plan});

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  late List<ExerciseModel> _exercises;
  late TextEditingController _titleController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.plan.exercises);
    _titleController = TextEditingController(text: widget.plan.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updated = widget.plan.copyWith(
        title: _titleController.text.trim().isEmpty
            ? widget.plan.title
            : _titleController.text.trim(),
        exercises: _exercises,
      );
      await context.read<WorkoutProvider>().updatePlan(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Workout saved!'),
            backgroundColor: Color(0xFF2E3800),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red[900]),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addExercise(ExerciseModel ex) {
    setState(() {
      _exercises.add(ExerciseModel(
        id: '${ex.id}_${DateTime.now().millisecondsSinceEpoch}',
        name: ex.name,
        sets: ex.sets,
        reps: ex.reps,
        targetMuscle: ex.targetMuscle,
      ));
    });
  }

  void _removeExercise(int index) {
    setState(() => _exercises.removeAt(index));
  }

  void _editExercise(int index) {
    final ex = _exercises[index];
    final setsCtrl = TextEditingController(text: '${ex.sets}');
    final repsCtrl = TextEditingController(text: ex.reps);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(ex.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(ex.targetMuscle,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _editField(setsCtrl, 'Sets', TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _editField(repsCtrl, 'Reps (e.g. 8-12)', TextInputType.text),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _exercises[index] = ex.copyWith(
                      sets: int.tryParse(setsCtrl.text) ?? ex.sets,
                      reps: repsCtrl.text.isEmpty ? ex.reps : repsCtrl.text,
                    );
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5FF00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Update Exercise', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _editField(TextEditingController ctrl, String label, TextInputType type) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1F1F1F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5FF00)),
        ),
      ),
    );
  }

  void _showAddExerciseSheet() {
    // Flatten all exercises from the DB (gym + home)
    final allExercises = <ExerciseModel>[];
    final db = ExerciseDB.gym;
    for (final entry in db.entries) {
      for (final ex in entry.value) {
        allExercises.add(ExerciseModel(
          id: '${entry.key}_${ex['name']!.replaceAll(' ', '_').toLowerCase()}',
          name: ex['name']!,
          sets: 3,
          reps: ex['reps']!,
          targetMuscle: ex['muscle']!,
        ));
      }
    }

    String _search = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filtered = allExercises
              .where((e) =>
                  e.name.toLowerCase().contains(_search.toLowerCase()) ||
                  e.targetMuscle.toLowerCase().contains(_search.toLowerCase()))
              .toList();

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    children: [
                      Container(width: 36, height: 4,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 14),
                      const Text('Add Exercise',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (v) => setModalState(() => _search = v),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search exercise or muscle...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.search, color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF1F1F1F),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final ex = filtered[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5FF00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.fitness_center_rounded,
                              color: Color(0xFFE5FF00), size: 18),
                        ),
                        title: Text(ex.name,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(ex.targetMuscle,
                            style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        trailing: Text(ex.reps,
                            style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        onTap: () {
                          _addExercise(ex);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ ${ex.name} added'),
                              backgroundColor: const Color(0xFF2E3800),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _titleController,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Workout Name',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE5FF00)))
                : const Text('SAVE',
                    style: TextStyle(color: Color(0xFFE5FF00), fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Info bar ─────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white38, size: 16),
                const SizedBox(width: 8),
                Text('${_exercises.length} exercises  •  Drag to reorder  •  Swipe to delete',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Exercise list (reorderable) ───────────────
          Expanded(
            child: _exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center_rounded, color: Colors.white12, size: 60),
                        const SizedBox(height: 12),
                        Text('No exercises yet',
                            style: TextStyle(color: Colors.white.withOpacity(0.3))),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _showAddExerciseSheet,
                          child: const Text('+ Add Exercise',
                              style: TextStyle(color: Color(0xFFE5FF00))),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _exercises.length,
                    onReorder: (oldIdx, newIdx) {
                      setState(() {
                        if (newIdx > oldIdx) newIdx--;
                        final item = _exercises.removeAt(oldIdx);
                        _exercises.insert(newIdx, item);
                      });
                    },
                    itemBuilder: (_, i) {
                      final ex = _exercises[i];
                      return _ExerciseEditTile(
                        key: ValueKey(ex.id + i.toString()),
                        exercise: ex,
                        index: i,
                        onEdit: () => _editExercise(i),
                        onDelete: () => _removeExercise(i),
                      );
                    },
                  ),
          ),

          // ── Add Exercise button ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showAddExerciseSheet,
                icon: const Icon(Icons.add_rounded, color: Color(0xFFE5FF00)),
                label: const Text('Add Exercise',
                    style: TextStyle(color: Color(0xFFE5FF00), fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5FF00), width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// EXERCISE EDIT TILE
// ─────────────────────────────────────────────────────────────
class _ExerciseEditTile extends StatelessWidget {
  final ExerciseModel exercise;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseEditTile({
    super.key,
    required this.exercise,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(exercise.id + index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
            SizedBox(width: 6),
            Text('Remove', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: ReorderableDragStartListener(
            index: index,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.drag_handle_rounded, color: Colors.white38, size: 20),
            ),
          ),
          title: Text(exercise.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text('${exercise.sets} sets  ×  ${exercise.reps} reps  •  ${exercise.targetMuscle}',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
          trailing: GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE5FF00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5FF00).withOpacity(0.3)),
              ),
              child: const Text('Edit',
                  style: TextStyle(color: Color(0xFFE5FF00), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
