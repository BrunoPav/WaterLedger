import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/repository_provider.dart';

/// Provider derivado: trae las solicitudes de crédito de la empresa logueada.
/// Se reevalúa cuando cambia la sesión.
/// Retorna lista vacía si no hay sesión.
///
/// Versión anterior (FutureProvider): cargaba las solicitudes UNA sola vez y
/// quedaba cacheada. Tras enviar un draft, el dashboard seguía mostrando el
/// estado viejo ("Complete your draft request") hasta refrescar a mano.
/// La dejamos comentada como referencia del cambio:
// final companyRequestsProvider = FutureProvider<List<CreditRequestEntity>>((ref) async {
//   final session = ref.watch(sessionProvider);
//   final user = session.value;
//   if (user == null) return [];
//
//   final repository = ref.read(creditIssuanceRepositoryProvider);
//   return repository.getCompanyRequests(user.uid);
// });

/// Ahora es un StreamProvider: escucha Firestore en tiempo real (mismo patrón
/// que companyActivityProvider). Así el banner "Pending action", las stats y la
/// lista de solicitudes se actualizan solos cuando cambia el estado de una
/// solicitud (draft -> pending al enviar, o cambios del auditor/certificador),
/// sin tener que refrescar la pantalla.
final companyRequestsProvider = StreamProvider<List<CreditRequestEntity>>((ref) {
  final session = ref.watch(sessionProvider);
  final user = session.value;
  if (user == null) return Stream.value([]);

  final repository = ref.watch(creditIssuanceRepositoryProvider);
  return repository.watchCompanyRequests(user.uid);
});

/// Carga una solicitud específica por ID — usado por RequestTrackingScreen.
final requestTrackingProvider =
    FutureProvider.family<CreditRequestEntity, String>((ref, requestId) {
  return ref.read(creditIssuanceRepositoryProvider).getRequestById(requestId);
});
