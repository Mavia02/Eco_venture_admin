import 'package:firebase_database/firebase_database.dart';
import 'package:eco_venture_admin_portal/models/modules_uploaded_model.dart';

/// Logic: Exhaustive discovery service to aggregate ALL learning modules from RTDB.
/// It addresses inconsistencies in naming conventions (Admin vs Teacher vs Global nodes).
class ModuleService {
  ModuleService._();
  static final ModuleService instance = ModuleService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Future<List<ModuleContentModel>> fetchAllModules() async {
    List<ModuleContentModel> allModules = [];

    try {
      // 1. DISCOVER ADMIN TREE (Admin -> {uid} -> [quizzes, QrHunts, stem, stories, etc])
      final adminSnapshot = await _db.ref('Admin').get();
      if (adminSnapshot.exists) {
        final adminData = adminSnapshot.value as Map<dynamic, dynamic>;
        adminData.forEach((adminId, content) {
          if (content is Map) {
            _recursiveDiscovery(content, 'admin', allModules);
          }
        });
      }

      // 2. DISCOVER TEACHER TREE (Teacher_Content -> {uid} -> [Multimedia, Quizzes, Stem, etc])
      final teacherSnapshot = await _db.ref('Teacher_Content').get();
      if (teacherSnapshot.exists) {
        final teacherData = teacherSnapshot.value as Map<dynamic, dynamic>;
        teacherData.forEach((teacherId, content) {
          if (content is Map) {
            _recursiveDiscovery(content, 'teacher', allModules);
          }
        });
      }

      // 3. DISCOVER GLOBAL ROOT NODES (For content not nested under a UID)
      // This catches the "Global Stories" and "Global Videos" you add from the Admin panel.
      await _scanGlobalRootNodes(allModules);

      return allModules;
    } catch (e) {
      print("Error in exhaustive module fetch: $e");
      return [];
    }
  }

  /// Logic: Scans root nodes like 'stories' or 'videos'.
  /// These are usually global content added directly by the Admin.
  Future<void> _scanGlobalRootNodes(List<ModuleContentModel> list) async {
    final Map<String, String> roots = {
      'Quizzes': 'Interactive Quiz',
      'stem_challenges': 'STEM Challenges',
      'StemChallenges': 'STEM Challenges',
      'QrHunts': 'QR Based',
      'stories': 'Multimedia Content',
      'videos': 'Multimedia Content',
    };

    for (var entry in roots.entries) {
      final snap = await _db.ref(entry.key).get();
      if (snap.exists) {
        String? specificType;
        if (entry.key == 'stories') specificType = 'Story';
        if (entry.key == 'videos') specificType = 'Video';

        _extractItemData(snap.value, entry.value, 'admin', list, type: specificType);
      }
    }
  }

  /// Logic: Helper to identify the category by node key names (case-insensitive).
  void _recursiveDiscovery(Map<dynamic, dynamic> node, String role, List<ModuleContentModel> list) {
    node.forEach((key, value) {
      final String k = key.toString().toLowerCase();

      if (k.contains('quiz')) {
        _extractItemData(value, 'Interactive Quiz', role, list);
      }
      else if (k.contains('stem')) {
        _extractItemData(value, 'STEM Challenges', role, list);
      }
      else if (k.contains('hunt') || k.contains('qr')) {
        _extractItemData(value, 'QR Based', role, list);
      }
      else if (k.contains('multimedia') || k.contains('storie') || k.contains('video')) {
        // Multimedia can be nested (Multimedia -> Stories -> ID) or flat (Multimedia -> ID)
        if (value is Map && value.values.any((v) => v is Map)) {
          value.forEach((subType, items) {
            _extractItemData(items, 'Multimedia Content', role, list,
                type: subType.toString().replaceAll('ies', 'y').replaceAll('s', ''));
          });
        } else {
          _extractItemData(value, 'Multimedia Content', role, list);
        }
      }
    });
  }

  /// Logic: The core data extractor that handles mixed data formats (Folders vs Items).
  void _extractItemData(dynamic data, String category, String defaultRole, List<ModuleContentModel> list, {String? type}) {
    if (data is! Map) return;

    data.forEach((idOrCat, itemData) {
      if (itemData is Map) {
        // CASE A: This is a Category Folder (e.g. "Animals" -> { ID1: {...} })
        // We detect this by checking if the children are also Maps.
        if (itemData.values.any((v) => v is Map)) {
          itemData.forEach((id, details) {
            if (details is Map) _processAndAddToList(id, details, category, defaultRole, list, type: type);
          });
        }
        // CASE B: This is a direct Module Item (e.g. "ID123" -> { title: "..." })
        else {
          _processAndAddToList(idOrCat.toString(), itemData, category, defaultRole, list, type: type);
        }
      }
    });
  }

  /// Logic: Maps varied database fields (title vs topicName vs name) to a unified model.
  void _processAndAddToList(String id, Map<dynamic, dynamic> details, String category, String defaultRole, List<ModuleContentModel> list, {String? type}) {
    // Prevent duplicates in the analytics list
    if (list.any((m) => m.id == id)) return;

    // Support every possible key name found in your AddQuiz, AddStory, and AddVideo screens
    final String title = details['title'] ??
        details['topic_name'] ??
        details['topicName'] ??
        details['name'] ??
        details['story_title'] ??
        'Untitled Item';

    // Identify the role using 'createdBy' or 'role' fields, fallback to path-based role
    final dynamic rawRole = details['createdBy'] ??
        details['role'] ??
        details['created_by_role'] ??
        defaultRole;

    final String finalRole = rawRole.toString().toLowerCase().contains('admin') ? 'admin' : 'teacher';

    list.add(ModuleContentModel(
      id: id,
      title: title,
      category: category,
      uploadedByRole: finalRole,
      authorName: finalRole == 'admin' ? 'Admin' : 'Teacher',
      type: type ?? details['type'],
    ));
  }
}