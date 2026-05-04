import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../../../models/report_model.dart';
import '../core/config/api_constant.dart';

class AdminReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // --- PRESERVED TEACHER LOGIC (FIRESTORE) ---
  Stream<QuerySnapshot> getPendingTeachersStream() {
    return _firestore.collection('users').where('role', isEqualTo: 'teacher').where('status', isEqualTo: 'pending').snapshots();
  }

  Stream<QuerySnapshot> getActiveTeachersStream() {
    return _firestore.collection('users').where('role', isEqualTo: 'teacher').where('status', isEqualTo: 'active').snapshots();
  }

  Future<void> verifyTeacherAction(String teacherId, String action) async {
    final url = Uri.parse(ApiConstants.notifyTeacherEndpoints);
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({ 'teacherId': teacherId, 'action': action }),
    );
  }

  // --- RTDB UNIFIED REPORTS STREAM ---

  Stream<List<ReportModel>> getAllAdminReportsStream() {
    final teacherRef = _database.ref('teacher_to_admin_reports').onValue;
    final parentRef = _database.ref('parent_to_admin_reports').onValue;
    final childRef = _database.ref('safety_alerts').onValue;
    final usersStream = _firestore.collection('users').snapshots();

    return Rx.combineLatest4(
      teacherRef, parentRef, childRef, usersStream,
          (DatabaseEvent t, DatabaseEvent p, DatabaseEvent c, QuerySnapshot userSnap) {

        Map<String, Map<String, dynamic>> userLookup = {};
        for (var doc in userSnap.docs) {
          userLookup[doc.id] = doc.data() as Map<String, dynamic>;
        }

        List<ReportModel> allReports = [];

        // 1. Teacher Reports (RTDB)
        if (t.snapshot.value != null) {
          final data = Map<String, dynamic>.from(t.snapshot.value as Map);
          data.forEach((key, value) {
            final report = Map<String, dynamic>.from(value as Map);
            final tId = report['fromTeacherId'] ?? '';
            allReports.add(ReportModel(
              id: key,
              reporterId: tId,
              source: 'Teacher',
              reporterName: report['fromTeacherName'] ?? userLookup[tId]?['name'] ?? 'Teacher',
              issueType: report['type'] ?? 'Report',
              severity: 'Medium',
              details: report['description'] ?? report['title'] ?? '',
              timestamp: DateTime.tryParse(report['timestamp'] ?? '') ?? DateTime.now(),
              isResolved: report['status'] == 'Resolved' || report['adminStatus'] == 'Resolved',
            ));
          });
        }

        // 2. Parent Reports (RTDB)
        if (p.snapshot.value != null) {
          final data = Map<String, dynamic>.from(p.snapshot.value as Map);
          data.forEach((key, value) {
            final report = Map<String, dynamic>.from(value as Map);
            final cId = report['childId'] ?? '';
            final pId = userLookup[cId]?['parent_id'];
            allReports.add(ReportModel(
              id: key,
              reporterId: pId ?? cId,
              source: 'Parent',
              reporterName: userLookup[pId]?['name'] ?? 'Parent of ${userLookup[cId]?['name'] ?? "Child"}',
              issueType: report['issue'] ?? 'Bug',
              severity: 'Low',
              details: "${report['parentNote'] ?? ''} ${report['details'] ?? ''}",
              timestamp: DateTime.tryParse(report['timestamp'] ?? '') ?? DateTime.now(),
              isResolved: report['status'] == 'Resolved',
            ));
          });
        }

        // 3. Child Alerts (RTDB - Nested: UID -> ID)
        if (c.snapshot.value != null) {
          final usersData = Map<String, dynamic>.from(c.snapshot.value as Map);
          usersData.forEach((userId, alertsMap) {
            if (alertsMap is Map) {
              final alerts = Map<String, dynamic>.from(alertsMap);
              alerts.forEach((alertId, alertValue) {
                final alert = Map<String, dynamic>.from(alertValue as Map);
                final studentData = userLookup[userId];
                String name = studentData?['name'] ?? 'Student $userId';

                if (studentData?['is_teacher_added'] == true) {
                  final teacherName = userLookup[studentData!['teacher_id']]?['name'] ?? 'Teacher';
                  name = "$name (Added by $teacherName)";
                }

                allReports.add(ReportModel(
                  id: alertId,
                  reporterId: userId, // Logic: This UID is required for the path safety_alerts/UID/ID
                  source: 'Child',
                  reporterName: name,
                  issueType: alert['issueType'] ?? 'Alert',
                  severity: 'High',
                  details: alert['details'] ?? 'Safety Alert',
                  timestamp: DateTime.tryParse(alert['timestamp'] ?? '') ?? DateTime.now(),
                  isResolved: alert['status'] == 'Resolved',
                ));
              });
            }
          });
        }

        allReports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return allReports;
      },
    );
  }

  /// Logic: Direct Realtime Database Update for Persistence (Fixes the logical error)
  Future<void> resolveReportAction(String reportId, String source, {String? reporterId}) async {
    try {
      if (source == 'Teacher') {
        // Path: teacher_to_admin_reports/REPORT_ID
        await _database.ref('teacher_to_admin_reports/$reportId').update({
          'status': 'Resolved',
          'adminStatus': 'Resolved',
        });
      } else if (source == 'Child' && reporterId != null) {
        // Path: safety_alerts/USER_UID/REPORT_ID
        await _database.ref('safety_alerts/$reporterId/$reportId').update({
          'status': 'Resolved',
        });
      }

      // Logic: Call backend for Push Notification delivery (Preserved)
      final url = Uri.parse("${ApiConstants.baseUrl}/resolve-report");
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({ 'reportId': reportId, 'source': source, 'action': 'resolve' }),
      );

      debugPrint("✅ RTDB Update Successful for $reportId");
    } catch (e) {
      debugPrint("❌ RTDB Resolve Error: $e");
      throw Exception("Failed to update Realtime Database. Check your databaseURL.");
    }
  }
}