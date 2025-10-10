// Widget chứa hai nút hành động dành cho học sinh.

import 'package:flutter/material.dart';
import 'package:edusync/l10n/app_localizations.dart';

class StudentActionButtonsWidget extends StatelessWidget {
  final VoidCallback onFindClasses;
  final VoidCallback onViewPending;

  const StudentActionButtonsWidget({
    super.key,
    required this.onFindClasses,
    required this.onViewPending,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onFindClasses,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.search, size: 18),
              label: Text(
                AppLocalizations.of(context)!.findTutorButton,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onViewPending,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.pending_actions, size: 18),
              label: Text(
                AppLocalizations.of(context)!.registrationApplications,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
