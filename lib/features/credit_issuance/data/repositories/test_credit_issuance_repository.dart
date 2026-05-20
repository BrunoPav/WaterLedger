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

  /// Generates a unique request ID in format: REQ_YYYYMMDD_XXXXXX
  String _generateRequestId() {
    final now = DateTime.now();
    final dateCode = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomSuffix = _random.nextInt(999999).toString().padLeft(6, '0');
    return 'REQ_${dateCode}_$randomSuffix';
  }

  @override
  Future<CreditRequestEntity> createDraft({
    required String companyId
  }) async {
    // Generar un ID único para la solicitud
    final draft = CreditRequestEntity(
      id: _generateRequestId(),
      issuerCompanyId: companyId,
      proyectoId: 'null',
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
    final request = _requests.firstWhere((r) => r.id == requestId);
    request.roadmap = roadmap;
  }

  @override
  Future<void> updateProjectInfo({
    required String requestId,
    required WaterProjectEntity project,
  }) async {
    //deberia buscar el id de PROYECTOS y actualizarlo. Sin db no se puede hacer
    return Future.value();
  }
  

  @override
  Future<void> uploadDocuments({
    required String requestId,
    required List<DocumentEntity> documents,
  }) async {
    final request = _requests.firstWhere((r) => r.id == requestId);
    request.documents.addAll(documents);
  }

  @override
  Future<void> submitRequest({
    required String requestId,
  }) async {
    final request = _requests.firstWhere((r) => r.id == requestId);
    request.status = RequestStatus.pending;
    request.updatedAt = DateTime.now();
  }

  @override
  Future<CreditRequestEntity> getRequestById(String requestId) async {
    return _requests.firstWhere((r) => r.id == requestId);
  }

  @override
  Future<List<CreditRequestEntity>> getCompanyRequests(String companyId) async {
    return _requests.where((r) => r.issuerCompanyId == companyId).toList();
  }

  @override
  Future<void> deleteDraft(String requestId) async {
    _requests.removeWhere((r) => r.id == requestId && r.status == RequestStatus.draft);
  }
}

