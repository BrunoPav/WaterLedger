import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/document_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/water_project_entity.dart';



abstract class CreditIssuanceRepository {

  Future<CreditRequestEntity> createDraft({
    required String companyId,
  });

  Future<void> updateProjectInfo({
    required String requestId,
    required WaterProjectEntity project,
  });

  Future<void> updateRoadmap({
    required String requestId,
    required RoadmapEntity roadmap,
  });

  Future<void> uploadDocuments({
    required String requestId,
    required List<DocumentEntity> documents,
  });

  Future<void> submitRequest({
    required String requestId,
  });

  Future<CreditRequestEntity> getRequestById(String requestId);

  Future<List<CreditRequestEntity>> getCompanyRequests(String companyId);

  Future<void> deleteDraft(String requestId);
}