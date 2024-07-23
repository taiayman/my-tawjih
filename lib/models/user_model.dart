import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;
  final List<String> interests;
  final List<String> appliedOpportunities;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String? fcmToken;
  final String username;
  final String? gender;
  final String? branch;
  final String? regionPoint;
  final String? nationalPoint;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    this.interests = const [],
    this.appliedOpportunities = const [],
    required this.createdAt,
    required this.lastLogin,
    this.fcmToken,
    required this.username,
    this.gender,
    this.branch,
    this.regionPoint,
    this.nationalPoint,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      interests: List<String>.from(data['interests'] ?? []),
      appliedOpportunities: List<String>.from(data['appliedOpportunities'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmToken: data['fcmToken'],
      username: data['username'] ?? '',
      gender: data['gender'],
      branch: data['branch'],
      regionPoint: data['regionPoint'],
      nationalPoint: data['nationalPoint'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'interests': interests,
      'appliedOpportunities': appliedOpportunities,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'fcmToken': fcmToken,
      'username': username,
      'gender': gender,
      'branch': branch,
      'regionPoint': regionPoint,
      'nationalPoint': nationalPoint,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
    List<String>? interests,
    List<String>? appliedOpportunities,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? fcmToken,
    String? username,
    String? gender,
    String? branch,
    String? regionPoint,
    String? nationalPoint,
  }) {
    return UserModel(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      appliedOpportunities: appliedOpportunities ?? this.appliedOpportunities,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      fcmToken: fcmToken ?? this.fcmToken,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      branch: branch ?? this.branch,
      regionPoint: regionPoint ?? this.regionPoint,
      nationalPoint: nationalPoint ?? this.nationalPoint,
    );
  }
}
