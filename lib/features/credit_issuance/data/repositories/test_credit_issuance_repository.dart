import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/document_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/water_project_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/credit_issuance/domain/repositories/credit_issuance_repository.dart';

class TestCreditIssuanceRepository implements CreditIssuanceRepository {

  final List<CreditRequestEntity> _requests = [];

  @override
  Future<CreditRequestEntity> createDraft({
    required String companyId
  }) async {
    //creo un CreditRequestEntity con datos de prueba
    final draft = CreditRequestEntity(
      id: 'test_request_id',
      issuerCompanyId: companyId,
      proyectoId: "null",
      creditAmount: 100.0,
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

