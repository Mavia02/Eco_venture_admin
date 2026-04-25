import 'package:firebase_database/firebase_database.dart';
import 'package:eco_venture_admin_portal/models/modules_uploaded_model.dart';

/// Logic: Final Robust Recursive Service to aggregate every learning module.
/// This version is "Structure-Agnostic" and "Path-Resilient".
/// It crawls the RTDB tree to find items based on data signatures and dynamic context updating.
class ModuleService {
  ModuleService._();
  static final ModuleService instance = ModuleService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Future<List<ModuleContentModel>> fetchAllModules() async {
    List<ModuleContentModel> allModules = [];

    try {
      // 1. CRAWL ADMIN TREE (Dives into Admin -> UID -> Folder -> ID)
      final adminSnapshot = await _db.ref('Admin').get();
      if (adminSnapshot.exists) {
        _crawlNode(adminSnapshot.value, 'admin', allModules);
      }

      // 2. CRAWL TEACHER TREE (Dives into Teacher_Content -> UID -> Multimedia/Quizzes -> ID)
      final teacherSnapshot = await _db.ref('Teacher_Content').get();
      if (teacherSnapshot.exists) {
        _crawlNode(teacherSnapshot.value, 'teacher', allModules);
      }

      // 3. CRAWL GLOBAL ROOTS (Catches root-level modules not tied to a UID tree)
      final List<String> globalRoots = [
        'Quizzes',
        'stem_challenges',
        'StemChallenges',
        'QrHunts',
        'stories',
        'videos',
        'Multimedia',
        'Tasks'
      ];

      for (var path in globalRoots) {
        final snap = await _db.ref(path).get();
        if (snap.exists) {
          _crawlNode(snap.value, 'admin', allModules, pathContext: path);
        }
      }

      return allModules;
    } catch (e) {
      print("Error in exhaustive module crawl: $e");
      return [];
    }
  }

  /// Logic: The Recursive Crawler.
  /// It visits every node. It dynamically updates the pathContext when it hits
  /// a folder name that indicates a module type (quiz, stem, hunt, multimedia).
  void _crawlNode(dynamic data, String defaultRole, List<ModuleContentModel> list, {String? pathContext}) {
    if (data is! Map) return;

    data.forEach((key, value) {
      if (value is Map) {
        final String currentKey = key.toString().toLowerCase();

        // Logic: Update context if current key is a type-indicator
        String? nextContext = pathContext;
        if (currentKey.contains('quiz') ||
            currentKey.contains('stem') ||
            currentKey.contains('hunt') ||
            currentKey.contains('qr') ||
            currentKey.contains('multimedia') ||
            currentKey.contains('storie') ||
            currentKey.contains('video')) {
          nextContext = key.toString();
        }

        // Check if this map represents a specific module item
        if (_isModuleItem(value)) {
          _addModuleToList(key.toString(), value, defaultRole, list, nextContext);
        }
        // If not an item, it's a folder (UID, Category, or Group). Recurse.
        else {
          _crawlNode(value, defaultRole, list, pathContext: nextContext);
        }
      }
    });
  }

  /// Logic: Detects if a Map is a Module based on known fields from your Add screens.
  bool _isModuleItem(Map<dynamic, dynamic> map) {
    return map.containsKey('title') ||
        map.containsKey('topic_name') ||
        map.containsKey('topicName') ||
        map.containsKey('story_title') ||
        map.containsKey('videoUrl') ||
        map.containsKey('video_url') ||
        map.containsKey('levels') || // Quiz Signature
        map.containsKey('clues') ||  // QR Hunt Signature
        map.containsKey('task_description'); // Fallback signature
  }

  void _addModuleToList(String id, Map<dynamic, dynamic> details, String defaultRole, List<ModuleContentModel> list, String? context) {
    // 1. Uniqueness Guard: Prevent double-counting if an item is seen in two paths
    if (list.any((m) => m.id == id)) return;

    // 2. Identify Category
    String category = _identifyCategory(details, context);

    // 3. Resolve Title: Check all variations
    final String title = details['title'] ??
        details['topic_name'] ??
        details['topicName'] ??
        details['story_title'] ??
        details['name'] ??
        details['quiz_title'] ??
        'Untitled Item';

    // 4. Resolve Role: Check for 'createdBy' or 'role' fields
    final dynamic rawRole = details['createdBy'] ??
        details['role'] ??
        details['created_by_role'] ??
        details['uploadedByRole'] ??
        defaultRole;

    final String finalRole = rawRole.toString().toLowerCase().contains('admin') ? 'admin' : 'teacher';

    list.add(ModuleContentModel(
      id: id,
      title: title,
      category: category,
      uploadedByRole: finalRole,
      authorName: finalRole == 'admin' ? 'Admin' : 'Teacher',
      type: details['type'] ?? _inferSubtype(category, context, details),
    ));
  }

  /// Logic: Strong category identification.
  /// Structural keys (levels/clues) take highest priority to avoid mislabeling.
  String _identifyCategory(Map<dynamic, dynamic> details, String? context) {
    // Priority 1: Structural Signatures
    if (details.containsKey('levels')) return 'Interactive Quiz';
    if (details.containsKey('clues')) return 'QR Based';

    // Priority 2: Explicit Internal Category Field
    if (details.containsKey('category')) {
      final String cat = details['category'].toString().toLowerCase();
      if (cat.contains('quiz')) return 'Interactive Quiz';
      if (cat.contains('stem')) return 'STEM Challenges';
      if (cat.contains('qr') || cat.contains('hunt')) return 'QR Based';
    }

    // Priority 3: Dynamic Path Context
    final String ctx = (context ?? '').toLowerCase();
    if (ctx.contains('quiz')) return 'Interactive Quiz';
    if (ctx.contains('stem')) return 'STEM Challenges';
    if (ctx.contains('hunt') || ctx.contains('qr')) return 'QR Based';

    return 'Multimedia Content';
  }

  String? _inferSubtype(String category, String? context, Map<dynamic, dynamic> details) {
    if (category != 'Multimedia Content') return null;
    final String ctx = (context ?? '').toLowerCase();
    if (ctx.contains('video') || details.containsKey('videoUrl') || details.containsKey('video_url')) return 'Video';
    if (ctx.contains('audio')) return 'Audio';
    return 'Story';
  }
}