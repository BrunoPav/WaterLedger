import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/repositories/credit_issuance_repository.dart';

class UpdateRoadmapUseCase {
  final CreditIssuanceRepository repository;
  UpdateRoadmapUseCase(this.repository);

  Future<void> call(String requestId, RoadmapEntity roadmap) {
    return repository.updateRoadmap(requestId: requestId, roadmap: roadmap);
  }
}
