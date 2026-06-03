import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

const _kCachedUserKey = 'cached_user_profile';

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
      await _cacheUser(user);
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
      final user = await _fetchUserProfile(credential.user!.uid);
      await _cacheUser(user);
      return user;
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
      await _clearCachedUser();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    // Return cached profile immediately, refresh in background.
    final cached = await _loadCachedUser();
    if (cached != null) {
      unawaited(_refreshUserProfileInBackground(firebaseUser.uid));
      return cached;
    }

    // No cache — fetch and cache synchronously (first launch after install).
    try {
      final user = await _fetchUserProfile(firebaseUser.uid);
      await _cacheUser(user);
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateLanguage(String userId, String language) async {
    try {
      await _users.doc(userId).update({'language': language});
      final cached = await _loadCachedUser();
      if (cached != null) {
        await _cacheUser(cached.copyWith(language: language));
      }
    } catch (e) {
      throw Exception('Failed to update language: $e');
    }
  }

  Future<UserModel> _fetchUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) throw Exception('User profile not found');
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<void> _refreshUserProfileInBackground(String uid) async {
    try {
      final user = await _fetchUserProfile(uid);
      await _cacheUser(user);
    } catch (_) {}
  }

  Future<void> _cacheUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCachedUserKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> _loadCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kCachedUserKey);
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCachedUserKey);
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
