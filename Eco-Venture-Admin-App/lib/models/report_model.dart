class ReportModel {
  final String id;
  final String reporterId; // Logic: Added to track the User UID for RTDB pathing
  final String source; // 'child', 'teacher', 'system'
  final String reporterName;
  final String issueType; // 'Inappropriate Content', 'Bug', 'Bullying'
  final String severity; // 'High', 'Medium', 'Low'
  final String details;
  final String relatedContentId; // Optional
  final DateTime timestamp;
  final bool isResolved;

  ReportModel({
    required this.id,
    required this.reporterId, // Logic: Required for nested database updates
    required this.source,
    required this.reporterName,
    required this.issueType,
    required this.severity,
    required this.details,
    this.relatedContentId = '',
    required this.timestamp,
    this.isResolved = false,
  });

  // Logic: Updated to include reporterId
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporterId': reporterId,
      'source': source,
      'reporterName': reporterName,
      'issueType': issueType,
      'severity': severity,
      'details': details,
      'relatedContentId': relatedContentId,
      'timestamp': timestamp.toIso8601String(),
      'isResolved': isResolved,
    };
  }

  // Logic: Updated to include reporterId from Map
  factory ReportModel.fromMap(String id, Map<String, dynamic> map) {
    return ReportModel(
      id: id,
      reporterId: map['reporterId'] ?? '',
      source: map['source'] ?? 'system',
      reporterName: map['reporterName'] ?? 'Unknown',
      issueType: map['issueType'] ?? 'General',
      severity: map['severity'] ?? 'Low',
      details: map['details'] ?? '',
      relatedContentId: map['relatedContentId'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      isResolved: map['isResolved'] ?? false,
    );
  }

  // Logic: Preserved and updated copyWith
  ReportModel copyWith({
    String? id,
    String? reporterId,
    String? source,
    String? reporterName,
    String? issueType,
    String? severity,
    String? details,
    String? relatedContentId,
    DateTime? timestamp,
    bool? isResolved,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      source: source ?? this.source,
      reporterName: reporterName ?? this.reporterName,
      issueType: issueType ?? this.issueType,
      severity: severity ?? this.severity,
      details: details ?? this.details,
      relatedContentId: relatedContentId ?? this.relatedContentId,
      timestamp: timestamp ?? this.timestamp,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  // Logic: Preserved your mock factory for testing
  factory ReportModel.mock(int index) {
    return ReportModel(
      id: 'report_$index',
      reporterId: 'user_$index',
      source: index % 2 == 0 ? 'Child' : 'Teacher',
      reporterName: index % 2 == 0 ? 'Ali Khan' : 'Ms. Fatima',
      issueType: index % 3 == 0 ? 'Inappropriate Content' : 'Bug Report',
      severity: index % 3 == 0 ? 'High' : (index % 2 == 0 ? 'Medium' : 'Low'),
      details: 'This quiz has a spelling mistake on Q3. Please fix it.',
      timestamp: DateTime.now().subtract(Duration(hours: index * 2)),
      isResolved: false,
    );
  }
}