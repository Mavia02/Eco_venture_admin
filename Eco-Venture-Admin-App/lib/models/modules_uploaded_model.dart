class ModuleContentModel {
  final String id;
  final String title;
  final String category; // Interactive Quiz, STEM Challenges, QR Based, Multimedia
  final String uploadedByRole; // 'admin' or 'teacher'
  final String authorName;
  final String? type; // 'Video' or 'Story'

  ModuleContentModel({
    required this.id,
    required this.title,
    required this.category,
    required this.uploadedByRole,
    required this.authorName,
    this.type,
  });
}

class ModuleStatsModel {
  final int totalCount;
  final int adminCount;
  final int teacherCount;
  final List<ModuleContentModel> adminModules;
  final List<ModuleContentModel> teacherModules;
  final Map<String, int> categoryCounts;

  ModuleStatsModel({
    required this.totalCount,
    required this.adminCount,
    required this.teacherCount,
    required this.adminModules,
    required this.teacherModules,
    required this.categoryCounts,
  });

  factory ModuleStatsModel.empty() => ModuleStatsModel(
    totalCount: 0,
    adminCount: 0,
    teacherCount: 0,
    adminModules: [],
    teacherModules: [],
    categoryCounts: {},
  );
}