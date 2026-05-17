import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../themes/app_theme.dart';
import '../widgets/stat_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  final UserModel user;
  const AdminDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
      ),
    );
  }
}
