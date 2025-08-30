import 'package:flutter/material.dart';

/// Màn hình Bài tập (tab 3)
class ExercisScreen extends StatelessWidget {
	const ExercisScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Text(
				'Bài tập',
				style: Theme.of(context).textTheme.headlineSmall,
			),
		);
	}
}
