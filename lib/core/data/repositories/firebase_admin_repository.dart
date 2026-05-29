import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_ledger/core/domain/entities/user_model.dart';
import 'package:water_ledger/core/domain/enums/user_status.dart';
import 'package:water_ledger/core/domain/repositories/admin_repository.dart';

class FirebaseAdminRepository implements AdminRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<List<UserModel>> pendingUsersStream() {
    // Antes ordenábamos por createdAt desde Firestore con .orderBy('createdAt', descending: true),
    // pero la combinación where(status) + orderBy(createdAt) requiere un índice compuesto que
    // tirador 'failed-precondition' hasta que se cree manualmente en Firebase Console.
    // Para evitar ese paso de setup, ordenamos en cliente. Como las solicitudes pendientes son
    // un set acotado (decenas, no miles), el cost de ordenar en memoria es despreciable.
    // Si en el futuro el volumen crece, mover el orden al servidor y crear el índice.
    return _db
        .collection('users')
        .where('status', isEqualTo: UserStatus.pending.value)
        .snapshots()
        .map((snap) {
      final users = snap.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    });
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
    final now = FieldValue.serverTimestamp();
    await _db.collection('users').doc(uid).update({
      'status': UserStatus.active.value,
      'approvedAt': now,
      // `decisionAt` es el timestamp unificado para approve/reject — se usa para
      // ordenar el feed de "Recent Audit Log" del admin profile.
      'decisionAt': now,
    });
  }

  @override
  Future<void> rejectUser(String uid) async {
    final now = FieldValue.serverTimestamp();
    await _db.collection('users').doc(uid).update({
      'status': UserStatus.rejected.value,
      'rejectedAt': now,
      'decisionAt': now,
    });
  }

  @override
  Stream<List<AdminDecisionRecord>> recentDecisionsStream({int limit = 5}) {
    // orderBy con descending sobre decisionAt filtra automáticamente los docs
    // que no tienen ese campo (usuarios no procesados aún). Para los registros
    // procesados antes de que se introdujera `decisionAt`, no aparecerán acá —
    // limitación aceptada porque el log se empieza a llenar desde ahora.
    return _db
        .collection('users')
        .orderBy('decisionAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AdminDecisionRecord.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
