import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

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
    final Color accentGreen = AppTheme.accentGreen;
    final double borderRadius = AppTheme.borderRadius;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(
                _error!,
                style: GoogleFonts.nunito(color: Colors.red),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchLeaderboard,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: _buildTrophy(index),
                      title: Text(
                        (user['username'] != null &&
                                user['username'].toString().trim().isNotEmpty)
                            ? user['username']
                            : (user['email'] ?? 'Unknown'),
                        style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        user['id'].toString(),
                        style: GoogleFonts.nunito(),
                      ),
                      trailing: Text(
                        user['score']?.toString() ?? '0',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          color: accentGreen,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
