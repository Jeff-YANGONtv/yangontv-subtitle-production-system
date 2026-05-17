import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'admin_dashboard_screen.dart';
import 'editor_dashboard_screen.dart';
import 'qc_dashboard_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return userProfile.when(
      data: (user) {
        if (user == null) return const Center(child: Text('User not found'));
        
        switch (user.role) {
          case UserRole.admin:
            return AdminDashboardScreen(user: user);
          case UserRole.qc:
            return QCDashboardScreen(user: user);
          case UserRole.editor:
            return EditorDashboardScreen(user: user);
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
