import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../themes/app_theme.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: userProfile.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          
          switch (user.role) {
            case UserRole.admin:
              return _AdminDashboard(user: user);
            case UserRole.qc:
              return _QCDashboard(user: user);
            case UserRole.editor:
              return _EditorDashboard(user: user);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AdminDashboard extends StatelessWidget {
  final UserModel user;
  const _AdminDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, ${user.name}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: const [
              StatCard(title: 'Total Files', value: '1,240', icon: Icons.file_copy, color: Colors.blue),
              StatCard(title: 'Active Editors', value: '12', icon: Icons.people, color: Colors.green),
              StatCard(title: 'QC Pending', value: '45', icon: Icons.pending_actions, color: Colors.orange),
              StatCard(title: 'Accuracy', value: '98.5%', icon: Icons.check_circle, color: AppTheme.primaryColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditorDashboard extends StatelessWidget {
  final UserModel user;
  const _EditorDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Editor Dashboard Content'));
  }
}

class _QCDashboard extends StatelessWidget {
  final UserModel user;
  const _QCDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('QC Dashboard Content'));
  }
}
