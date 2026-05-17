import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user_model.dart';
import '../models/subtitle_file.dart';
import '../models/qc_log.dart';
import '../providers/auth_provider.dart';
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: const [
                StatCard(title: 'Pending Reviews', value: '15', icon: Icons.pending_actions, color: Colors.orange),
                StatCard(title: 'Rejected Files', value: '3', icon: Icons.cancel, color: AppTheme.primaryColor),
                StatCard(title: 'Avg. Error Rate', value: '2.5%', icon: Icons.bug_report, color: Colors.blueGrey),
                StatCard(title: 'QC Performance', value: 'Excellent', icon: Icons.star, color: Colors.amber),
              ],
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
                        subtitle: Text('Editor: ${file.assignedEditor} - Submitted: ${file.submissionDate?.toLocal().toString().split(' ')[0]}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () {
                                // Simulate approval
                                ref.read(subtitleFileNotifierProvider.notifier).updateSubtitleFileStatus(file.id, FileStatus.approved);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                // Simulate rejection (add QC notes and missed errors)
                                ref.read(subtitleFileNotifierProvider.notifier).updateSubtitleFileStatus(file.id, FileStatus.rejected);
                                // Example QC log entry
                                ref.read(subtitleFileNotifierProvider.notifier).addQCLog(
                                  QCLog(
                                    id: '', // Supabase will generate
                                    subtitleFileId: file.id,
                                    qcUser: user.id,
                                    lineNumber: 10,
                                    errorType: 'Formatting',
                                    correctionNote: 'Incorrect subtitle format on line 10',
                                    createdAt: DateTime.now(),
                                  ),
                                );
                              },
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
}
