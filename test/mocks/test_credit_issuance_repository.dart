import 'dart:math';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/document_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/water_project_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/credit_issuance/domain/repositories/credit_issuance_repository.dart';

class TestCreditIssuanceRepository implements CreditIssuanceRepository {
  final List<CreditRequestEntity> _requests = [];
  final Random _random = Random();

  String _generateRequestId() {
    final now = DateTime.now();
    final dateCode =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomSuffix = _random.nextInt(999999).toString().padLeft(6, '0');
    return 'REQ_${dateCode}_$randomSuffix';
  }

  @override
  Future<CreditRequestEntity> createDraft({required String companyId}) async {
    final draft = CreditRequestEntity(
      id: _generateRequestId(),
      issuerCompanyId: companyId,
      proyectoId: '',
      creditAmount: 0.0,
      status: RequestStatus.draft,
      createdAt: DateTime.now(),
    );
    _requests.add(draft);
    return draft;
  }

  @override
  Future<void> updateRoadmap({
    required String requestId,
    required RoadmapEntity roadmap,
  }) async {
    _requests.firstWhere((r) => r.id == requestId).roadmap = roadmap;
  }

  @override
  Future<void> updateProjectInfo({
    required String requestId,
    required WaterProjectEntity project,
  }) async {
    // No-op en memoria: el proyecto se guarda embebido en la entidad en Firestore
  }

  @override
  Future<void> uploadDocuments({
    required String requestId,
    required List<DocumentEntity> documents,
  }) async {
    _requests.firstWhere((r) => r.id == requestId).documents.addAll(documents);
  }

  @override
  Future<void> submitRequest({required String requestId}) async {
    final req = _requests.firstWhere((r) => r.id == requestId);
    req.status = RequestStatus.pending;
    req.updatedAt = DateTime.now();
  }

  @override
  Future<CreditRequestEntity> getRequestById(String requestId) async =>
      _requests.firstWhere((r) => r.id == requestId);

  @override
  Future<List<CreditRequestEntity>> getCompanyRequests(String companyId) async =>
      _requests.where((r) => r.issuerCompanyId == companyId).toList();

  @override
  Stream<List<CreditRequestEntity>> watchCompanyRequests(String companyId) =>
      Stream.value(
        _requests.where((r) => r.issuerCompanyId == companyId).toList(),
      );

  @override
  Future<void> updateCreditAmount({
    required String requestId,
    required double amount,
  }) async {
    _requests.firstWhere((r) => r.id == requestId).creditAmount = amount;
  }

  @override
  Future<void> deleteDraft(String requestId) async {
    _requests.removeWhere(
      (r) => r.id == requestId && r.status == RequestStatus.draft,
    );
  }

  @override
  Future<List<CreditRequestEntity>> getAuditorAssignments(String auditorId) async => [];

  @override
  Future<List<CreditRequestEntity>> getCertifiedRequests() async =>
      _requests.where((r) => r.status == RequestStatus.certified).toList();

  @override
  Future<List<CreditRequestEntity>> getInsuredRequests() async =>
      _requests.where((r) => r.status == RequestStatus.insured).toList();

  @override
  Future<List<CreditRequestEntity>> getValuedRequests() async =>
      _requests.where((r) => r.status == RequestStatus.valued).toList();

  @override
  Stream<List<CreditRequestEntity>> watchCertifiedRequests() => Stream.value(
        _requests.where((r) => r.status == RequestStatus.certified).toList(),
      );

  @override
  Stream<List<CreditRequestEntity>> watchInsuredRequests() => Stream.value(
        _requests.where((r) => r.status == RequestStatus.insured).toList(),
      );
}
