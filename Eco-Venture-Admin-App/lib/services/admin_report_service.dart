import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../core/config/api_constant.dart';

class AdminReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Get Pending Teachers (Queue)
  Stream<QuerySnapshot> getPendingTeachersStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // 2. NEW: Get Active Teachers (Count)
  Stream<QuerySnapshot> getActiveTeachersStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  Future<void> verifyTeacherAction(String teacherId, String action) async {
    final url = Uri.parse(ApiConstants.notifyTeacherEndpoints);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({ 'teacherId': teacherId, 'action': action }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode != 200) throw Exception(response.body);
    } catch (e) {
      debugPrint("❌ Error: $e");
      throw Exception("Network Error");
    }
  }
}