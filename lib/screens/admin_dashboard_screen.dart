import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import '../models/subtitle_file.dart';
import '../providers/auth_provider.dart';
import '../providers/data_providers.dart';
import '../themes/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/app_sidebar.dart';
import '../utils/salary_calculator.dart';

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
                final approvedFiles = files.where((f) => f.status == FileStatus.approved).toList();
                final pendingFiles = files.where((f) => f.status == FileStatus.pending).length;
                final accuracy = totalFiles > 0 ? (approvedFiles.length / totalFiles * 100).toStringAsFixed(1) : '0';
                
                // Calculate monthly cost based on deductions
                double totalMonthlyCost = 0;
                // Simplified logic: sum of base salaries - sum of deductions
                // In a real app, you'd fetch all users and their individual salaries
                totalMonthlyCost = (approvedFiles.length * SalaryCalculator.fileValue);

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
                        StatCard(title: 'Production Value', value: '${(totalMonthlyCost / 1000000).toStringAsFixed(1)}M MMK', icon: Icons.payments, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('Productivity Overview', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildProductivityChart(files),
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

  Widget _buildProductivityChart(List<SubtitleFile> files) {
    // Group files by day for the last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
    
    final spots = last7Days.asMap().entries.map((entry) {
      final date = entry.value;
      final count = files.where((f) => 
        f.createdAt.day == date.day && 
        f.createdAt.month == date.month && 
        f.createdAt.year == date.year
      ).length;
      return FlSpot(entry.key.toDouble(), count.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = last7Days[value.toInt()];
                return Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 4,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
