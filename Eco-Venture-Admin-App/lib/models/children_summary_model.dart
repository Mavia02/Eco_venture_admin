/// Logic: Simple data model to hold categorized child counts for the dashboard.
class ChildrenSummaryModel {
  final int totalChildren;
  final int teacherRegistered;
  final int directRegistered;

  ChildrenSummaryModel({
    required this.totalChildren,
    required this.teacherRegistered,
    required this.directRegistered,
  });

  factory ChildrenSummaryModel.empty() => ChildrenSummaryModel(
    totalChildren: 0,
    teacherRegistered: 0,
    directRegistered: 0,
  );
}