import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { client, admin, guard }

class AuthUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

class AuthService extends ChangeNotifier {
  AuthUser? _currentUser;
  bool _isLoading = false;

  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  static SupabaseClient get _sb => Supabase.instance.client;

  /// Call once at app start — restores session from secure storage.
  Future<void> restoreSession() async {
    final session = _sb.auth.currentSession;
    if (session != null) {
      await _loadProfile(session.user);
    }
    // Listen for future auth changes (token refresh, sign-out, etc.)
    _sb.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        if (data.session != null) await _loadProfile(data.session!.user);
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadProfile(User user) async {
    try {
      final row = await _sb
          .from('profiles')
          .select('name, role')
          .eq('id', user.id)
          .single();

      final role = _parseRole(row['role'] as String? ?? 'client');
      _currentUser = AuthUser(
        id: user.id,
        name: row['name'] as String? ?? user.email ?? 'User',
        email: user.email ?? '',
        role: role,
      );
    } catch (_) {
      // Profile row missing — derive from user metadata
      final meta = user.userMetadata;
      final role = _parseRole(meta?['role'] as String? ?? 'client');
      _currentUser = AuthUser(
        id: user.id,
        name: meta?['name'] as String? ?? user.email ?? 'User',
        email: user.email ?? '',
        role: role,
      );
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _sb.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (response.user != null) {
        await _loadProfile(response.user!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on AuthException catch (e) {
      debugPrint('Login error: ${e.message}');
    } catch (e) {
      debugPrint('Login error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _sb.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Create a new account (admin use / seeding)
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      await _sb.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role},
      );
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _sb.auth.resetPasswordForEmail(email.trim());
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'admin': return UserRole.admin;
      case 'guard': return UserRole.guard;
      default:      return UserRole.client;
    }
  }
}
