import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taleb_edu_platform/models/user_model.dart';
import 'package:taleb_edu_platform/services/firebase_service.dart';
import 'package:taleb_edu_platform/services/firestore_service.dart';
import 'package:taleb_edu_platform/services/notification_service.dart';
import 'package:taleb_edu_platform/services/storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseService().auth;
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final NotificationService _notificationService;

  AuthService(this._notificationService);


  FirebaseAuth get auth => _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      print('Current user ID: ${user.uid}');
      try {
        UserModel? userModel = await _getUserDocument(user.uid);
        if (userModel == null) {
          userModel = await _createUserDocument(user);
        }
        // Update OneSignal player ID
        String? playerId = await _notificationService.getDeviceToken();
        if (playerId != null && playerId != userModel.fcmToken) {
          userModel = userModel.copyWith(fcmToken: playerId);
          await _firestoreService.updateDocument('users', user.uid, {'fcmToken': playerId});
        }
        return userModel;
      } catch (e) {
        print('Error retrieving or creating user document: $e');
        return null;
      }
    } else {
      print('No current user found in FirebaseAuth');
    }
    return null;
  }

  Future<bool> isUserAdmin() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        IdTokenResult tokenResult = await user.getIdTokenResult(true);
        return tokenResult.claims?['admin'] == true;
      } catch (e) {
        print('Error checking admin status: $e');
        return false;
      }
    }
    return false;
  }

  Future<UserModel?> _getUserDocument(String uid) async {
    try {
      final doc = await _firestoreService.getDocument('users', uid);
      if (doc.exists) {
        print('User document found in Firestore');
        return UserModel.fromFirestore(doc);
      } else {
        print('No user document found in Firestore for user $uid');
        return null;
      }
    } catch (e) {
      print('Error retrieving user document: $e');
      return null;
    }
  }

  Future<UserModel> _createUserDocument(User user, {Map<String, dynamic>? additionalInfo}) async {
    String? playerId = await _notificationService.getDeviceToken();
    final newUser = UserModel(
      id: user.uid,
      name: additionalInfo?['name'] ?? user.displayName ?? 'New User',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      username: additionalInfo?['username'] ?? '',
      gender: additionalInfo?['gender'],
      branch: additionalInfo?['branch'],
      regionPoint: additionalInfo?['regionPoint'],
      nationalPoint: additionalInfo?['nationalPoint'],
      fcmToken: playerId,
    );
    try {
      await _firestoreService.setDocument('users', user.uid, newUser.toMap());
      print('Created new user document for ${user.uid}');
      return newUser;
    } catch (e) {
      print('Error creating user document: $e');
      throw Exception('Failed to create user document: $e');
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('Attempting to sign in with email: $email');
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('User signed in successfully: ${credential.user?.uid}');
      await _createOrUpdateUser(credential.user!);
      return credential;
    } catch (e) {
      print('Error signing in: $e');
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String username,
    {
      required Map<String, dynamic> additionalInfo,
      File? profileImage,
    }
  ) async {
    try {
      print('Attempting to create user with email: $email');
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      print('User created successfully: ${userCredential.user?.uid}');
      
      String? photoUrl;
      if (profileImage != null) {
        photoUrl = await _uploadProfileImage(userCredential.user!.uid, profileImage);
      }

      final newUser = UserModel(
        id: userCredential.user!.uid,
        name: additionalInfo['name'] ?? '',
        email: email,
        username: username,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        gender: additionalInfo['gender'],
        branch: additionalInfo['branch'],
        regionPoint: additionalInfo['regionPoint'],
        nationalPoint: additionalInfo['nationalPoint'],
      );

      await _firestoreService.setDocument('users', userCredential.user!.uid, newUser.toMap());
      print('User data added to Firestore');

      // Update OneSignal player ID
      String? playerId = await _notificationService.getDeviceToken();
      if (playerId != null) {
        await _firestoreService.updateDocument('users', userCredential.user!.uid, {'fcmToken': playerId});
      }

      return userCredential;
    } catch (e) {
      print('Error creating user: $e');
      throw _handleAuthException(e);
    }
  }

  Future<String> _uploadProfileImage(String userId, File imageFile) async {
    try {
      final imagePath = 'profile_images/$userId/profile.jpg';
      final downloadUrl = await _storageService.uploadFile(imagePath, imageFile);
      print('Profile image uploaded successfully');
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      print('Attempting Google Sign-In');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      print('Google Sign-In successful: ${userCredential.user?.uid}');
      await _createOrUpdateUser(userCredential.user!);
      return userCredential;
    } catch (e) {
      print('Error in Google Sign-In: $e');
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    try {
      print('Attempting Facebook Sign-In');
      final LoginResult loginResult = await _facebookAuth.login();

      if (loginResult.status == LoginStatus.success) {
        final AccessToken? accessToken = loginResult.accessToken;
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken!.token);
        final userCredential = await _auth.signInWithCredential(facebookAuthCredential);
        print('Facebook Sign-In successful: ${userCredential.user?.uid}');
        await _createOrUpdateUser(userCredential.user!);
        return userCredential;
      } else {
        throw Exception('Facebook login failed: ${loginResult.status}');
      }
    } catch (e) {
      print('Error in Facebook Sign-In: $e');
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    try {
      print('Attempting to sign out');
      await _googleSignIn.signOut();
      await _facebookAuth.logOut();
      await _auth.signOut();
      print('Sign out successful');
    } catch (e) {
      print('Error signing out: $e');
      throw _handleAuthException(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      print('Attempting to send password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent successfully');
    } catch (e) {
      print('Error sending password reset email: $e');
      throw _handleAuthException(e);
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data, {File? profileImage}) async {
    try {
      print('Updating user profile for user: $userId');
      if (profileImage != null) {
        final photoUrl = await _uploadProfileImage(userId, profileImage);
        data['photoUrl'] = photoUrl;
      }
      await _firestoreService.updateDocument('users', userId, data);
      print('User profile updated successfully');
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      print('Attempting to delete user: $userId');
      await _firestoreService.deleteDocument('users', userId);
      await _auth.currentUser?.delete();
      print('User deleted successfully');
    } catch (e) {
      print('Error deleting user: $e');
      throw _handleAuthException(e);
    }
  }

  Future<void> _createOrUpdateUser(User user) async {
    try {
      print('Checking if user document exists for: ${user.uid}');
      final userData = await _getUserDocument(user.uid);

      if (userData != null) {
        print('Updating existing user data');
        await _updateUserLastLogin(user.uid);
      } else {
        print('Creating new user document');
        await _createUserDocument(user);
      }
    } catch (e) {
      print('Error in _createOrUpdateUser: $e');
    }
  }

  Future<void> _updateUserLastLogin(String userId) async {
    try {
      print('Updating last login for user: $userId');
      await _firestoreService.updateDocument('users', userId, {'lastLogin': DateTime.now()});
      print('Last login updated successfully');
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found for that email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('The email address is already in use.');
        case 'invalid-email':
          return Exception('The email address is invalid.');
        case 'user-disabled':
          return Exception('This user account has been disabled.');
        case 'operation-not-allowed':
          return Exception('This operation is not allowed.');
        case 'weak-password':
          return Exception('The password provided is too weak.');
        case 'account-exists-with-different-credential':
          return Exception('An account already exists with the same email address but different sign-in credentials.');
        default:
          return Exception('Authentication error: ${e.message}');
      }
    }
    print('Unexpected error in AuthService: $e');
    return Exception('An unexpected error occurred: $e');
  }
}
