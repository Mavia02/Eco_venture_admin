class ActiveChallengeModel {
  final String userId;
  final String userName; // We will fetch this from Firestore using userId
  final String challengeTitle;
  final String category;
  final String status; // "In Progress" or "Needs Improvement"
  final DateTime lastActivity;
  final double progressPercent;

  ActiveChallengeModel({
    required this.userId,
    required this.userName,
    required this.challengeTitle,
    required this.category,
    required this.status,
    required this.lastActivity,
    required this.progressPercent,
  });
}