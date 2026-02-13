import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:impactguide/auth/auth_manager.dart';
import 'package:impactguide/models/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService extends AuthManager with EmailSignInManager {
  SupabaseAuthService._();
  static final SupabaseAuthService instance = SupabaseAuthService._();

  static bool _supabaseInitialized = false;

  /// Set during app bootstrap (see `main.dart`).
  static void setSupabaseInitialized(bool value) => _supabaseInitialized = value;

  bool get isReady => _supabaseInitialized;

  GoTrueClient get _auth {
    if (!_supabaseInitialized) {
      throw StateError('SupabaseAuthService used before Supabase.initialize');
    }
    return Supabase.instance.client.auth;
  }

  AppAuthUser? _mapUser(User? u) {
    if (u == null) return null;
    final verifiedAt = u.emailConfirmedAt;
    return AppAuthUser(id: u.id, email: u.email, isEmailVerified: verifiedAt != null);
  }

  @override
  AppAuthUser? get currentUser {
    if (!isReady) return null;
    return _mapUser(_auth.currentUser);
  }

  @override
  Stream<AppAuthUser?> authStateChanges() {
    if (!isReady) return Stream.value(null);
    return _auth.onAuthStateChange.map((event) => _mapUser(event.session?.user));
  }

  @override
  Future<AppAuthUser?> signInWithEmail(BuildContext context, String email, String password) async {
    if (!isReady) {
      _showError(context, 'Supabase is not configured yet. Open the Supabase module and finish setup.');
      return null;
    }
    try {
      final res = await _auth.signInWithPassword(email: email.trim(), password: password);
      return _mapUser(res.user);
    } on AuthException catch (e) {
      debugPrint('Supabase signInWithEmail failed: ${e.message}');
      _showError(context, e.message);
      return null;
    } catch (e) {
      debugPrint('Supabase signInWithEmail failed: $e');
      _showError(context, 'Sign in failed. Please try again.');
      return null;
    }
  }

  @override
  Future<AppAuthUser?> createAccountWithEmail(BuildContext context, String email, String password) async {
    if (!isReady) {
      _showError(context, 'Supabase is not configured yet. Open the Supabase module and finish setup.');
      return null;
    }
    try {
      final res = await _auth.signUp(email: email.trim(), password: password);
      final user = _mapUser(res.user);
      if (user != null && !user.isEmailVerified) {
        _showInfo(context, 'Check your email to confirm your account.');
      }
      return user;
    } on AuthException catch (e) {
      debugPrint('Supabase createAccountWithEmail failed: ${e.message}');
      _showError(context, e.message);
      return null;
    } catch (e) {
      debugPrint('Supabase createAccountWithEmail failed: $e');
      _showError(context, 'Account creation failed. Please try again.');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    if (!isReady) return;
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Supabase signOut failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({required String email, required BuildContext context}) async {
    if (!isReady) {
      _showError(context, 'Supabase is not configured yet. Open the Supabase module and finish setup.');
      return;
    }
    try {
      await _auth.resetPasswordForEmail(email.trim());
      _showInfo(context, 'Password reset email sent (if the account exists).');
    } on AuthException catch (e) {
      debugPrint('Supabase resetPassword failed: ${e.message}');
      _showError(context, e.message);
    } catch (e) {
      debugPrint('Supabase resetPassword failed: $e');
      _showError(context, 'Could not send reset email. Try again.');
    }
  }

  @override
  Future<void> updateEmail({required String email, required BuildContext context}) async {
    if (!isReady) {
      _showError(context, 'Supabase is not configured yet. Open the Supabase module and finish setup.');
      return;
    }
    try {
      await _auth.updateUser(UserAttributes(email: email.trim()));
      _showInfo(context, 'Check your inbox to confirm the new email.');
    } on AuthException catch (e) {
      debugPrint('Supabase updateEmail failed: ${e.message}');
      _showError(context, e.message);
    } catch (e) {
      debugPrint('Supabase updateEmail failed: $e');
      _showError(context, 'Could not update email.');
    }
  }

  @override
  Future<void> deleteUser(BuildContext context) async {
    _showError(
      context,
      'Account deletion requires a server-side endpoint (service role).',
    );
  }

  @override
  Future<void> sendEmailVerification({required BuildContext context}) async {
    if (!isReady) {
      _showError(context, 'Supabase is not configured yet. Open the Supabase module and finish setup.');
      return;
    }
    final email = _auth.currentUser?.email;
    if (email == null || email.trim().isEmpty) {
      _showError(context, 'No email is associated with this account.');
      return;
    }
    try {
      await _auth.resend(type: OtpType.signup, email: email);
      _showInfo(context, 'Verification email sent.');
    } on AuthException catch (e) {
      debugPrint('Supabase sendEmailVerification failed: ${e.message}');
      _showError(context, e.message);
    } catch (e) {
      debugPrint('Supabase sendEmailVerification failed: $e');
      _showError(context, 'Could not send verification email.');
    }
  }

  @override
  Future<AppAuthUser?> refreshUser() async {
    if (!isReady) return null;
    try {
      final res = await _auth.getUser();
      return _mapUser(res.user);
    } catch (e) {
      debugPrint('Supabase refreshUser failed: $e');
      return currentUser;
    }
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showInfo(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
