import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/repository_provider.dart';

/// Solicitudes con status='certified' visibles para todos los certificadores.
final certifiedRequestsProvider = FutureProvider<List<CreditRequestEntity>>((ref) async {
  return ref.read(creditIssuanceRepositoryProvider).getCertifiedRequests();
});

/// Detalle de una solicitud — usado por la pantalla de detalle del certificador.
final certifierRequestDetailProvider =
    FutureProvider.family<CreditRequestEntity, String>((ref, requestId) {
  return ref.read(creditIssuanceRepositoryProvider).getRequestById(requestId);
});
