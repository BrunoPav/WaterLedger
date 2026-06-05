import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_ledger/features/shared/domain/entities/user_model.dart';
import 'package:water_ledger/features/shared/domain/enums/user_role.dart';
import 'package:water_ledger/features/shared/domain/enums/user_status.dart';
import 'package:water_ledger/features/admin/domain/repositories/admin_repository.dart';

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

  // ── 4.6.3 Supervisión ─────────────────────────────────────────────────────

  @override
  Stream<List<Map<String, dynamic>>> creditRequestsStream() {
    return _db
        .collection('creditRequests')
        .snapshots()
        .map((snap) {
      final docs = snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        // Normalizar Timestamps a DateTime para consistencia en la UI
        for (final key in ['createdAt', 'updatedAt', 'submittedAt']) {
          if (data[key] is Timestamp) {
            data[key] = (data[key] as Timestamp).toDate();
          }
        }
        data['id'] = d.id;
        return data;
      }).toList();
      docs.sort((a, b) {
        final ta = a['createdAt'];
        final tb = b['createdAt'];
        if (ta is DateTime && tb is DateTime) return tb.compareTo(ta);
        return 0;
      });
      return docs;
    });
  }

  // ── 4.6.2 Asignación operativa ────────────────────────────────────────────

  @override
  Stream<List<UserModel>> activeAuditorsStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: UserRole.auditor.value)
        .where('status', isEqualTo: UserStatus.active.value)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  @override
  Future<void> assignAuditor({
    required String requestId,
    required String auditorId,
    required String auditorName,
  }) async {
    await _db.collection('creditRequests').doc(requestId).update({
      'assignedAuditorId': auditorId,
      'assignedAuditorName': auditorName,
      'status': 'underAudit',
      'updatedAt': FieldValue.serverTimestamp(),
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
