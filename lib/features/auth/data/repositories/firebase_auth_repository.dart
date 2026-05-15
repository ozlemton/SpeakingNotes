import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository(this._auth, this._firestore);

  CollectionReference get _users => _firestore.collection('users');

  @override
  Future<UserModel> signUp(
      String username, String email, String password, String language) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = UserModel(
        id: credential.user!.uid,
        username: username,
        email: email,
        language: language,
        createdAt: DateTime.now(),
      );
      await _users.doc(user.id).set(user.toJson());
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e.code));
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _fetchUserProfile(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e.code));
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;
      return await _fetchUserProfile(firebaseUser.uid);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateLanguage(String userId, String language) async {
    try {
      await _users.doc(userId).update({'language': language});
    } catch (e) {
      throw Exception('Failed to update language: $e');
    }
  }

  Future<UserModel> _fetchUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) throw Exception('User profile not found');
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication error: $code';
    }
  }
}
