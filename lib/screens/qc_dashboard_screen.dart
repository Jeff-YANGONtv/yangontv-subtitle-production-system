import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/subtitle_file.dart';
import '../models/qc_log.dart';
import '../providers/data_providers.dart';
import '../themes/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/app_sidebar.dart';

class QCDashboardScreen extends ConsumerWidget {
  final UserModel user;
  const QCDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleFilesAsync = ref.watch(subtitleFilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QC Dashboard'),
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
                final pendingReviews = files.where((f) => f.status == FileStatus.pending).length;
                final rejectedFiles = files.where((f) => f.status == FileStatus.rejected).length;
                final totalFiles = files.length;
                final errorRate = totalFiles > 0 ? (rejectedFiles / totalFiles * 100).toStringAsFixed(1) : '0';

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    StatCard(title: 'Pending Reviews', value: pendingReviews.toString(), icon: Icons.pending_actions, color: Colors.orange),
                    StatCard(title: 'Rejected Files', value: rejectedFiles.toString(), icon: Icons.cancel, color: AppTheme.primaryColor),
                    StatCard(title: 'Rejection Rate', value: '$errorRate%', icon: Icons.bug_report, color: Colors.blueGrey),
                    StatCard(title: 'QC Performance', value: 'Active', icon: Icons.star, color: Colors.amber),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => const Text('Error loading stats'),
            ),
            const SizedBox(height: 24),
            Text('Files for Review', style: Theme.of(context).textTheme.titleLarge),
            subtitleFilesAsync.when(
              data: (files) {
                final pendingReviewFiles = files.where((file) => file.status == FileStatus.pending).toList();
                if (pendingReviewFiles.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No files pending review.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingReviewFiles.length,
                  itemBuilder: (context, index) {
                    final file = pendingReviewFiles[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(file.fileName),
                        subtitle: Text('Submitted: ${file.submissionDate?.toLocal().toString().split(' ')[0]}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => _showApprovalDialog(context, ref, file),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => _showRejectionDialog(context, ref, file),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error loading files: $e'),
            ),
          ],
        ),
      ),
    );
  }

  void _showApprovalDialog(BuildContext context, WidgetRef ref, SubtitleFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve File'),
        content: Text('Are you sure you want to approve "${file.fileName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(subtitleFileNotifierProvider.notifier).updateSubtitleFileStatus(file.id, FileStatus.approved);
              Navigator.pop(context);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context, WidgetRef ref, SubtitleFile file) {
    final noteController = TextEditingController();
    final errorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: errorController,
              decoration: const InputDecoration(labelText: 'Number of Missed Errors'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'QC Notes'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final missedErrors = int.tryParse(errorController.text) ?? 0;
              ref.read(subtitleFileNotifierProvider.notifier).updateSubtitleFileStatus(file.id, FileStatus.rejected);
              // In a real scenario, we'd also update missed_errors and qc_notes in the file record
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
