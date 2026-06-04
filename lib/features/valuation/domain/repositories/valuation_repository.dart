import 'package:water_ledger/features/valuation/domain/entities/valuation_entity.dart';

abstract class ValuationRepository {
  Future<ValuationEntity?> getValuation(String requestId);

  Stream<ValuationEntity?> valuationStream(String requestId);

  Future<void> createValuation({
    required String requestId,
    required String adminId,
    required double assessedValue,
    required double pricePerCredit,
    required String methodology,
    required String notes,
  });

  Future<void> rejectValuation({
    required String requestId,
    required String adminId,
    required String notes,
  });

  Future<void> publishRequest({required String requestId});
}
