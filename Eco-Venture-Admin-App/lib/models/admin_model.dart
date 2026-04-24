import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String aid;
  final String name;
  final String email;
  final String imgUrl;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  AdminModel({
    required this.aid,
    required this.name,
    required this.email,
    required this.imgUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "aid": aid,
      "name": name,
      "email": email,
      "imgUrl": imgUrl,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      aid: map['aid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  AdminModel copyWith({
    String? aid,
    String? name,
    String? email,
    String? imgUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return AdminModel(
      aid: aid ?? this.aid,
      name: name ?? this.name,
      email: email ?? this.email,
      imgUrl: imgUrl ?? this.imgUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdminModel &&
        other.aid == aid &&
        other.email == email;
  }

  @override
  int get hashCode => aid.hashCode ^ email.hashCode;
}