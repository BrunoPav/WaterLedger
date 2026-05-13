import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/credit_issuance/data/repositories/test_credit_issuance_repository.dart';
import 'package:water_ledger/features/credit_issuance/domain/repositories/credit_issuance_repository.dart';
import 'package:water_ledger/features/credit_issuance/domain/use_cases/create_credit_request_use_case.dart';
import 'package:water_ledger/features/credit_issuance/domain/use_cases/get_credit_request_status_use_case.dart';

final creditIssuanceRepositoryProvider =
    Provider<CreditIssuanceRepository>((ref) {
  return TestCreditIssuanceRepository();
});

final createCreditRequestUseCaseProvider = Provider<CreateCreditRequestUseCase>((ref) {
  final repository = ref.watch(creditIssuanceRepositoryProvider);
  return CreateCreditRequestUseCase(repository);
});

final getCreditRequestStatusUseCaseProvider = Provider<GetCreditRequestStatusUseCase>((ref) {
  final repository = ref.watch(creditIssuanceRepositoryProvider);
  return GetCreditRequestStatusUseCase(repository);
}); 