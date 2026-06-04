import 'package:water_ledger/features/insurer/domain/repositories/insurance_repository.dart';

class RejectInsuranceUseCase {
  const RejectInsuranceUseCase(this._repository);
  final InsuranceRepository _repository;

  Future<void> call({
    required String requestId,
    required String insurerId,
    required String notes,
  }) =>
      _repository.rejectInsurance(
        requestId: requestId,
        insurerId: insurerId,
        notes: notes,
      );
}
