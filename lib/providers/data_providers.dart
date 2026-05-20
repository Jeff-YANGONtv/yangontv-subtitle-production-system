import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subtitle_file.dart';
import '../models/qc_log.dart';
import '../models/user_model.dart';
import '../models/attendance.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// Subtitle Files Provider
final subtitleFilesProvider = StreamProvider<List<SubtitleFile>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.getSubtitleFiles();
});

// QC Logs Provider for a specific subtitle file
final qcLogsProvider = StreamProvider.family<List<QCLog>, String>((ref, subtitleFileId) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.getQCLogsForFile(subtitleFileId);
});

// Attendance Provider for the current user
final attendanceProvider = StreamProvider<List<Attendance>>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);

  if (userProfile.value == null) {
    return Stream.value([]);
  }
  return supabaseService.getAttendanceForUser(userProfile.value!.id);
});

// Provider for managing subtitle file operations
final subtitleFileNotifierProvider = StateNotifierProvider<SubtitleFileNotifier, AsyncValue<void>>((ref) {
  return SubtitleFileNotifier(ref.read(supabaseServiceProvider));
});

class SubtitleFileNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseService _service;
  SubtitleFileNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> addSubtitleFile(SubtitleFile file) async {
    state = const AsyncValue.loading();
    try {
      await _service.insertSubtitleFile(file.toJson());
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSubtitleFileStatus(String fileId, FileStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateSubtitleFile(fileId, {
        'status': status.name,
        'submission_date': DateTime.now().toIso8601String(),
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addQCLog(QCLog log) async {
    state = const AsyncValue.loading();
    try {
      await _service.insertQCLog({
        'subtitle_file_id': log.subtitleFileId,
        'qc_user': log.qcUser,
        'line_number': log.lineNumber,
        'error_type': log.errorType,
        'correction_note': log.correctionNote,
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> upsertAttendance(Attendance attendance) async {
    state = const AsyncValue.loading();
    try {
      await _service.upsertAttendance(attendance.toJson());
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> upsertAttendance(Attendance attendance) async {
    await updateAttendance(attendance);
  }
}
