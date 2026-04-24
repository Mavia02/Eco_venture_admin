import 'package:eco_venture_admin_portal/services/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/qr_hunt_model.dart';
import '../models/quiz_topic_model.dart';
import '../models/stem_challenge_model.dart';
import '../models/story_model.dart';
import '../models/video_model.dart';

class FirebaseDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Node Names defined as constants for safety (Used for Quizzes)
  static const String _adminQuizNode = 'admin_quiz_content';
  static const String _publicQuizNode = 'public_quiz_content';

  // Helper to generate a new key
  String _generateKey() => _database.ref().push().key!;

  //  ADMIN VIDEO MODULE
  Future<void> addVideo(VideoModel video) async {
    try {
      String? adminId = await SharedPreferencesHelper.instance.getAdminId();
      adminId ??= _auth.currentUser?.uid;
      if (adminId == null) throw Exception("Admin ID not found.");

      final newKey = _generateKey();

      final videoWithMeta = video.copyWith(
        id: newKey,
        adminId: adminId,
      );

      final data = videoWithMeta.toMap();

      final updates = {
        'Admin/$adminId/videos/$newKey': data,
        'Public/Videos/$newKey': data,
      };

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to add video: $e');
    }
  }

  Future<void> updateVideo(VideoModel video) async {
    if (video.id == null) throw Exception("Video ID missing");

    try {
      String? adminId = video.adminId ??
          await SharedPreferencesHelper.instance.getAdminId();
      adminId ??= _auth.currentUser?.uid;
      if (adminId == null) throw Exception("Admin ID missing");

      final updatedVideo = video.copyWith(adminId: adminId);
      final data = updatedVideo.toMap();

      final updates = {
        'Admin/$adminId/videos/${video.id}': data,
        'Public/Videos/${video.id}': data,
      };

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to update video: $e');
    }
  }

  Future<void> deleteVideo(String videoId) async {
    try {
      String? adminId = await SharedPreferencesHelper.instance.getAdminId();
      adminId ??= _auth.currentUser?.uid;

      final updates = {
        'Admin/$adminId/videos/$videoId': null,
        'Public/Videos/$videoId': null,
      };

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to delete video: $e');
    }
  }

  Stream<List<VideoModel>> getVideosStream() async* {
    String? adminId = await SharedPreferencesHelper.instance.getAdminId();
    adminId ??= _auth.currentUser?.uid;

    if (adminId == null) {
      yield [];
      return;
    }

    yield* _database.ref('Admin/$adminId/videos').onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) return [];

      try {
        final map = data as Map<dynamic, dynamic>;
        final List<VideoModel> videos = [];

        map.forEach((key, value) {
          videos.add(VideoModel.fromMap(
            key.toString(),
            Map<String, dynamic>.from(value),
          ));
        });

        return videos;
      } catch (e) {
        print("Error parsing videos: $e");
        return [];
      }
    });
  }


  //  ADMIN STORY MODULE


  Future<void> addStory(StoryModel story) async {
    try {
      String? adminId = await SharedPreferencesHelper.instance.getAdminId();
      adminId ??= _auth.currentUser?.uid;
      if (adminId == null) throw Exception("Admin ID not found.");

      final newKey = _generateKey();

      final storyWithMeta = story.copyWith(
        id: newKey,
        adminId: adminId,
      );

      final data = storyWithMeta.toMap();

      final updates = {
        'Admin/$adminId/stories/$newKey': data,
        'Public/Stories/$newKey': data,
      };

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to add story: $e');
    }
  }

  Future<void> updateStory(StoryModel story) async {
    if (story.id == null) throw Exception("Story ID missing");

    try {
      String? adminId = story.adminId ??
          await SharedPreferencesHelper.instance.getAdminId();
      adminId ??= _auth.currentUser?.uid;

      final updatedStory = story.copyWith(adminId: adminId);
      final data = updatedStory.toMap();

      final updates = {
        'Admin/$adminId/stories/${story.id}': data,
        'Public/Stories/${story.id}': data,
      };

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to update story: $e');
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      String? adminId = await SharedPreferencesHelper.instance.getAdminId();
      adminId ??= _auth.currentUser?.uid;

      final updates = {
        'Admin/$adminId/stories/$storyId': null,
        'Public/Stories/$storyId': null,
      };

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to delete story: $e');
    }
  }

  Stream<List<StoryModel>> getStoriesStream() async* {
    String? adminId = await SharedPreferencesHelper.instance.getAdminId();
    adminId ??= _auth.currentUser?.uid;

    if (adminId == null) {
      yield [];
      return;
    }

    yield* _database.ref('Admin/$adminId/stories').onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) return [];

      try {
        final map = data as Map<dynamic, dynamic>;
        final List<StoryModel> stories = [];

        map.forEach((key, value) {
          stories.add(StoryModel.fromMap(
            key.toString(),
            Map<String, dynamic>.from(value),
          ));
        });

        return stories;
      } catch (e) {
        print("Error parsing stories: $e");
        return [];
      }
    });
  }



// QUiz Module

  // 1. ADD TOPIC
  Future<void> addQuizTopic(QuizTopicModel topic) async {
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      currentAdminId ??= _auth.currentUser?.uid;
      if (currentAdminId == null) throw Exception("Admin ID not found.");

      final String newKey = _generateKey();

      final topicWithMeta = topic.copyWith(
        id: newKey,
        creatorId: currentAdminId,
        createdBy: 'admin',
      );

      final Map<String, dynamic> data = topicWithMeta.toMap();
      final Map<String, dynamic> updates = {};

      // FIX: Use standard Admin Path
      // Path 1: Admin Node -> Admin/{id}/quizzes/{category}/{id}
      updates['Admin/$currentAdminId/quizzes/${topic.category}/$newKey'] = data;

      // Path 2: Public Node -> Public/Quizzes/{category}/{id}
      updates['Public/Quizzes/${topic.category}/$newKey'] = data;

      await _database.ref().update(updates);

    } catch (e) {
      throw Exception('Failed to add quiz topic: $e');
    }
  }

  // 2. UPDATE TOPIC
  Future<void> updateQuizTopic(QuizTopicModel topic) async {
    if (topic.id == null) throw Exception("Topic ID is missing");
    try {
      // We need the Original Creator ID to update the Admin path correctly
      // If editing own topic, use current ID. If editing someone else's, use stored creatorId.
      String? targetAdminId = topic.creatorId;

      if (targetAdminId.isEmpty) {
        targetAdminId = await SharedPreferencesHelper.instance.getAdminId();
        targetAdminId ??= _auth.currentUser?.uid;
      }

      final Map<String, dynamic> data = topic.toMap();
      final Map<String, dynamic> updates = {};

      // FIX: Update paths
      updates['Admin/$targetAdminId/quizzes/${topic.category}/${topic.id}'] = data;
      updates['Public/Quizzes/${topic.category}/${topic.id}'] = data;

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to update quiz topic: $e');
    }
  }

  // 3. DELETE TOPIC
  Future<void> deleteQuizTopic(String topicId, String category) async {
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      currentAdminId ??= _auth.currentUser?.uid;

      final Map<String, dynamic> updates = {};

      // FIX: Delete paths
      updates['Admin/$currentAdminId/quizzes/$category/$topicId'] = null;
      updates['Public/Quizzes/$category/$topicId'] = null;

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to delete quiz topic: $e');
    }
  }

// Inside getQuizTopicsStream
  Stream<List<QuizTopicModel>> getQuizTopicsStream(String category) async* {
    String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
    currentAdminId ??= _auth.currentUser?.uid;

    print("DEBUG: Fetching for AdminID: $currentAdminId, Category: $category"); // 1. Check ID

    if (currentAdminId == null) {
      yield [];
      return;
    }

    yield* _database.ref('Admin/$currentAdminId/quizzes/$category').onValue.map((event) {
      final data = event.snapshot.value;
      print("DEBUG: Data from Firebase: $data"); // 2. See raw data

      if (data == null) return [];

      try {
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
        final List<QuizTopicModel> topics = [];

        mapData.forEach((key, value) {
          final topicMap = Map<String, dynamic>.from(value as Map);
          topics.add(QuizTopicModel.fromMap(key.toString(), category, topicMap));
        });

        return topics;
      } catch (e) {
        print("DEBUG ERROR: Parsing failed: $e"); // 3. Catch crash
        return [];
      }
    });
  }
  // ==================================================
  // STEM CHALLENGES DATA METHODS (NEW)
  // ==================================================

  // 1. ADD STEM CHALLENGE
  Future<void> addStemChallenge(StemChallengeModel challenge) async {
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      if (currentAdminId == null || currentAdminId.isEmpty) {
        currentAdminId = _auth.currentUser?.uid;
      }
      if (currentAdminId == null) throw Exception("Admin ID not found.");

      final String newKey = _generateKey();

      // Add Meta Data
      final challengeWithMeta = challenge.copyWith(id: newKey, adminId: currentAdminId);
      final Map<String, dynamic> data = challengeWithMeta.toMap();

      final Map<String, dynamic> updates = {};

      // Path 1: Private Admin Node
      updates['Admin/$currentAdminId/stem_challenges/${challenge.category}/$newKey'] = data;

      // Path 2: Public User Node
      updates['Public/StemChallenges/${challenge.category}/$newKey'] = data;

      await _database.ref().update(updates);

    } catch (e) {
      throw Exception('Failed to add STEM challenge: $e');
    }
  }

  // 2. UPDATE STEM CHALLENGE
  Future<void> updateStemChallenge(StemChallengeModel challenge) async {
    if (challenge.id == null) throw Exception("Challenge ID is missing");
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      if (currentAdminId == null || currentAdminId.isEmpty) {
        currentAdminId = _auth.currentUser?.uid;
      }

      // Use existing adminId if present, else current
      final targetAdminId = challenge.adminId ?? currentAdminId;

      if (targetAdminId == null) throw Exception("Target Admin ID missing");

      final challengeWithMeta = challenge.copyWith(adminId: targetAdminId);
      final data = challengeWithMeta.toMap();

      final Map<String, dynamic> updates = {};

      // Path 1: Private Admin Node
      updates['Admin/$targetAdminId/stem_challenges/${challenge.category}/${challenge.id}'] = data;

      // Path 2: Public User Node
      updates['Public/StemChallenges/${challenge.category}/${challenge.id}'] = data;

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to update STEM challenge: $e');
    }
  }

  // 3. DELETE STEM CHALLENGE
  Future<void> deleteStemChallenge(String challengeId, String category) async {
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      if (currentAdminId == null || currentAdminId.isEmpty) {
        currentAdminId = _auth.currentUser?.uid;
      }
      if (currentAdminId == null) throw Exception("Admin ID not found.");

      final Map<String, dynamic> updates = {};

      // Set both paths to null
      updates['Admin/$currentAdminId/stem_challenges/$category/$challengeId'] = null;
      updates['Public/StemChallenges/$category/$challengeId'] = null;

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to delete STEM challenge: $e');
    }
  }

  // 4. FETCH: STREAM (Admin side)
  Stream<List<StemChallengeModel>> getStemChallengesStream(String category) async* {
    String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
    if (currentAdminId == null || currentAdminId.isEmpty) {
      currentAdminId = _auth.currentUser?.uid;
    }

    if (currentAdminId == null) {
      yield [];
      return;
    }

    // Listen to specific category under Admin node
    // If 'All' is selected, we might need a different strategy or iterate all cats.
    // For now, assuming filtering by specific category path.
    // If category is 'All', you typically fetch all sub-nodes, which is complex in RTDB structure.
    // Best practice: Fetch all if category == 'All', or specific if not.

    Query query;
    if (category == 'All') {
      // Fetching 'All' is tricky because they are nested by category.
      // We will fetch the parent 'stem_challenges' node and flatten it.
      query = _database.ref('Admin/$currentAdminId/stem_challenges');
    } else {
      query = _database.ref('Admin/$currentAdminId/stem_challenges/$category');
    }

    yield* query.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      try {
        final List<StemChallengeModel> challenges = [];
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;

        if (category == 'All') {
          // Structure: { Science: {id1: data}, Technology: {id2: data} }
          mapData.forEach((catKey, catData) {
            final innerMap = catData as Map<dynamic, dynamic>;
            innerMap.forEach((key, value) {
              final challengeMap = Map<String, dynamic>.from(value as Map);
              challenges.add(StemChallengeModel.fromMap(key.toString(), challengeMap));
            });
          });
        } else {
          // Structure: { id1: data, id2: data }
          mapData.forEach((key, value) {
            final challengeMap = Map<String, dynamic>.from(value as Map);
            challenges.add(StemChallengeModel.fromMap(key.toString(), challengeMap));
          });
        }

        return challenges;
      } catch (e) {
        print("Error parsing STEM stream: $e");
        return [];
      }
    });
  }

  // 5. FETCH SINGLE CHALLENGE
  Future<StemChallengeModel?> getSingleStemChallenge(String challengeId, String category) async {
    String? adminUid = await SharedPreferencesHelper.instance.getAdminId();
    adminUid ??= _auth.currentUser?.uid;
    if (adminUid == null) throw Exception("Admin ID missing");

    final snap = await _database
        .ref('Admin/$adminUid/stem_challenges/$category/$challengeId')
        .get();

    if (!snap.exists) return null;

    final data = Map<String, dynamic>.from(snap.value as Map);
    return StemChallengeModel.fromMap(challengeId, data);
  }

  // Qr Treasure Hunt

  // 1. ADD QR HUNT
  Future<void> addQrHunt(QrHuntModel hunt) async {
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      currentAdminId ??= _auth.currentUser?.uid;
      if (currentAdminId == null) throw Exception("Admin ID not found.");

      final String newKey = _generateKey();

      // Attach Metadata
      final huntWithMeta = hunt.copyWith(id: newKey, adminId: currentAdminId);
      final Map<String, dynamic> data = huntWithMeta.toMap();

      final Map<String, dynamic> updates = {};

      // Path 1: Admin Private Node
      updates['Admin/$currentAdminId/QrHunts/$newKey'] = data;

      // Path 2: Public User Node (Children read from here)
      updates['Public/QrHunts/$newKey'] = data;

      await _database.ref().update(updates);

    } catch (e) {
      throw Exception('Failed to add QR hunt: $e');
    }
  }

  // 2. UPDATE QR HUNT
  Future<void> updateQrHunt(QrHuntModel hunt) async {
    if (hunt.id == null) throw Exception("Hunt ID is missing");
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      currentAdminId ??= _auth.currentUser?.uid;

      // Use original creator ID if editing, or current admin
      final targetAdminId = hunt.adminId ?? currentAdminId;

      final Map<String, dynamic> data = hunt.toMap();
      final Map<String, dynamic> updates = {};

      updates['Admin/$targetAdminId/QrHunts/${hunt.id}'] = data;
      updates['Public/QrHunts/${hunt.id}'] = data;

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to update QR hunt: $e');
    }
  }

  // 3. DELETE QR HUNT
  Future<void> deleteQrHunt(String huntId) async {
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      currentAdminId ??= _auth.currentUser?.uid;

      final Map<String, dynamic> updates = {};

      updates['Admin/$currentAdminId/QrHunts/$huntId'] = null;
      updates['Public/QrHunts/$huntId'] = null;

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to delete QR hunt: $e');
    }
  }

  // 4. FETCH QR HUNTS (Stream)
  Stream<List<QrHuntModel>> getQrHuntsStream() async* {
    String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
    currentAdminId ??= _auth.currentUser?.uid;

    if (currentAdminId == null) {
      yield [];
      return;
    }

    yield* _database.ref('Admin/$currentAdminId/QrHunts').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      try {
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
        final List<QrHuntModel> hunts = [];

        mapData.forEach((key, value) {
          final huntMap = Map<String, dynamic>.from(value as Map);
          hunts.add(QrHuntModel.fromMap(key.toString(), huntMap));
        });

        // Sort by Newest first
        hunts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return hunts;
      } catch (e) {
        print("Error parsing QR hunts: $e");
        return [];
      }
    });
  }
}