import 'package:eco_venture_admin_portal/models/active_challenge_model.dart';
import 'package:eco_venture_admin_portal/services/active_challenge_service.dart';

/// Logic: Bridge between the ViewModel and the ActiveChallengeService.
/// Updated to call the unified fetcher to include Multimedia, QR, and STEM data.
class ActiveChallengeRepo {
  ActiveChallengeRepo._();
  static final ActiveChallengeRepo instance = ActiveChallengeRepo._();

  /// Logic: Fetches the unified list containing Quizzes, QR Hunts, Multimedia logs, and STEM submissions.
  /// This ensures the 'Active Challenges' card on the dashboard is fully populated.
  Future<List<ActiveChallengeModel>> getActiveChallenges() async {
    // Calling the unified fetcher from the service which now includes STEM tracking
    return await ActiveChallengeService.instance.fetchAllActiveChallenges();
  }
}