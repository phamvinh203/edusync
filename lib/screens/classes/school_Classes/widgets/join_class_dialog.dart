import 'package:flutter/material.dart';
import 'package:edusync/l10n/app_localizations.dart';
import 'join_class_form.dart';

class JoinClassDialog extends StatelessWidget {
  const JoinClassDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.qr_code_2, color: Colors.blue),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.enterClassCode),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.enterClassCodeDescription,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // Use the reusable form. When successful, close the dialog.
          JoinClassForm(onSuccess: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}
