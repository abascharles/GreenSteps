import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Future<void> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) {
      final error =
          response.session?.user.identities?.firstOrNull?.identityData != null
          ? response.session!.user.identities!.first.identityData!['error']
          : null;
      throw Exception(error ?? 'Login failed');
    }
  }

  Future<void> signUp(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user == null) {
      final error =
          response.session?.user.identities?.firstOrNull?.identityData != null
          ? response.session!.user.identities!.first.identityData!['error']
          : null;
      throw Exception(error ?? 'Signup failed');
    }
  }

  Future<void> signInWithGoogle() async {
    final res = await _client.auth.signInWithOAuth(
      Provider.google,
      redirectTo: null, // You can set a redirect URL for web
    );
  }
}
