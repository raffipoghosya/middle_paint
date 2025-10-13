import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a registered user in our application,
/// used for storing extra profile data in Firestore.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final Timestamp creationDate;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.creationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'creationDate': creationDate,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: (map['uid'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      creationDate: map['creationDate'] as Timestamp,
    );
  }
}
