import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_ledger/features/certifier/domain/entities/certification_entity.dart';
import 'package:water_ledger/features/certifier/domain/enums/certification_status.dart';
import 'package:water_ledger/features/certifier/domain/repositories/certification_repository.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';

class FirebaseCertificationRepository implements CertificationRepository {
  final _certifications = FirebaseFirestore.instance.collection('certifications');
  final _requests = FirebaseFirestore.instance.collection('creditRequests');

  Map<String, dynamic> _normalize(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) return MapEntry(key, value.toDate());
      if (value is Map<String, dynamic>) return MapEntry(key, _normalize(value));
      return MapEntry(key, value);
    });
  }

  @override
  Future<CertificationEntity?> getCertification(String requestId) async {
    final doc = await _certifications.doc(requestId).get();
    if (!doc.exists || doc.data() == null) return null;
    return CertificationEntity.fromMap(_normalize(doc.data()!));
  }

  @override
  Stream<CertificationEntity?> certificationStream(String requestId) {
    return _certifications.doc(requestId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return CertificationEntity.fromMap(_normalize(snap.data()!));
    });
  }

  @override
  Future<void> issueCertificate({
    required String requestId,
    required String certifierId,
    required String notes,
  }) async {
    final now = DateTime.now();
    final entity = CertificationEntity(
      requestId: requestId,
      certifierId: certifierId,
      status: CertificationStatus.issued,
      notes: notes,
      issuedAt: now,
      createdAt: now,
      updatedAt: now,
    );

    final batch = FirebaseFirestore.instance.batch();
    batch.set(_certifications.doc(requestId), entity.toMap());
    batch.update(_requests.doc(requestId), {
      'status': RequestStatus.insured.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  @override
  Future<void> rejectCertification({
    required String requestId,
    required String certifierId,
    required String notes,
  }) async {
    final now = DateTime.now();
    final entity = CertificationEntity(
      requestId: requestId,
      certifierId: certifierId,
      status: CertificationStatus.rejected,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    final batch = FirebaseFirestore.instance.batch();
    batch.set(_certifications.doc(requestId), entity.toMap());
    batch.update(_requests.doc(requestId), {
      'status': RequestStatus.rejected.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
