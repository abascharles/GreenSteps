import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/eco_action.dart';

class EcoActionService {
  final _client = Supabase.instance.client;

  Future<List<EcoAction>> getActionsForUser(String userId) async {
    final response = await _client
        .from('actions')
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false);
    return (response as List)
        .map((item) => EcoAction.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> logAction(EcoAction action, {bool forInsert = false}) async {
    await _client.from('actions').insert(action.toMap(forInsert: forInsert));
  }
}
