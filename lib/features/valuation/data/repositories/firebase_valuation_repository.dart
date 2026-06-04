import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/valuation/domain/entities/valuation_entity.dart';
import 'package:water_ledger/features/valuation/domain/enums/valuation_status.dart';
import 'package:water_ledger/features/valuation/domain/repositories/valuation_repository.dart';

class FirebaseValuationRepository implements ValuationRepository {
  final _valuations = FirebaseFirestore.instance.collection('valuations');
  final _requests = FirebaseFirestore.instance.collection('creditRequests');

  Map<String, dynamic> _normalize(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) return MapEntry(key, value.toDate());
      if (value is Map<String, dynamic>) return MapEntry(key, _normalize(value));
      return MapEntry(key, value);
    });
  }

  @override
  Future<ValuationEntity?> getValuation(String requestId) async {
    final doc = await _valuations.doc(requestId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ValuationEntity.fromMap(_normalize(doc.data()!));
  }

  @override
  Stream<ValuationEntity?> valuationStream(String requestId) {
    return _valuations.doc(requestId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return ValuationEntity.fromMap(_normalize(snap.data()!));
    });
  }

  @override
  Future<void> createValuation({
    required String requestId,
    required String adminId,
    required double assessedValue,
    required double pricePerCredit,
    required String methodology,
    required String notes,
  }) async {
    final now = DateTime.now();
    final entity = ValuationEntity(
      requestId: requestId,
      adminId: adminId,
      status: ValuationStatus.appraised,
      assessedValue: assessedValue,
      pricePerCredit: pricePerCredit,
      methodology: methodology,
      notes: notes,
      appraisedAt: now,
      createdAt: now,
      updatedAt: now,
    );

    final batch = FirebaseFirestore.instance.batch();
    batch.set(_valuations.doc(requestId), entity.toMap());
    batch.update(_requests.doc(requestId), {
      'status': RequestStatus.valued.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  @override
  Future<void> rejectValuation({
    required String requestId,
    required String adminId,
    required String notes,
  }) async {
    final now = DateTime.now();
    final entity = ValuationEntity(
      requestId: requestId,
      adminId: adminId,
      status: ValuationStatus.rejected,
      assessedValue: 0,
      pricePerCredit: 0,
      methodology: '',
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    final batch = FirebaseFirestore.instance.batch();
    batch.set(_valuations.doc(requestId), entity.toMap());
    batch.update(_requests.doc(requestId), {
      'status': RequestStatus.rejected.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  @override
  Future<void> publishRequest({required String requestId}) async {
    await _requests.doc(requestId).update({
      'status': RequestStatus.published.name,
      'publishedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
