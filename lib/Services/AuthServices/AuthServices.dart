import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:goal_play/Services/DataService/DataService.dart';




enum AuthStatus { authenticated, unauthenticated, loading }



class AuthService with ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
    ],
  );




  User? _user;

  AuthStatus _status = AuthStatus.unauthenticated;

  String? _errorMessage;



  // Getters

  User? get user => _user;

  AuthStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;



  AuthService() {

    // Listen to auth state changes

    _auth.authStateChanges().listen(_onAuthStateChanged);

  }



  void _onAuthStateChanged(User? user) {

    _user = user;

    _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;

    notifyListeners();

    // Initialize DataService when user logs in
    if (user != null) {
      DataService().initializeData();
    } else {
      DataService().clearCache();
    }

  }



  // ==================== STORE USER DATA IN FIRESTORE ====================

  Future<void> _storeUserDataInFirestore(String userId, String email, String username) async {
    try {
      // Only store essential user data in Firestore
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'email': email,
        'username': username.toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('User data stored successfully in Firestore');
    } catch (e) {
      print('Error storing user data in Firestore: $e');
    }
  }



  // ==================== FIND USER BY USERNAME ====================

  Future<String?> findEmailByUsername(String username) async {

    try {

      final snapshot = await _firestore

          .collection('users')

          .where('username', isEqualTo: username.toLowerCase())

          .limit(1)

          .get();

      

      if (snapshot.docs.isNotEmpty) {

        return snapshot.docs.first.data()['email'] as String;

      }

      return null;

    } catch (e) {

      print('Error finding email by username: $e');

      return null;

    }

  }



  // ==================== SIGN UP ====================

  Future<bool> signUp({

    required String email,

    required String password,

    required String name,

  }) async {

    try {

      _status = AuthStatus.loading;

      _errorMessage = null;

      notifyListeners();



      // Create user

      final credential = await _auth.createUserWithEmailAndPassword(

        email: email,

        password: password,

      );



      // Update display name (username)

      await credential.user?.updateDisplayName(name);

      await credential.user?.reload();

      _user = _auth.currentUser;



      // Store user data in Firestore

      if (_user != null) {

        await _storeUserDataInFirestore(_user!.uid, email, name);

      }



      _status = AuthStatus.authenticated;

      notifyListeners();

      return true;

    } on FirebaseAuthException catch (e) {

      _handleAuthError(e);

      return false;

    } catch (e) {

      _errorMessage = 'An unexpected error occurred: $e';

      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return false;

    }

  }



  // ==================== LOGIN ====================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Basic validation
      if (email.isEmpty) {
        _errorMessage = 'Email is required';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      
      if (password.isEmpty) {
        _errorMessage = 'Password is required';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      // Sign in with Firebase Auth
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = _auth.currentUser;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }



  // ==================== LEGACY LOGIN METHOD ====================

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await login(email: email, password: password);
  }



  /// ==================== GOOGLE SIGN-IN ====================

  Future<bool> signInWithGoogle() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled sign-in
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      await _auth.signInWithCredential(credential);

      _user = _auth.currentUser;
      
      // Store user data in Firestore
      if (_user != null) {
        await _storeUserDataInFirestore(
          _user!.uid,
          _user!.email!,
          _user!.displayName ?? 'User',
        );
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
        
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: $e';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }



  // ==================== FORGOT PASSWORD ====================







  Future<bool> resetPassword({required String email}) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Enhanced validation
      if (email.isEmpty) {
        _errorMessage = 'Please enter your email address';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email)) {
        _errorMessage = 'Please enter a valid email address';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      // Enhanced debugging
      print('=== PASSWORD RESET DEBUG ===');
      print('Target Email: $email');
      print('Project ID: goal-play');
      print('App ID: 1:480773029928:android:9d726b88dc7fb80a1e351d');
      print('Auth Domain: goal-play.firebaseapp.com');
      print('Current User: ${_auth.currentUser?.email}');
      print('===========================');
      
      // Send password reset email
      print('Sending password reset email...');
      await _auth.sendPasswordResetEmail(email: email.trim());
      
      print('✅ Password reset email sent successfully to: $email');
      print('📧 Check inbox and spam folder');
      print('⏰ Link expires in 24 hours');
      
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Password reset email sent! Please check your inbox (including spam folder).';
      notifyListeners();
      
      return true;
      
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error in reset password:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Email: ${e.email}');
      print('   Stack Trace: ${e.stackTrace}');
      
      // Enhanced error handling
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'No account found with this email address. Please sign up first.';
          break;
        case 'invalid-email':
          _errorMessage = 'Invalid email address format. Please check and try again.';
          break;
        case 'too-many-requests':
          _errorMessage = 'Too many requests. Please wait 15-30 minutes before trying again.';
          break;
        case 'network-request-failed':
          _errorMessage = 'Network error. Please check your internet connection and try again.';
          break;
        case 'auth/configuration-not-found':
          _errorMessage = 'Firebase configuration error. Please contact support.';
          break;
        case 'auth/invalid-api-key':
          _errorMessage = 'API key error. Please contact support.';
          break;
        default:
          _errorMessage = 'Failed to send reset email: ${e.message}';
      }
      
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
      
    } catch (e) {
      print('❌ Unexpected error in reset password: $e');
      _errorMessage = 'An unexpected error occurred. Please try again or contact support.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }



  // ==================== LOGOUT ====================

  Future<void> logout() async {

    try {

      await _auth.signOut();

      // await _googleSignIn.signOut();

      _user = null;

      _status = AuthStatus.unauthenticated;

      _errorMessage = null;

      notifyListeners();

    } catch (e) {

      _errorMessage = 'Logout failed: $e';

      notifyListeners();

    }

  }



  /// ==================== CHECK AUTH STATUS ====================

  Future<void> checkAuthStatus() async {

    _user = _auth.currentUser;

    _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;

    notifyListeners();

  }



  /// ==================== ERROR HANDLING ====================

  void _handleAuthError(FirebaseAuthException e) {

    switch (e.code) {

      case 'weak-password':

        _errorMessage = 'Password is too weak. Use at least 6 characters.';

        break;

      case 'email-already-in-use':

        _errorMessage = 'This email is already registered. Please use a different email or try logging in.';

        break;

      case 'invalid-email':

        _errorMessage = 'Invalid email address.';

        break;

      case 'user-not-found':

        _errorMessage = 'No account found with this email.';

        break;

      case 'wrong-password':

        _errorMessage = 'Incorrect password. Try again.';

        break;

      case 'user-disabled':

        _errorMessage = 'This account has been disabled.';

        break;

      case 'too-many-requests':

        _errorMessage = 'Too many attempts. Try again later.';

        break;

      case 'operation-not-allowed':

        _errorMessage = 'This sign-in method is not enabled.';

        break;

      case 'network-request-failed':

        _errorMessage = 'Network error. Check your connection.';

        break;

      case 'invalid-credential':

        _errorMessage = 'Invalid credentials. Please check your email and password.';

        break;

      case 'session-expired':

        _errorMessage = 'Session expired. Please login again.';

        break;

      case 'account-exists-with-different-credential':

        _errorMessage = 'Account exists with different sign-in method.';

        break;

      case 'requires-recent-login':

        _errorMessage = 'Please login again to perform this action.';

        break;

      default:

        _errorMessage = 'Authentication error: ${e.message}';

    }

    _status = AuthStatus.unauthenticated;

    notifyListeners();

  }



  /// ==================== CLEAR ERROR ====================

  void clearError() {

    _errorMessage = null;

    notifyListeners();

  }

}

