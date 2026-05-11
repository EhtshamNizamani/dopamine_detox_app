import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthLocalDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  
  AuthLocalDataSource(this._firebaseAuth);
  
  Future<firebase_auth.User?> signInAnonymously() async {
    final result = await _firebaseAuth.signInAnonymously();
    return result.user;
  }
  
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  
  Stream<firebase_auth.User?> get userChanges => _firebaseAuth.userChanges();
}