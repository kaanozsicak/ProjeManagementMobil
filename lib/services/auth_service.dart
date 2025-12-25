import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

/// Authentication result types
enum AuthResult {
  success,
  invalidEmail,
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  weakPassword,
  cancelled,
  networkError,
  unknownError,
}

/// Service for authentication operations
class AuthService {
  final FirebaseAuth _auth;
  final UserRepository _userRepository;
  GoogleSignIn? _googleSignIn;

  AuthService({
    FirebaseAuth? auth,
    UserRepository? userRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _userRepository = userRepository ?? UserRepository();

  /// Lazy initialization of GoogleSignIn
  GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn(
      scopes: ['email', 'profile'],
      // Web için client ID - Firebase Console'dan alınmalı
      // clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    );
    return _googleSignIn!;
  }

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ============================================
  // Email/Password Authentication
  // ============================================

  /// Register with email and password
  Future<(AuthResult, AppUser?)> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      // Update Firebase Auth display name
      await credential.user!.updateDisplayName(displayName);

      // Create user profile in Firestore
      final user = await _userRepository.createUser(
        uid: uid,
        displayName: displayName.trim(),
      );

      return (AuthResult.success, user);
    } on FirebaseAuthException catch (e) {
      debugPrint('Register error: ${e.code}');
      return (_mapFirebaseError(e.code), null);
    } catch (e) {
      debugPrint('Register error: $e');
      return (AuthResult.unknownError, null);
    }
  }

  /// Sign in with email and password
  Future<(AuthResult, AppUser?)> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      // Get or create user profile
      var user = await _userRepository.getUser(uid);
      if (user == null) {
        // Create profile if it doesn't exist (migration case)
        user = await _userRepository.createUser(
          uid: uid,
          displayName: credential.user!.displayName ?? email.split('@').first,
        );
      }

      return (AuthResult.success, user);
    } on FirebaseAuthException catch (e) {
      debugPrint('SignIn error: ${e.code}');
      return (_mapFirebaseError(e.code), null);
    } catch (e) {
      debugPrint('SignIn error: $e');
      return (AuthResult.unknownError, null);
    }
  }

  // ============================================
  // Google Sign-In
  // ============================================

  /// Sign in with Google
  Future<(AuthResult, AppUser?)> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return (AuthResult.cancelled, null);
      }

      // Get auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      // Get or create user profile
      var user = await _userRepository.getUser(uid);
      if (user == null) {
        user = await _userRepository.createUser(
          uid: uid,
          displayName: googleUser.displayName ?? googleUser.email.split('@').first,
        );
      }

      return (AuthResult.success, user);
    } on FirebaseAuthException catch (e) {
      debugPrint('Google SignIn error: ${e.code}');
      return (_mapFirebaseError(e.code), null);
    } catch (e) {
      debugPrint('Google SignIn error: $e');
      return (AuthResult.unknownError, null);
    }
  }

  // ============================================
  // Password Reset
  // ============================================

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e.code);
    } catch (e) {
      return AuthResult.unknownError;
    }
  }

  // ============================================
  // Legacy Methods (for backward compatibility)
  // ============================================

  /// Sign in anonymously and create user profile
  /// @deprecated Use signInWithEmail or signInWithGoogle instead
  Future<AppUser> signInWithUsername(String displayName) async {
    final credential = await _auth.signInAnonymously();
    final uid = credential.user!.uid;

    final existingUser = await _userRepository.getUser(uid);
    if (existingUser != null) {
      if (existingUser.displayName != displayName) {
        await _userRepository.updateDisplayName(uid, displayName);
        return existingUser.copyWith(displayName: displayName);
      }
      return existingUser;
    }

    return await _userRepository.createUser(
      uid: uid,
      displayName: displayName,
    );
  }

  // ============================================
  // Common Methods
  // ============================================

  /// Get current user's profile
  Future<AppUser?> getCurrentUserProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;
    return await _userRepository.getUser(uid);
  }

  /// Check if current user has a profile
  Future<bool> hasUserProfile() async {
    final uid = currentUserId;
    if (uid == null) return false;
    return await _userRepository.userExists(uid);
  }

  /// Sign out
  Future<void> signOut() async {
    // Only sign out from Google if it was initialized
    if (_googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
    await _auth.signOut();
  }

  /// Stream current user's profile
  Stream<AppUser?> watchCurrentUserProfile() {
    return authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      return await _userRepository.getUser(user.uid);
    });
  }

  /// Map Firebase error codes to AuthResult
  AuthResult _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return AuthResult.invalidEmail;
      case 'user-not-found':
        return AuthResult.userNotFound;
      case 'wrong-password':
      case 'invalid-credential':
        return AuthResult.wrongPassword;
      case 'email-already-in-use':
        return AuthResult.emailAlreadyInUse;
      case 'weak-password':
        return AuthResult.weakPassword;
      case 'network-request-failed':
        return AuthResult.networkError;
      default:
        return AuthResult.unknownError;
    }
  }
}

/// Extension to get user-friendly error messages
extension AuthResultMessage on AuthResult {
  String get message {
    switch (this) {
      case AuthResult.success:
        return 'İşlem başarılı';
      case AuthResult.invalidEmail:
        return 'Geçersiz e-posta adresi';
      case AuthResult.userNotFound:
        return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı';
      case AuthResult.wrongPassword:
        return 'Hatalı şifre';
      case AuthResult.emailAlreadyInUse:
        return 'Bu e-posta adresi zaten kullanımda';
      case AuthResult.weakPassword:
        return 'Şifre çok zayıf (en az 6 karakter)';
      case AuthResult.cancelled:
        return 'İşlem iptal edildi';
      case AuthResult.networkError:
        return 'İnternet bağlantısı yok';
      case AuthResult.unknownError:
        return 'Bir hata oluştu, tekrar deneyin';
    }
  }
}
