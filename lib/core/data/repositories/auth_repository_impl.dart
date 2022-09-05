// Package imports:
import 'package:firebase_auth/firebase_auth.dart' as auth;

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/repositories/auth_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/models/user.dart';
import 'package:attendance_log_with_firebase/utils/logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user != null) {
        Log.logger.i('User ${user.uid} is signed in!');
        return _userFromFirebaseUser(user);
      }

      Log.logger.i('User is currently signed out!');
      return null;
    });
  }

  @override
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final auth.UserCredential result =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final auth.User? user = result.user;

    if (user != null) {
      _firebaseAuth.currentUser?.reload();
      return _userFromFirebaseUser(user);
    }

    return null;
  }

  @override
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final auth.UserCredential result =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final auth.User? user = result.user;

    if (user != null) {
      return _userFromFirebaseUser(user);
    }

    return null;
  }

  @override
  Future<void> signOut() async => _firebaseAuth.signOut();

  /// create user obj based on Firebase User
  User _userFromFirebaseUser(auth.User user) {
    return User(uid: user.uid, name: user.displayName);
  }

  User? get currentUser {
    if (_firebaseAuth.currentUser != null) {
      return _userFromFirebaseUser(_firebaseAuth.currentUser!);
    }

    return null;
  }
}
