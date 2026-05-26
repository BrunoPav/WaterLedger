import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_ledger/core/domain/entities/user_model.dart';
import 'package:water_ledger/core/domain/enums/user_status.dart';
import 'package:water_ledger/core/domain/repositories/admin_repository.dart';

class FirebaseAdminRepository implements AdminRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<List<UserModel>> pendingUsersStream() {
    return _db
        .collection('users')
        .where('status', isEqualTo: UserStatus.pending.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<int> pendingApprovalsCount() {
    return _db
        .collection('users')
        .where('status', isEqualTo: UserStatus.pending.value)
        .snapshots()
        .map((snap) => snap.size);
  }

  @override
  Stream<int> collectionCount(String collectionPath) {
    return _db
        .collection(collectionPath)
        .snapshots()
        .map((snap) => snap.size);
  }

  @override
  Future<Map<String, dynamic>> fetchUserFullData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('Usuario no encontrado: $uid');
    }
    return doc.data()!;
  }

  @override
  Future<void> approveUser(String uid) async {
    await _db.collection('users').doc(uid).update({
      'status': UserStatus.active.value,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> rejectUser(String uid) async {
    await _db.collection('users').doc(uid).update({
      'status': UserStatus.rejected.value,
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }
}
