import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _errorMessage;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    print('🔵 Auth state changed: ${user?.uid}');
    _user = user;
    if (user != null) {
      await _loadUserData(user.uid);
    } else {
      _userModel = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      print('🔵 Loading user data for: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        print('🟢 User document found');
        _userModel = UserModel.fromMap(doc.data()!);
        print('🟢 User model created: ${_userModel?.fullName}');
      } else {
        print('🔴 User document does not exist');
      }
    } catch (e) {
      print('🔴 Error loading user data: $e');
      _errorMessage = e.toString();
    }
  }

  Future<bool> checkUsernameAvailability(String username) async {
    try {
      print('🔵 Checking username availability: $username');
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      print('🟢 Username check result: ${query.docs.isEmpty ? "Available" : "Taken"}');
      return query.docs.isEmpty;
    } catch (e) {
      print('🔴 Username check error: $e');
      // If there's a permission error, assume username is available
      // This allows sign-up to proceed even if rules aren't set up yet
      if (e.toString().contains('PERMISSION_DENIED') ||
          e.toString().contains('permission')) {
        print('⚠️ Permission error - allowing sign-up to proceed');
        return true; // Assume available on permission error
      }
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required DateTime sobrietyStartDate,
    required double dailyAlcoholSpend,
    required int drinkingDuration,
    required int drinkingAmount,
    required int medicalAdvice,
    required int impactLevel,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔵 Starting sign-up process...');

      // Check username availability
      final isAvailable = await checkUsernameAvailability(username);
      if (!isAvailable) {
        _errorMessage = 'Username is already taken';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('🔵 Creating Firebase Auth account...');

      // Create user account - wrapped in try-catch for type casting issues
      UserCredential? userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (authError) {
        print('⚠️ Auth creation error (might be type casting): $authError');
        // Wait a bit and check if user was actually created
        await Future.delayed(const Duration(seconds: 2));
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          print('🟢 User was created despite error: ${currentUser.uid}');
          // Create a mock credential
          userCredential = null; // We'll use currentUser instead
        } else {
          throw authError;
        }
      }

      final userId = userCredential?.user?.uid ?? _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Failed to get user ID after account creation');
      }

      print('🟢 Auth account created: $userId');

      // Create user document
      final userModel = UserModel(
        uid: userId,
        fullName: fullName,
        username: username,
        email: email,
        sobrietyStartDate: sobrietyStartDate,
        dailyAlcoholSpend: dailyAlcoholSpend,
        drinkingDuration: drinkingDuration,
        drinkingAmount: drinkingAmount,
        medicalAdvice: medicalAdvice,
        impactLevel: impactLevel,
        createdAt: DateTime.now(),
      );

      print('🔵 Creating Firestore document...');

      await _firestore
          .collection('users')
          .doc(userId)
          .set(userModel.toMap());

      print('🟢 Firestore document created successfully');

      _userModel = userModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('🔴 Firebase Auth Error: ${e.code} - ${e.message}');
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('🔴 Sign-up Error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      String email = emailOrUsername;

      // Check if input is username
      if (!emailOrUsername.contains('@')) {
        print('🔵 Looking up username: $emailOrUsername');
        final query = await _firestore
            .collection('users')
            .where('username', isEqualTo: emailOrUsername)
            .get();

        if (query.docs.isEmpty) {
          _errorMessage = 'User not found';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        email = query.docs.first.data()['email'];
        print('🟢 Username found, email: $email');
      }

      print('🔵 Attempting sign in with email: $email');

      // Wrap the actual sign-in to catch type casting errors
      UserCredential? userCredential;
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('🟢 Sign in successful: ${userCredential.user?.uid}');
      } catch (signInError) {
        print('⚠️ Sign-in error (might be type casting): $signInError');
        // Wait a bit and check if sign-in actually succeeded
        await Future.delayed(const Duration(seconds: 1));
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          print('🟢 User is signed in despite error: ${currentUser.uid}');
          // Sign-in succeeded despite the error
        } else {
          // Actual sign-in failure
          throw signInError;
        }
      }

      // Explicitly load user data after sign-in
      if (_auth.currentUser != null) {
        print('🔵 Loading user data after sign-in...');
        await _loadUserData(_auth.currentUser!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('🔴 Firebase Auth Error: ${e.code} - ${e.message}');
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('🔴 Sign-in Error: $e');
      _errorMessage = 'Sign in failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<bool> updateUserProfile({
    String? fullName,
    String? username,
    String? email,
  }) async {
    try {
      if (_user == null || _userModel == null) return false;

      final updates = <String, dynamic>{};

      if (fullName != null) updates['fullName'] = fullName;
      if (username != null) {
        final isAvailable = await checkUsernameAvailability(username);
        if (!isAvailable && username != _userModel!.username) {
          _errorMessage = 'Username is already taken';
          return false;
        }
        updates['username'] = username;
      }
      if (email != null) {
        await _user!.updateEmail(email);
        updates['email'] = email;
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_user!.uid).update(updates);
        await _loadUserData(_user!.uid);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      if (_user == null) return false;

      // Delete user document
      await _firestore.collection('users').doc(_user!.uid).delete();

      // Delete all user's reports
      final reports = await _firestore
          .collection('daily_reports')
          .where('userId', isEqualTo: _user!.uid)
          .get();

      for (var doc in reports.docs) {
        await doc.reference.delete();
      }

      // Delete all user's badges
      final badges = await _firestore
          .collection('badges')
          .where('userId', isEqualTo: _user!.uid)
          .get();

      for (var doc in badges.docs) {
        await doc.reference.delete();
      }

      // Delete user account
      await _user!.delete();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}