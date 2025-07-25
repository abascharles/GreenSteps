import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await Supabase.instance.client
          .from('leaderboard')
          .select()
          .limit(20)
          .order('score', ascending: false);
      setState(() {
        _users = List<Map<String, dynamic>>.from(response as List);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildTrophy(int index) {
    if (index == 0) {
      return const Icon(Icons.emoji_events, color: Colors.amber, size: 32);
    } else if (index == 1) {
      return const Icon(Icons.emoji_events, color: Colors.grey, size: 28);
    } else if (index == 2) {
      return const Icon(Icons.emoji_events, color: Colors.brown, size: 24);
    }
    return const SizedBox(width: 32);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : RefreshIndicator(
              onRefresh: _fetchLeaderboard,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    leading: _buildTrophy(index),
                    title: Text(
                      (user['username'] != null &&
                              user['username'].toString().trim().isNotEmpty)
                          ? user['username']
                          : (user['email'] ?? 'Unknown'),
                    ),
                    subtitle: Text(user['id'].toString()),
                    trailing: Text(
                      user['score']?.toString() ?? '0',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    // Optionally show avatar if avatar_url exists
                    // leading: user['avatar_url'] != null ? CircleAvatar(backgroundImage: NetworkImage(user['avatar_url'])) : null,
                  );
                },
              ),
            ),
    );
  }
}
