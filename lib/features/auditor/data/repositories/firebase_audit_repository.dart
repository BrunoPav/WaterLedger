import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_ledger/features/auditor/domain/entities/audit_entity.dart';
import 'package:water_ledger/features/auditor/domain/enums/audit_recommendation.dart';
import 'package:water_ledger/features/auditor/domain/enums/audit_status.dart';
import 'package:water_ledger/features/auditor/domain/repositories/audit_repository.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';

class FirebaseAuditRepository implements AuditRepository {
  final _audits = FirebaseFirestore.instance.collection('audits');
  final _requests = FirebaseFirestore.instance.collection('creditRequests');

  Map<String, dynamic> _normalize(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) return MapEntry(key, value.toDate());
      if (value is Map<String, dynamic>) return MapEntry(key, _normalize(value));
      if (value is List) {
        return MapEntry(
          key,
          value.map((e) => e is Map<String, dynamic> ? _normalize(e) : e).toList(),
        );
      }
      return MapEntry(key, value);
    });
  }

  @override
  Future<AuditEntity?> getAudit(String requestId) async {
    final doc = await _audits.doc(requestId).get();
    if (!doc.exists || doc.data() == null) return null;
    return AuditEntity.fromMap(_normalize(doc.data()!));
  }

  @override
  Stream<AuditEntity?> auditStream(String requestId) {
    return _audits.doc(requestId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return AuditEntity.fromMap(_normalize(snap.data()!));
    });
  }

  @override
  Future<void> startAudit({
    required String requestId,
    required String auditorId,
  }) async {
    final now = DateTime.now();
    final entity = AuditEntity(
      requestId: requestId,
      auditorId: auditorId,
      status: AuditStatus.inProgress,
      observations: [],
      createdAt: now,
      updatedAt: now,
    );
    await _audits.doc(requestId).set(entity.toMap());
  }

  @override
  Future<void> addObservation({
    required String requestId,
    required AuditObservation observation,
  }) async {
    await _audits.doc(requestId).update({
      'observations': FieldValue.arrayUnion([observation.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteObservation({
    required String requestId,
    required String observationId,
  }) async {
    final doc = await _audits.doc(requestId).get();
    if (!doc.exists || doc.data() == null) return;
    final audit = AuditEntity.fromMap(_normalize(doc.data()!));
    final updated = audit.observations.where((o) => o.id != observationId).toList();
    await _audits.doc(requestId).update({
      'observations': updated.map((o) => o.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> submitConclusion({
    required String requestId,
    required AuditConclusion conclusion,
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    batch.update(_audits.doc(requestId), {
      'conclusion': conclusion.toMap(),
      'status': AuditStatus.submitted.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (conclusion.recommendation == AuditRecommendation.approve) {
      batch.update(_requests.doc(requestId), {
        'status': RequestStatus.certified.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else if (conclusion.recommendation == AuditRecommendation.reject) {
      batch.update(_requests.doc(requestId), {
        'status': RequestStatus.rejected.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    // needsMoreInfo: creditRequest se mantiene en underAudit

    await batch.commit();
  }
}
