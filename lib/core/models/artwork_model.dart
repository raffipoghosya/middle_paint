import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for an artwork saved to the cloud.
/// Simplifies data handling and mapping between Dart objects and Firestore documents.
class ArtworkModel {
  final String id;
  final String userUid;
  final String imageUrl;
  final String name;
  final Timestamp creationDate;

  ArtworkModel({
    required this.id,
    required this.userUid,
    required this.imageUrl,
    required this.name,
    required this.creationDate,
  });

  factory ArtworkModel.fromMap(Map<String, dynamic> map) {
    return ArtworkModel(
      id: map['id'] as String,
      userUid: map['userUid'] as String,
      imageUrl: map['imageUrl'] as String,
      name: map['name'] as String,
      creationDate: map['creationDate'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userUid': userUid,
      'imageUrl': imageUrl,
      'name': name,
      'creationDate': creationDate,
    };
  }
}
