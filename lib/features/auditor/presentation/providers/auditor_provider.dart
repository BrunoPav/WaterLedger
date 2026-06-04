import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/repository_provider.dart';

/// Solicitudes de crédito asignadas al auditor logueado.
/// Se reevalúa cuando cambia la sesión.
final auditorAssignmentsProvider = FutureProvider<List<CreditRequestEntity>>((ref) async {
  final user = ref.watch(sessionProvider).value;
  if (user == null) return [];
  return ref.read(creditIssuanceRepositoryProvider).getAuditorAssignments(user.uid);
});

/// Detalle de una solicitud específica — usado por la pantalla de detalle del auditor.
final auditorRequestDetailProvider =
    FutureProvider.family<CreditRequestEntity, String>((ref, requestId) {
  return ref.read(creditIssuanceRepositoryProvider).getRequestById(requestId);
});
