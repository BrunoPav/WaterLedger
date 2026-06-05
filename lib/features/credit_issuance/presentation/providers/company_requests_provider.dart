import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/repository_provider.dart';

/// Provider derivado: trae las solicitudes de crédito de la empresa logueada.
/// Se reevalúa cuando cambia la sesión.
/// Retorna lista vacía si no hay sesión.
final companyRequestsProvider = FutureProvider<List<CreditRequestEntity>>((ref) async {
  final session = ref.watch(sessionProvider);
  final user = session.value;
  if (user == null) return [];

  final repository = ref.read(creditIssuanceRepositoryProvider);
  return repository.getCompanyRequests(user.uid);
});

/// Carga una solicitud específica por ID — usado por RequestTrackingScreen.
final requestTrackingProvider =
    FutureProvider.family<CreditRequestEntity, String>((ref, requestId) {
  return ref.read(creditIssuanceRepositoryProvider).getRequestById(requestId);
});
