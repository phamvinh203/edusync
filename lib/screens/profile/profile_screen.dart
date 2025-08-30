import 'package:flutter/material.dart';

/// Màn hình Cá nhân (tab 4)
class ProfileScreen extends StatelessWidget {
	const ProfileScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Text(
				'Cá nhân',
				style: Theme.of(context).textTheme.headlineSmall,
			),
		);
	}
}
