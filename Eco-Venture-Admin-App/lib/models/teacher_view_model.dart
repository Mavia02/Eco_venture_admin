class TeacherModel {
  final String uid;
  final String name;
  final String email;
  final bool isApproved;

  TeacherModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isApproved,
  });

  /// Logic: Map keys must match what AdminReportService/Firestore uses
  factory TeacherModel.fromMap(Map<String, dynamic> map, String id) {
    return TeacherModel(
      uid: id,
      name: map['name'] ?? 'Unknown Teacher',
      email: map['email'] ?? 'No Email',
      // In your system, if they are in the active stream, they are approved
      isApproved: map['status'] == 'approved' || (map['isApproved'] ?? true),
    );
  }
}