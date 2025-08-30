import 'package:flutter/material.dart';

/// Màn hình Lớp học (tab 2)
class ClassScreen extends StatelessWidget {
	const ClassScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Text(
				'Lớp học',
				style: Theme.of(context).textTheme.headlineSmall,
			),
		);
	}
}
