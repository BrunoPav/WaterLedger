import 'package:water_ledger/features/credit_issuance/domain/entities/water_project_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/repositories/credit_issuance_repository.dart';

class UpdateWaterProjectUseCase {
  final CreditIssuanceRepository repository;

  UpdateWaterProjectUseCase(this.repository);

  Future<void> call(String requestId, WaterProjectEntity project) {
    return repository.updateProjectInfo(requestId: requestId, project: project);
  }
}
