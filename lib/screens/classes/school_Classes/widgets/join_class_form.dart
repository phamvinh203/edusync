import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_bloc.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_event.dart';
import 'package:edusync/repositories/class_repository.dart';

class JoinClassForm extends StatefulWidget {
  final VoidCallback? onSuccess;

  const JoinClassForm({this.onSuccess, super.key});

  @override
  State<JoinClassForm> createState() => _JoinClassFormState();
}

class _JoinClassFormState extends State<JoinClassForm> {
  final TextEditingController _codeController = TextEditingController();
  bool _isJoining = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập mã lớp học');
      return;
    }

    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<ClassRepository>();
      final resp = await repo.joinClassByCode(code);
      if (!mounted) return;

      if (resp.success) {
        _codeController.clear();

        // Notify registered classes bloc to refresh list
        try {
          context.read<RegisteredClassesBloc>().add(
            RefreshRegisteredClassesEvent(),
          );
        } catch (_) {
          // ignore: no-op if bloc not provided by ancestor
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resp.message.isEmpty
                  ? 'Tham gia lớp học thành công'
                  : resp.message,
            ),
            backgroundColor: Colors.green,
          ),
        );

        widget.onSuccess?.call();
      } else {
        setState(() => _errorMessage = resp.message);
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      setState(() => _errorMessage = message);
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _codeController,
          textCapitalization: TextCapitalization.characters,
          enabled: !_isJoining,
          decoration: InputDecoration(
            labelText: 'Mã lớp học',
            hintText: 'Ví dụ: 5LG9HA',
            prefixIcon: const Icon(Icons.vpn_key),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            errorText: _errorMessage,
          ),
          onSubmitted: (_) => _join(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton.icon(
            onPressed: _isJoining ? null : _join,
            icon:
                _isJoining
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.login),
            label: Text(_isJoining ? 'Đang tham gia...' : 'Tham gia'),
          ),
        ),
      ],
    );
  }
}
