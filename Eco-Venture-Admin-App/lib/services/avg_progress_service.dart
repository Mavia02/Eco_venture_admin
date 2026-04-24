import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_venture_admin_portal/models/avg_progress_model.dart';

/// Logic: Service responsible for calculating the global and module-specific progress.
class ProgressAggregationService {
  ProgressAggregationService._();
  static final ProgressAggregationService instance = ProgressAggregationService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Logic: Calculates the Global Average with equal weightage (25%) for each module.
  Future<AvgProgressModel> calculateGlobalStats() async {
    try {
      final results = await Future.wait([
        _calculateQuizAvg(),
        _calculateSTEMAvg(),
        _calculateQRAvg(),
        _calculateMultimediaAvg(),
      ]);

      double quizAvg = results[0];
      double stemAvg = results[1];
      double qrAvg = results[2];
      double multiAvg = results[3];

      // Logic: Applying equal weight (25% each) as requested ("50/50 for every module")
      double globalAvg = (quizAvg * 0.25) + (stemAvg * 0.25) + (qrAvg * 0.25) + (multiAvg * 0.25);

      // Get student count from Firestore for the model
      final studentCountSnap = await _firestore.collection('users').where('role', isEqualTo: 'child').count().get();

      return AvgProgressModel(
        globalAverage: globalAvg,
        quizAverage: quizAvg,
        stemAverage: stemAvg,
        qrAverage: qrAvg,
        multimediaEngagement: multiAvg,
        totalStudentsTracked: studentCountSnap.count ?? 0,
      );
    } catch (e) {
      print("Error aggregating progress: $e");
      return AvgProgressModel.empty();
    }
  }

  Future<double> _calculateQuizAvg() async {
    final snap = await _db.ref('child_quiz_progress').get();
    if (!snap.exists) return 0.0;

    double totalPercent = 0;
    int count = 0;

    final Map<dynamic, dynamic> data = snap.value as Map<dynamic, dynamic>;
    data.forEach((uId, cats) {
      if (cats is Map) {
        cats.forEach((cat, topics) {
          if (topics is Map) {
            topics.forEach((top, levels) {
              if (levels is Map) {
                levels.forEach((l, val) {
                  totalPercent += (val['attempt_percentage'] ?? 0).toDouble();
                  count++;
                });
              }
            });
          }
        });
      }
    });
    return count == 0 ? 0.0 : totalPercent / count;
  }

  Future<double> _calculateSTEMAvg() async {
    final snap = await _db.ref('student_stem_submissions').get();
    if (!snap.exists) return 0.0;

    int approved = 0;
    int total = 0;

    final Map<dynamic, dynamic> data = snap.value as Map<dynamic, dynamic>;
    data.forEach((uId, subs) {
      if (subs is Map) {
        subs.forEach((sId, val) {
          if (val['status'] == 'approved') approved++;
          total++;
        });
      }
    });
    return total == 0 ? 0.0 : (approved / total) * 100;
  }

  Future<double> _calculateQRAvg() async {
    final snap = await _db.ref('child_qr_progress').get();
    if (!snap.exists) return 0.0;

    double totalProgress = 0;
    int count = 0;

    final Map<dynamic, dynamic> data = snap.value as Map<dynamic, dynamic>;
    data.forEach((uId, hunts) {
      if (hunts is Map) {
        hunts.forEach((hId, val) {
          int current = val['current_clue_index'] ?? 0;
          int total = val['total_clues'] ?? 1;
          totalProgress += (current / total) * 100;
          count++;
        });
      }
    });
    return count == 0 ? 0.0 : totalProgress / count;
  }

  Future<double> _calculateMultimediaAvg() async {
    final snap = await _db.ref('child_activity_log').get();
    if (!snap.exists) return 0.0;

    final Map<dynamic, dynamic> data = snap.value as Map<dynamic, dynamic>;
    int activeUserCount = data.keys.length;

    final totalUserSnap = await _firestore.collection('users').where('role', isEqualTo: 'child').count().get();
    int total = totalUserSnap.count ?? 1;

    return (activeUserCount / total * 100).clamp(0, 100);
  }
}