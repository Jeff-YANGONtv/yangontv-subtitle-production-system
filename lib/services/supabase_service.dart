import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/subtitle_file.dart';

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
        .order('created_at')
        .map((data) => data.map((json) => SubtitleFile.fromJson(json)).toList());
  }

  Future<void> updateSubtitleFile(String id, Map<String, dynamic> updates) async {
    await _client.from('subtitle_files').update(updates).eq('id', id);
  }

  // Realtime Subscriptions
  void subscribeToUpdates(String table, Function(dynamic) onUpdate) {
    _client.channel('public:$table').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      callback: (payload) => onUpdate(payload),
    ).subscribe();
  }
}
