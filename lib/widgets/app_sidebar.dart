import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../themes/app_theme.dart';

class AppSidebar extends ConsumerWidget {
  final UserModel user;
  const AppSidebar({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.cardColor),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(user.name[0], style: const TextStyle(fontSize: 24, color: Colors.white)),
            ),
            accountName: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user.email, style: const TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          if (user.role == UserRole.admin) ...[
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('User Management'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Reports'),
              onTap: () {},
            ),
          ],
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.primaryColor),
            title: const Text('Logout', style: TextStyle(color: AppTheme.primaryColor)),
            onTap: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
