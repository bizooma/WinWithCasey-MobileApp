// Authentication Manager - Base interface for auth implementations
//
// This abstract class and mixins define the contract for authentication systems.
// Implement this with concrete classes for Firebase, Supabase, or local auth.
//
// Usage:
// 1. Create a concrete class extending AuthManager
// 2. Mix in the required authentication provider mixins
// 3. Implement all abstract methods with your auth provider logic

import 'package:flutter/material.dart';

import 'package:impactguide/models/auth_user.dart';

// Core authentication operations that all auth implementations must provide
abstract class AuthManager {
  AppAuthUser? get currentUser;
  Stream<AppAuthUser?> authStateChanges();

  Future<void> signOut();
  Future<void> deleteUser(BuildContext context);
  Future<void> updateEmail({required String email, required BuildContext context});
  Future<void> resetPassword({required String email, required BuildContext context});
  Future<void> sendEmailVerification({required BuildContext context});
  Future<AppAuthUser?> refreshUser();
}

// Email/password authentication mixin
mixin EmailSignInManager on AuthManager {
  Future<AppAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  );

  Future<AppAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  );
}

// Anonymous authentication for guest users
mixin AnonymousSignInManager on AuthManager {
  Future<AppAuthUser?> signInAnonymously(BuildContext context);
}

// Apple Sign-In authentication (iOS/web)
mixin AppleSignInManager on AuthManager {
  Future<AppAuthUser?> signInWithApple(BuildContext context);
}

// Google Sign-In authentication (all platforms)
mixin GoogleSignInManager on AuthManager {
  Future<AppAuthUser?> signInWithGoogle(BuildContext context);
}

// JWT token authentication for custom backends
mixin JwtSignInManager on AuthManager {
  Future<AppAuthUser?> signInWithJwtToken(
    BuildContext context,
    String jwtToken,
  );
}

// Phone number authentication with SMS verification
mixin PhoneSignInManager on AuthManager {
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  });

  Future verifySmsCode({
    required BuildContext context,
    required String smsCode,
  });
}

// Facebook Sign-In authentication
mixin FacebookSignInManager on AuthManager {
  Future<AppAuthUser?> signInWithFacebook(BuildContext context);
}

// Microsoft Sign-In authentication (Azure AD)
mixin MicrosoftSignInManager on AuthManager {
  Future<AppAuthUser?> signInWithMicrosoft(
    BuildContext context,
    List<String> scopes,
    String tenantId,
  );
}

// GitHub Sign-In authentication (OAuth)
mixin GithubSignInManager on AuthManager {
  Future<AppAuthUser?> signInWithGithub(BuildContext context);
}
