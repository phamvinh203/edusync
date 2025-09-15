import 'package:edusync/screens/exercises/widgets/exercise_item.dart';
import 'package:flutter/material.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/repositories/exercise_repository.dart';

class ExercisScreen extends StatefulWidget {
  final bool isTeacher;

  const ExercisScreen({super.key, this.isTeacher = false});

  @override
  State<ExercisScreen> createState() => _ExercisScreenState();
}

class _ExercisScreenState extends State<ExercisScreen>
    with SingleTickerProviderStateMixin {
  final ClassRepository _classRepo = ClassRepository();
  final ExerciseRepository _exerciseRepo = ExerciseRepository();

  late TabController _tabController;
  List<Exercise> _allExercises = [];
  List<Exercise> _ungradedExercises = [];
  List<Exercise> _gradedExercises = [];
  List<Exercise> _submittedExercises = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (widget.isTeacher) {
        // Load created exercises for teacher
        final exercises = await _exerciseRepo.getMyCreatedExercises();
        exercises.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        setState(() {
          _allExercises = exercises;
          _ungradedExercises =
              exercises
                  .where(
                    (ex) =>
                        ex.gradingStatus == 'ungraded' ||
                        ex.gradingStatus == 'partially_graded',
                  )
                  .toList();
          _gradedExercises =
              exercises
                  .where((ex) => ex.gradingStatus == 'fully_graded')
                  .toList();
          _loading = false;
        });
      } else {
        // Student logic: Load exercises from registered classes
        final classes = await _classRepo.getMyRegisteredClasses();

        final futures =
            classes
                .where((c) => (c.id ?? '').isNotEmpty)
                .map((c) => _exerciseRepo.getExercisesByClass(c.id!))
                .toList();

        final results = await Future.wait(futures);
        final merged = results.expand((r) => r).toList();
        merged.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        final submitted = await _exerciseRepo.getMySubmittedExercises();

        setState(() {
          _allExercises = merged;
          _submittedExercises = submitted;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Exercise> _getPendingExercises() {
    if (widget.isTeacher) {
      return _ungradedExercises;
    }
    // For students - exercises not submitted yet
    return _allExercises
        .where((ex) => !_submittedExercises.any((s) => s.id == ex.id))
        .toList();
  }

  List<Exercise> _getCompletedExercises() {
    if (widget.isTeacher) {
      return _gradedExercises;
    }
    // For students - submitted exercises
    return _submittedExercises;
  }

  Widget _buildList(List<Exercise> exercises) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text("Lỗi: $_error"));
    }
    if (exercises.isEmpty) {
      return const Center(child: Text("Không có bài tập"));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final ex = exercises[index];
          return ExerciseItem(
            exercise: ex,
            submitted:
                widget.isTeacher
                    ? false
                    : _submittedExercises.any((s) => s.id == ex.id),
            isTeacher: widget.isTeacher,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String pendingTabLabel = widget.isTeacher ? 'Chưa chấm' : 'Chưa làm';
    final String completedTabLabel = widget.isTeacher ? 'Đã chấm' : 'Đã nộp';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTeacher ? "Quản lý bài tập" : "Bài tập"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
          tabs: [
            const Tab(text: 'Tất cả'),
            Tab(text: pendingTabLabel),
            Tab(text: completedTabLabel),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_allExercises),
          _buildList(_getPendingExercises()),
          _buildList(_getCompletedExercises()),
        ],
      ),
    );
  }
}
