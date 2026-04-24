import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_venture_admin_portal/models/admin_model.dart';

class AdminFirestoreService {
  AdminFirestoreService._();
  static final AdminFirestoreService getInstance = AdminFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'Admins';

  /// Logic: Fetches all users from the 'users' collection who have the 'role' child.
  Future<List<Map<String, dynamic>>> getAllChildren() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'child')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching children from Firestore: $e");
      return [];
    }
  }

  /// Logic: Fetches all teachers from the 'users' collection.
  /// This allows us to map teacher_id to a readable name.
  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching teachers from Firestore: $e");
      return [];
    }
  }

  // --- 🔒 Admin Profile Management Logic Preserved ---

  Future<AdminModel?> createBasicAdminProfile({
    required String aid,
    required String email,
  }) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(aid);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        await docRef.set({
          'aid': aid,
          'email': email,
          'name': '',
          'imageUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final newSnap = await docRef.get();
      return AdminModel.fromMap(newSnap.data()!);
    } catch (e) {
      print("Error creating admin profile: $e");
      return null;
    }
  }

  Future<bool> updateAdminName(String aid, String name) async {
    try {
      await _firestore.collection(_collectionName).doc(aid).update({
        'name': name,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAdminImage(String aid, String imageUrl) async {
    try {
      await _firestore.collection(_collectionName).doc(aid).update({
        'imageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAdminEmail(String aid, String email) async {
    try {
      await _firestore.collection(_collectionName).doc(aid).update({
        'email': email,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<AdminModel?> getAdminProfile(String aid) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(aid).get();
      if (doc.exists && doc.data() != null) {
        return AdminModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteAdminData(String aid) async {
    try {
      final adminDoc = _firestore.collection(_collectionName).doc(aid);
      final docSnapshot = await adminDoc.get();

      if (docSnapshot.exists) {
        await adminDoc.delete();
      }
    } catch (e) {
      throw Exception("Failed to delete admin data: $e");
    }
  }
}
