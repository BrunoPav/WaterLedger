import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/repository_provider.dart';
import 'package:water_ledger/features/valuation/data/repositories/firebase_valuation_repository.dart';
import 'package:water_ledger/features/valuation/domain/entities/valuation_entity.dart';
import 'package:water_ledger/features/valuation/domain/repositories/valuation_repository.dart';

final valuationRepositoryProvider = Provider<ValuationRepository>((ref) {
  return FirebaseValuationRepository();
});

final valuationStreamProvider =
    StreamProvider.autoDispose.family<ValuationEntity?, String>((ref, requestId) {
  return ref.watch(valuationRepositoryProvider).valuationStream(requestId);
});

/// Solicitudes con status='insured' listas para valorizar.
final insuredRequestsForAdminProvider = FutureProvider<List<CreditRequestEntity>>((ref) async {
  return ref.read(creditIssuanceRepositoryProvider).getInsuredRequests();
});

/// Solicitudes con status='valued' listas para publicar.
final valuedRequestsForAdminProvider = FutureProvider<List<CreditRequestEntity>>((ref) async {
  return ref.read(creditIssuanceRepositoryProvider).getValuedRequests();
});

/// Detalle de una solicitud — usado por la pantalla de detalle de valorización.
final valuationRequestDetailProvider =
    FutureProvider.family<CreditRequestEntity, String>((ref, requestId) {
  return ref.read(creditIssuanceRepositoryProvider).getRequestById(requestId);
});
