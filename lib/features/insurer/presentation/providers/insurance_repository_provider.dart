import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/insurer/data/repositories/firebase_insurance_repository.dart';
import 'package:water_ledger/features/insurer/domain/entities/insurance_plan_entity.dart';
import 'package:water_ledger/features/insurer/domain/repositories/insurance_repository.dart';
import 'package:water_ledger/features/insurer/domain/use_cases/create_insurance_plan_use_case.dart';
import 'package:water_ledger/features/insurer/domain/use_cases/reject_insurance_use_case.dart';

final insuranceRepositoryProvider = Provider<InsuranceRepository>((ref) {
  return FirebaseInsuranceRepository();
});

final createInsurancePlanUseCaseProvider = Provider<CreateInsurancePlanUseCase>((ref) {
  return CreateInsurancePlanUseCase(ref.watch(insuranceRepositoryProvider));
});

final rejectInsuranceUseCaseProvider = Provider<RejectInsuranceUseCase>((ref) {
  return RejectInsuranceUseCase(ref.watch(insuranceRepositoryProvider));
});

final insurancePlanStreamProvider =
    StreamProvider.autoDispose.family<InsurancePlanEntity?, String>((ref, requestId) {
  return ref.watch(insuranceRepositoryProvider).insurancePlanStream(requestId);
});
