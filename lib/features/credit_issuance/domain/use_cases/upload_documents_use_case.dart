import 'package:water_ledger/features/credit_issuance/domain/entities/document_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/repositories/credit_issuance_repository.dart';

class UploadDocumentsUseCase {
  final CreditIssuanceRepository repository;
  UploadDocumentsUseCase(this.repository);

  Future<void> call(String requestId, List<DocumentEntity> documents) {
    return repository.uploadDocuments(
      requestId: requestId,
      documents: documents,
    );
  }
}
