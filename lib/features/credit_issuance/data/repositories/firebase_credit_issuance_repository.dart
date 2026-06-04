import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/document_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/water_project_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/credit_issuance/domain/repositories/credit_issuance_repository.dart';

class FirebaseCreditIssuanceRepository implements CreditIssuanceRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('creditRequests');
  final Random _random = Random();

  String _generateRequestId() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final suffix = _random.nextInt(999999).toString().padLeft(6, '0');
    return 'REQ_${date}_$suffix';
  }

  // Firestore returns Timestamps for date fields; convert them to DateTime
  // before passing to entity fromMap so domain stays infrastructure-free.
  Map<String, dynamic> _normalize(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) return MapEntry(key, value.toDate());
      if (value is Map<String, dynamic>) return MapEntry(key, _normalize(value));
      if (value is List) {
        return MapEntry(
          key,
          value
              .map((e) =>
                  e is Map<String, dynamic> ? _normalize(e) : e)
              .toList(),
        );
      }
      return MapEntry(key, value);
    });
  }

  @override
  Future<CreditRequestEntity> createDraft({required String companyId}) async {
    final id = _generateRequestId();
    final now = DateTime.now();
    final entity = CreditRequestEntity(
      id: id,
      issuerCompanyId: companyId,
      proyectoId: '',
      creditAmount: 0.0,
      status: RequestStatus.draft,
      createdAt: now,
    );
    await _col.doc(id).set(entity.toMap());
    return entity;
  }

  @override
  Future<void> updateProjectInfo({
    required String requestId,
    required WaterProjectEntity project,
  }) async {
    await _col.doc(requestId).update({
      'project': project.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateRoadmap({
    required String requestId,
    required RoadmapEntity roadmap,
  }) async {
    await _col.doc(requestId).update({
      'roadmap': roadmap.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> uploadDocuments({
    required String requestId,
    required List<DocumentEntity> documents,
  }) async {
    await _col.doc(requestId).update({
      'documents': FieldValue.arrayUnion(
        documents.map((d) => d.toMap()).toList(),
      ),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> submitRequest({required String requestId}) async {
    await _col.doc(requestId).update({
      'status': RequestStatus.pending.name,
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<CreditRequestEntity> getRequestById(String requestId) async {
    final doc = await _col.doc(requestId).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Solicitud $requestId no encontrada.');
    }
    return CreditRequestEntity.fromMap(_normalize(doc.data()!));
  }

  @override
  Future<List<CreditRequestEntity>> getCompanyRequests(String companyId) async {
    final snap = await _col
        .where('issuerCompanyId', isEqualTo: companyId)
        .get();
    final entities = snap.docs
        .map((d) => CreditRequestEntity.fromMap(_normalize(d.data())))
        .toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entities;
  }

  @override
  Future<void> updateCreditAmount({
    required String requestId,
    required double amount,
  }) async {
    await _col.doc(requestId).update({
      'creditAmount': amount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteDraft(String requestId) async {
    await _col.doc(requestId).delete();
  }

  @override
  Future<List<CreditRequestEntity>> getAuditorAssignments(String auditorId) async {
    final snap = await _col
        .where('assignedAuditorId', isEqualTo: auditorId)
        .get();
    final entities = snap.docs
        .map((d) => CreditRequestEntity.fromMap(_normalize(d.data())))
        .toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entities;
  }

  @override
  Future<List<CreditRequestEntity>> getCertifiedRequests() async {
    final snap = await _col
        .where('status', isEqualTo: RequestStatus.certified.name)
        .get();
    final entities = snap.docs
        .map((d) => CreditRequestEntity.fromMap(_normalize(d.data())))
        .toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entities;
  }

  @override
  Future<List<CreditRequestEntity>> getInsuredRequests() async {
    final snap = await _col
        .where('status', isEqualTo: RequestStatus.insured.name)
        .get();
    final entities = snap.docs
        .map((d) => CreditRequestEntity.fromMap(_normalize(d.data())))
        .toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entities;
  }

  @override
  Future<List<CreditRequestEntity>> getValuedRequests() async {
    final snap = await _col
        .where('status', isEqualTo: RequestStatus.valued.name)
        .get();
    final entities = snap.docs
        .map((d) => CreditRequestEntity.fromMap(_normalize(d.data())))
        .toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entities;
  }
}
