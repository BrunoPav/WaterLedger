import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/credit_issuance/domain/use_cases/create_credit_request_use_case.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/repository_provider.dart';

final creditRequestProvider = NotifierProvider<CreditRequestNotifier, CreditRequestEntity>(
  CreditRequestNotifier.new,
);

class CreditRequestNotifier extends Notifier<CreditRequestEntity> {

  late final CreateCreditRequestUseCase _createCreditRequestUseCase = ref.read(createCreditRequestUseCaseProvider);

  @override
  CreditRequestEntity build() {   

    return CreditRequestEntity(
      id: '',
      issuerCompanyId: '',
      proyectoId: '',
      creditAmount: 0.0,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
    );
  }
  
  Future<void> createDraft(String companyId) async {
    final draft = await _createCreditRequestUseCase(companyId);
    state = draft;
  }
} 