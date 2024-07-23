import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taleb_edu_platform/models/user_model.dart';
import 'package:taleb_edu_platform/services/auth_service.dart';
import 'package:taleb_edu_platform/services/firestore_service.dart';
import 'package:taleb_edu_platform/services/notification_service.dart';

class AuthState {
  final User? firebaseUser;
  final UserModel? userModel;

  const AuthState({this.firebaseUser, this.userModel});

  bool get isAuthenticated => firebaseUser != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  AuthNotifier() : super(AuthState()) {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      state = AuthState(firebaseUser: null, userModel: null);
    } else {
      print('Current user ID: ${firebaseUser.uid}');
      try {
        final doc = await _firestoreService.getDocument('users', firebaseUser.uid);
        UserModel? userModel;
        if (doc.exists) {
          userModel = UserModel.fromFirestore(doc);
        } else {
          userModel = await _createUserDocument(firebaseUser);
        }
        state = AuthState(firebaseUser: firebaseUser, userModel: userModel);
      } catch (e) {
        print('Error retrieving or creating user document: $e');
        state = AuthState(firebaseUser: firebaseUser, userModel: null);
      }
    }
  }

  Future<UserModel> _createUserDocument(User firebaseUser) async {
    final newUser = UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'New User',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      username: '',
    );
    try {
      await _firestoreService.setDocument('users', firebaseUser.uid, newUser.toMap());
      print('Created new user document for ${firebaseUser.uid}');
      return newUser;
    } catch (e) {
      print('Error creating user document: $e');
      throw Exception('Failed to create user document: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = UserModel(
        id: credential.user!.uid,
        name: username,
        email: email,
        username: username,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await _firestoreService.setDocument('users', user.id, user.toMap());
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      await _firestoreService.updateDocument('users', updatedUser.id, updatedUser.toMap());
      state = AuthState(firebaseUser: state.firebaseUser, userModel: updatedUser);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return AuthService(notificationService);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});