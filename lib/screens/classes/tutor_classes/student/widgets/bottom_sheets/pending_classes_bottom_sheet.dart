import 'package:flutter/material.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/screens/classes/tutor_classes/shared/widgets/cards/pending_class_card.dart';
import 'package:edusync/l10n/app_localizations.dart';

class PendingClassesBottomSheet extends StatelessWidget {
  const PendingClassesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.pending_actions, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.pendingClasses,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<ClassModel>>(
                  future: ClassRepository().getMyPendingClasses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${AppLocalizations.of(context)!.errorPrefix}: ${snapshot.error}',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final allPendingClasses = snapshot.data ?? [];
                    // Chỉ hiển thị các lớp học thêm (type='extra') trong tab "Lớp gia sư"
                    final pendingClasses =
                        allPendingClasses
                            .where((c) => c.type.toLowerCase() == 'extra')
                            .toList();

                    if (pendingClasses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.hourglass_empty,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.noPendingClasses,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: pendingClasses.length,
                      itemBuilder: (context, index) {
                        final classItem = pendingClasses[index];
                        return PendingClassCard(classItem: classItem);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
