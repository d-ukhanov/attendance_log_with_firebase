// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/user.dart';

abstract class AuthRepository {
  /// Notifies about changes to the user's sign-in state
  Stream<User?> get authStateChanges;

  /// sign in with email & password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// create a new user with email & password
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  );

  /// sign out
  Future<void> signOut();
}
