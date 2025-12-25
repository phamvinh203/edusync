import 'package:flutter/material.dart';
import 'package:edusync/l10n/app_localizations.dart';

class QuickInfoCard extends StatelessWidget {
  final String userClass;
  final String userSchool;
  final int classCount;
  final String classLabel;
  final String userRole;
  final VoidCallback? onCreateClass; // callback khi bấm nút "Tạo lớp"

  const QuickInfoCard({
    super.key,
    required this.userClass,
    required this.userSchool,
    required this.classCount,
    required this.classLabel,
    required this.userRole,
    this.onCreateClass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Thông tin lớp hoc
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context)!.classInfo}: $userClass',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.of(context)!.schoolInfo}: $userSchool',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildCardClass(
                    context,
                    '0 ${AppLocalizations.of(context)!.subjects}',
                    Icons.book,
                  ),
                  _buildCardClass(
                    context,
                    '$classCount $classLabel',
                    Icons.school,
                  ),
                ],
              ),
            ],
          ),

          // Nút "Tạo lớp" chỉ hiện nếu là giáo viên
          if (userRole.toLowerCase() == 'teacher' && onCreateClass != null)
            Positioned(
              top: 0,
              right: 0,
              child: Tooltip(
                message: AppLocalizations.of(context)!.createNewClass,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: onCreateClass,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardClass(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
