import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

/// Service for authentication operations
class AuthService {
  final FirebaseAuth _auth;
  final UserRepository _userRepository;

  AuthService({
    FirebaseAuth? auth,
    UserRepository? userRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _userRepository = userRepository ?? UserRepository();

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in anonymously and create user profile
  Future<AppUser> signInWithUsername(String displayName) async {
    // Sign in anonymously
    final credential = await _auth.signInAnonymously();
    final uid = credential.user!.uid;

    // Check if user already exists (in case of app reinstall)
    final existingUser = await _userRepository.getUser(uid);
    if (existingUser != null) {
      // Update display name if different
      if (existingUser.displayName != displayName) {
        await _userRepository.updateDisplayName(uid, displayName);
        return existingUser.copyWith(displayName: displayName);
      }
      return existingUser;
    }

    // Create new user profile
    return await _userRepository.createUser(
      uid: uid,
      displayName: displayName,
    );
  }

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
    await _auth.signOut();
  }

  /// Stream current user's profile
  Stream<AppUser?> watchCurrentUserProfile() {
    return authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      return await _userRepository.getUser(user.uid);
    });
  }
}
