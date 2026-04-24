import '../models/qr_hunt_model.dart';
import '../services/firebase_database_service.dart';

class AdminTreasureHuntRepository {
  final FirebaseDatabaseService _db;

  AdminTreasureHuntRepository(this._db);

  Future<void> addHunt(QrHuntModel hunt) async {
    await _db.addQrHunt(hunt);
  }

  Future<void> updateHunt(QrHuntModel hunt) async {
    await _db.updateQrHunt(hunt);
  }

  Future<void> deleteHunt(String huntId) async {
    await _db.deleteQrHunt(huntId);
  }

  Stream<List<QrHuntModel>> watchHunts() {
    return _db.getQrHuntsStream();
  }
}