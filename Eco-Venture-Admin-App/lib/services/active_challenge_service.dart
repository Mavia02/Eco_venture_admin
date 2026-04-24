import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_venture_admin_portal/models/active_challenge_model.dart';

/// Logic: Service responsible for fetching real-time progress from Firebase Realtime Database.
/// Now handles: Quizzes, QR Hunts, Multimedia Activity, and STEM Submissions.
class ActiveChallengeService {
  ActiveChallengeService._();
  static final ActiveChallengeService instance = ActiveChallengeService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Logic: Unified fetcher that combines Quiz, QR, Multimedia, and STEM activity.
  Future<List<ActiveChallengeModel>> fetchAllActiveChallenges() async {
    List<ActiveChallengeModel> allActive = [];

    final results = await Future.wait([
      fetchActiveQuizzes(),
      fetchActiveQRHunts(),
      fetchActiveMultimedia(),
      fetchActiveStemSubmissions(),
    ]);

    for (var list in results) {
      allActive.addAll(list);
    }

    // Sort by most recent activity first
    allActive.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

    return allActive;
  }

  /// Logic: Scans 'child_quiz_progress' in RTDB.
  Future<List<ActiveChallengeModel>> fetchActiveQuizzes() async {
    List<ActiveChallengeModel> activeList = [];
    try {
      final snapshot = await _db.ref('child_quiz_progress').get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> usersData = snapshot.value as Map<dynamic, dynamic>;
        for (var userId in usersData.keys) {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          final String userName = userDoc.data()?['name'] ?? "Unknown Student";

          final Map<dynamic, dynamic> categories = usersData[userId];
          categories.forEach((categoryName, topics) {
            final Map<dynamic, dynamic> topicMap = topics;
            topicMap.forEach((topicId, levels) {
              final Map<dynamic, dynamic> levelMap = levels;
              levelMap.forEach((levelOrder, data) {
                if (data['is_passed'] == false) {
                  activeList.add(ActiveChallengeModel(
                    userId: userId,
                    userName: userName,
                    challengeTitle: "Level $levelOrder Quiz",
                    category: "Interactive Quiz ($categoryName)",
                    status: "In Progress",
                    lastActivity: DateTime.tryParse(data['attempt_date'] ?? '') ?? DateTime.now(),
                    progressPercent: (data['attempt_percentage'] ?? 0).toDouble(),
                  ));
                }
              });
            });
          });
        }
      }
    } catch (e) {
      print("Error fetching active quizzes: $e");
    }
    return activeList;
  }

  /// Logic: Scans 'child_qr_progress' in RTDB.
  Future<List<ActiveChallengeModel>> fetchActiveQRHunts() async {
    List<ActiveChallengeModel> activeList = [];
    try {
      final snapshot = await _db.ref('child_qr_progress').get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> usersData = snapshot.value as Map<dynamic, dynamic>;
        for (var userId in usersData.keys) {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          final String userName = userDoc.data()?['name'] ?? "Unknown Student";

          final Map<dynamic, dynamic> hunts = usersData[userId];
          hunts.forEach((huntId, data) {
            if (data['is_completed'] == false) {
              int current = data['current_clue_index'] ?? 0;
              int total = data['total_clues'] ?? 1;
              double progress = (current / total) * 100;

              activeList.add(ActiveChallengeModel(
                userId: userId,
                userName: userName,
                challengeTitle: "Treasure Hunt",
                category: "QR Based",
                status: "Searching...",
                lastActivity: DateTime.tryParse(data['start_time'] ?? '') ?? DateTime.now(),
                progressPercent: progress,
              ));
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching active QR hunts: $e");
    }
    return activeList;
  }

  /// Logic: Scans 'child_activity_log' in RTDB for Multimedia.
  Future<List<ActiveChallengeModel>> fetchActiveMultimedia() async {
    List<ActiveChallengeModel> activeList = [];
    try {
      final snapshot = await _db.ref('child_activity_log').get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> usersData = snapshot.value as Map<dynamic, dynamic>;
        final now = DateTime.now();
        for (var userId in usersData.keys) {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          final String userName = userDoc.data()?['name'] ?? "Unknown Student";

          final Map<dynamic, dynamic> logs = usersData[userId];
          logs.forEach((logId, data) {
            final timestamp = DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now();
            if (now.difference(timestamp).inHours < 24) {
              activeList.add(ActiveChallengeModel(
                userId: userId,
                userName: userName,
                challengeTitle: data['title'] ?? "Multimedia Content",
                category: "Multimedia (${data['type'] ?? 'Content'})",
                status: data['type'] == 'Video' ? "Watching" : "Reading",
                lastActivity: timestamp,
                progressPercent: 100,
              ));
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching multimedia activity: $e");
    }
    return activeList;
  }

  /// Logic: Scans 'student_stem_submissions' in RTDB.
  /// Challenges with status 'pending' are flagged as Active for admin review.
  Future<List<ActiveChallengeModel>> fetchActiveStemSubmissions() async {
    List<ActiveChallengeModel> activeList = [];
    try {
      final snapshot = await _db.ref('student_stem_submissions').get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> usersData = snapshot.value as Map<dynamic, dynamic>;
        for (var userId in usersData.keys) {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          final String userName = userDoc.data()?['name'] ?? "Unknown Student";

          final Map<dynamic, dynamic> submissions = usersData[userId];
          submissions.forEach((submissionId, data) {
            // Logic: status 'pending' means it's an active item requiring admin attention
            if (data['status'] == 'pending') {
              activeList.add(ActiveChallengeModel(
                userId: userId,
                userName: userName,
                challengeTitle: data['challenge_title'] ?? "STEM Challenge",
                category: "STEM Challenge",
                status: "Pending Review",
                lastActivity: DateTime.tryParse(data['submitted_at'] ?? '') ?? DateTime.now(),
                progressPercent: 95, // Flagged near completion, awaiting points
              ));
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching STEM submissions: $e");
    }
    return activeList;
  }
}