import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/data_providers.dart';
import '../themes/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/app_sidebar.dart';

class AdminDashboardScreen extends ConsumerWidget {
  final UserModel user;
  const AdminDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleFilesAsync = ref.watch(subtitleFilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      drawer: AppSidebar(user: user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user.name}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            subtitleFilesAsync.when(
              data: (files) {
                final totalFiles = files.length;
                final approvedFiles = files.where((f) => f.status == FileStatus.approved).length;
                final pendingFiles = files.where((f) => f.status == FileStatus.pending).length;
                final accuracy = totalFiles > 0 ? (approvedFiles / totalFiles * 100).toStringAsFixed(1) : '0';

                return Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        StatCard(title: 'Total Files', value: totalFiles.toString(), icon: Icons.file_copy, color: Colors.blue),
                        StatCard(title: 'Accuracy', value: '$accuracy%', icon: Icons.check_circle, color: AppTheme.primaryColor),
                        StatCard(title: 'QC Pending', value: pendingFiles.toString(), icon: Icons.pending_actions, color: Colors.orange),
                        StatCard(title: 'Monthly Cost', value: '2.4M MMK', icon: Icons.payments, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('Productivity Overview', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 3),
                                FlSpot(1, 1),
                                FlSpot(2, 4),
                                FlSpot(3, 2),
                                FlSpot(4, 5),
                                FlSpot(5, 3),
                                FlSpot(6, 4),
                              ],
                              isCurved: true,
                              color: AppTheme.primaryColor,
                              barWidth: 4,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppTheme.primaryColor.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
