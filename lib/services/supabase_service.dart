import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/subtitle_file.dart';
import '../models/qc_log.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Auth
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // User Profile
  Future<UserModel?> getUserProfile(String id) async {
    final response = await _client.from('users').select().eq('id', id).single();
    return UserModel.fromJson(response);
  }

  // Subtitle Files
  Stream<List<SubtitleFile>> getSubtitleFiles() {
    return _client
        .from('subtitle_files')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => SubtitleFile.fromJson(json)).toList());
  }

  Future<void> updateSubtitleFile(String id, Map<String, dynamic> updates) async {
    await _client.from('subtitle_files').update(updates).eq('id', id);
  }

  Future<void> insertSubtitleFile(Map<String, dynamic> newFile) async {
    await _client.from('subtitle_files').insert(newFile);
  }

  // QC Logs
  Stream<List<QCLog>> getQCLogsForFile(String subtitleFileId) {
    return _client
        .from('qc_logs')
        .stream(primaryKey: ['id'])
        .eq('subtitle_file_id', subtitleFileId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => QCLog.fromJson(json)).toList());
  }

  Future<void> insertQCLog(Map<String, dynamic> newLog) async {
    await _client.from('qc_logs').insert(newLog);
  }

  // Attendance
  Stream<List<Attendance>> getAttendanceForUser(String userId) {
    return _client
        .from('attendance')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('date', ascending: false)
        .map((data) => data.map((json) => Attendance.fromJson(json)).toList());
  }

  Future<void> upsertAttendance(Map<String, dynamic> attendanceData) async {
    await _client.from('attendance').upsert(attendanceData, onConflict: 'user_id,date');
  }

  // Realtime Subscriptions (generic)
  RealtimeChannel subscribeToTable(String table, Function(dynamic) onUpdate) {
    final channel = _client.channel('public:$table');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      callback: (payload) => onUpdate(payload),
    ).subscribe();
    return channel;
  }

  Future<void> unsubscribeFromChannel(RealtimeChannel channel) async {
    await channel.unsubscribe();
  }
}
