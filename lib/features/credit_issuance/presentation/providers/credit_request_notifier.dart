import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/credit_issuance/domain/use_cases/create_credit_request_use_case.dart';
import 'package:water_ledger/features/credit_issuance/domain/use_cases/submit_credit_request_use_case.dart';
import 'package:water_ledger/features/credit_issuance/domain/use_cases/update_roadmap_use_case.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/repository_provider.dart';

final creditRequestProvider = NotifierProvider<CreditRequestNotifier, CreditRequestEntity>(
  CreditRequestNotifier.new,
);

class CreditRequestNotifier extends Notifier<CreditRequestEntity> {

  late final CreateCreditRequestUseCase _createCreditRequestUseCase = ref.read(createCreditRequestUseCaseProvider);
  late final UpdateRoadmapUseCase _updateRoadmapUseCase = ref.read(updateRoadmapUseCaseProvider);
  late final SubmitCreditRequestUseCase _submitCreditRequestUseCase = ref.read(submitCreditRequestUseCaseProvider);

  @override
  CreditRequestEntity build() {

    return CreditRequestEntity(
      id: '',
      issuerCompanyId: '',
      proyectoId: '',
      creditAmount: 0.0,
      // Versión anterior inicializaba con pending — corregido a draft
      // ya que el estado inicial de una solicitud recién instanciada es borrador:
      // status: RequestStatus.pending,
      status: RequestStatus.draft,
      createdAt: DateTime.now(),
    );
  }

  Future<void> createDraft(String companyId) async {
    final draft = await _createCreditRequestUseCase(companyId);
    state = draft;
  }

  Future<void> updateRoadmap(RoadmapEntity roadmap) async {
    await _updateRoadmapUseCase(state.id, roadmap);
    state.roadmap = roadmap;
    state.updatedAt = DateTime.now();
    // Forzar rebuild del state mutando la referencia
    state = state;
  }

  Future<void> submitRequest() async {
    final updated = await _submitCreditRequestUseCase(state.id);
    state = updated;
  }
}