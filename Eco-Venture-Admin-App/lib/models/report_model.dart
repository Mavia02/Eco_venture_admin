class ReportModel {
  final String id;
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
    required this.source,
    required this.reporterName,
    required this.issueType,
    required this.severity,
    required this.details,
    this.relatedContentId = '',
    required this.timestamp,
    this.isResolved = false,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
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

  // Create object from Map
  factory ReportModel.fromMap(String id, Map<String, dynamic> map) {
    return ReportModel(
      id: id,
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

  // CopyWith for immutable updates
  ReportModel copyWith({
    String? id,
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

  // Factory for mock data (replace with fromMap later)
  factory ReportModel.mock(int index) {
    return ReportModel(
      id: 'report_$index',
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