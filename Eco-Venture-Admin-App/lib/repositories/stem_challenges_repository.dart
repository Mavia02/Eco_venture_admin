import '../models/stem_challenge_model.dart';
import '../services/firebase_database_service.dart';

class StemChallengesRepository {
  final FirebaseDatabaseService _db;

  StemChallengesRepository(this._db);

  // 1. Add New Challenge
  Future<void> addChallenge(StemChallengeModel challenge) async {
    await _db.addStemChallenge(challenge);
  }

  // 2. Update Existing Challenge
  Future<void> updateChallenge(StemChallengeModel challenge) async {
    await _db.updateStemChallenge(challenge);
  }

  // 3. Delete Challenge
  Future<void> deleteChallenge(String challengeId, String category) async {
    await _db.deleteStemChallenge(challengeId, category);
  }

  // 4. Watch Stream of Challenges (for a specific category or 'All')
  Stream<List<StemChallengeModel>> watchChallenges(String category) {
    return _db.getStemChallengesStream(category);
  }

  // 5. Get Single Challenge (Optional, good for direct editing)
  Future<StemChallengeModel?> getSingleChallenge(String challengeId, String category) {
    return _db.getSingleStemChallenge(challengeId, category);
  }
}