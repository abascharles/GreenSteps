import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/eco_action_service.dart';
import '../models/eco_action.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _email;
  String? _avatarUrl;
  double _totalCO2 = 0;
  int _totalActions = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Not signed in.';
          _isLoading = false;
        });
        return;
      }
      final userResp = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      _email = userResp['email'] as String?;
      _avatarUrl = userResp['avatar_url'] as String?;
      _usernameController.text = userResp['username'] ?? '';
      _locationController.text = userResp['location'] ?? '';
      // Fetch stats
      final ecoActions = await EcoActionService().getActionsForUser(user.id);
      _totalCO2 = ecoActions.fold(0, (sum, a) => sum + a.co2Saved);
      _totalActions = ecoActions.length;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Not signed in.';
          _isSaving = false;
        });
        return;
      }
      await Supabase.instance.client
          .from('users')
          .update({
            'username': _usernameController.text.trim(),
            'location': _locationController.text.trim(),
          })
          .eq('id', user.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        _avatarUrl != null && _avatarUrl!.isNotEmpty
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: _avatarUrl == null || _avatarUrl!.isEmpty
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _email ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter a username'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            child: _isSaving
                                ? const CircularProgressIndicator()
                                : const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            _totalActions.toString(),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Text('Actions'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            _totalCO2.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Text('CO₂ Saved (kg)'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
