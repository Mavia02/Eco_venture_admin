/// Logic: Represents the aggregated progress data across all learning modules.
class AvgProgressModel {
  final double globalAverage;
  final double quizAverage;
  final double stemAverage;
  final double qrAverage;
  final double multimediaEngagement;
  final int totalStudentsTracked;

  AvgProgressModel({
    required this.globalAverage,
    required this.quizAverage,
    required this.stemAverage,
    required this.qrAverage,
    required this.multimediaEngagement,
    required this.totalStudentsTracked,
  });

  factory AvgProgressModel.empty() => AvgProgressModel(
    globalAverage: 0.0,
    quizAverage: 0.0,
    stemAverage: 0.0,
    qrAverage: 0.0,
    multimediaEngagement: 0.0,
    totalStudentsTracked: 0,
  );
}

/// Logic: Detailed breakdown for individual students in the Detail View.
class StudentProgressDetail {
  final String userId;
  final String userName;
  final double overallProgress;
  final Map<String, double> moduleBreakdown;

  StudentProgressDetail({
    required this.userId,
    required this.userName,
    required this.overallProgress,
    required this.moduleBreakdown,
  });
}