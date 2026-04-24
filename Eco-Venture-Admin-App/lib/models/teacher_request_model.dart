import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherRequestModel {
  final String id;
  final String name;
  final String email;
  final String status;
  final DateTime? createdAt;

  TeacherRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.createdAt,
  });

  factory TeacherRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle createdAt being either a String (ISO) or a Firestore Timestamp
    DateTime? parsedDate;
    if (data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      parsedDate = DateTime.tryParse(data['createdAt']);
    }

    return TeacherRequestModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: parsedDate,
    );
  }
}