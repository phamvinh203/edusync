import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_event.dart';
import 'package:edusync/blocs/exercise/exercise_state.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:edusync/screens/exercises/teacher/create_exercise_screen.dart';
import 'package:edusync/screens/exercises/exercise_detail_screen.dart';
import 'package:edusync/l10n/app_localizations.dart';

class ExercisesTab extends StatefulWidget {
  final String classId;
  final bool isTeacher;
  final String role; // Thêm thuộc tính role

  const ExercisesTab({
    super.key,
    required this.classId,
    this.isTeacher = false,
    required this.role,
  });

  @override
  State<ExercisesTab> createState() => _ExercisesTabState();
}

class _ExercisesTabState extends State<ExercisesTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animController;
  // Cache the list so it persists across navigation
  List<Exercise> _cachedItems = const [];

  @override
  bool get wantKeepAlive => true; // keep this tab alive across tab switches

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<ExerciseBloc>();
      final current = bloc.state;
      // If bloc already has list, prime the cache and skip re-fetch
      if (current is ExercisesLoaded && current.items.isNotEmpty) {
        _cachedItems = current.items;
        return;
      }
      // Only fetch if cache is empty and bloc has not loaded yet
      if (_cachedItems.isEmpty) {
        bloc.add(LoadExercisesByClassEvent(widget.classId));
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    context.read<ExerciseBloc>().add(
      RefreshExercisesByClassEvent(widget.classId),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return SizedBox.expand(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: BlocConsumer<ExerciseBloc, ExerciseState>(
                  listenWhen: (prev, curr) => curr is ExercisesLoaded,
                  listener: (context, state) {
                    if (state is ExercisesLoaded) {
                      _cachedItems = state.items;
                    }
                  },
                  buildWhen: (prev, curr) {
                    // Only rebuild the list UI when list is loading or loaded
                    return curr is ExercisesLoading ||
                        curr is ExercisesLoaded ||
                        curr is ExerciseError;
                  },
                  builder: (context, state) {
                    // Show loading only if we have no cache
                    if (state is ExercisesLoading && _cachedItems.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ExerciseError && _cachedItems.isEmpty) {
                      return Center(child: Text(state.message));
                    }

                    final items =
                        state is ExercisesLoaded ? state.items : _cachedItems;

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0.2, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        );
                        return SlideTransition(
                          position: offsetAnimation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child:
                          items.isEmpty
                              ? RefreshIndicator(
                                key: const ValueKey('empty'),
                                onRefresh: _refresh,
                                child: ListView(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 36,
                                  ),
                                  children: [
                                    const SizedBox(height: 40),
                                    Icon(
                                      Icons.assignment_outlined,
                                      size: 88,
                                      color: Colors.grey[350],
                                    ),
                                    const SizedBox(height: 20),
                                    Center(
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.noExercises,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    if (widget.isTeacher)
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.createExerciseFeatureInDevelopment,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                              : RefreshIndicator(
                                key: const ValueKey('list'),
                                onRefresh: _refresh,
                                child: ListView.builder(
                                  key: PageStorageKey(
                                    'exercises_${widget.classId}',
                                  ),
                                  itemCount: items.length,
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    12,
                                    12,
                                    96,
                                  ), // chừa chỗ cho FAB
                                  itemBuilder: (context, index) {
                                    final ex = items[index];
                                    return _buildExerciseCard(ex);
                                  },
                                ),
                              ),
                    );
                  },
                ),
              ),
            ],
          ),

          if (widget.isTeacher)
            Positioned(
              right: 16,
              bottom: 18,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  final created = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => CreateExerciseScreen(classId: widget.classId),
                    ),
                  );
                  if (!mounted) return;
                  if (created != null) {
                    _refresh();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.createExerciseSuccess,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.createExerciseButton),
              ),
            ),
        ],
      ),
    );
  }

  // ----------------- Card -----------------

  Widget _buildExerciseCard(Exercise ex) {
    final borderColor = _borderColorForStatus(ex.status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0.6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor.withOpacity(0.18)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final id = ex.id;
          if (id == null) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider(
                    create: (_) => ExerciseBloc(),
                    child: ExerciseDetailScreen(
                      classId: widget.classId,
                      exerciseId: id,
                      role: widget.role,
                    ),
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Icon(
                  _iconForType(ex.type),
                  size: 34,
                  color: Theme.of(context).colorScheme.primary,
                ),
                // Thumbnail nhỏ nếu có attachment
                if (ex.attachments.isNotEmpty)
                  const Positioned(
                    right: -2,
                    bottom: -2,
                    child: Icon(Icons.attachment, size: 16, color: Colors.grey),
                  ),
              ],
            ),
            title: Text(
              ex.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ex.description?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      ex.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: -6,
                  children: [
                    _chip(_typeLabel(ex.type), _typeColor(ex.type)),
                    _chip(
                      'Hạn: ${_formatDate(ex.dueDate)}',
                      _deadlineColor(ex.dueDate),
                    ),
                    _statusChip(ex.status),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }

  // ----------------- Helpers -----------------

  IconData _iconForType(String type) {
    switch (type) {
      case 'multiple_choice':
        return Icons.quiz;
      case 'file_upload':
        return Icons.attach_file;
      default:
        return Icons.description;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Trắc nghiệm';
      case 'file_upload':
        return 'Nộp file';
      case 'essay':
      default:
        return 'Tự luận';
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'multiple_choice':
        return Colors.purple;
      case 'file_upload':
        return Colors.indigo;
      default:
        return Colors.green;
    }
  }

  Color _deadlineColor(DateTime dt) {
    final now = DateTime.now().toUtc();
    return dt.toUtc().isBefore(now) ? Colors.red : Colors.orange;
  }

  Color _borderColorForStatus(String status) {
    final s = status.toLowerCase();
    if (s == 'closed') {
      return Colors.grey;
    } else if (s == 'graded') {
      return Colors.blueGrey;
    } else {
      return Colors.green;
    }
  }

  Widget _chip(String text, Color color) {
    final hsl = HSLColor.fromColor(color);
    final darker =
        hsl.withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0)).toColor();

    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(color: color.withOpacity(0.28)),
      labelStyle: TextStyle(color: darker, fontSize: 13),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase();
    Color color;
    String label;
    if (s == 'closed') {
      color = Colors.grey;
      label = 'Đã đóng';
    } else if (s == 'graded') {
      color = Colors.blueGrey;
      label = 'Đã chấm';
    } else {
      color = Colors.green;
      label = 'Đang mở';
    }
    return _chip(label, color);
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}
