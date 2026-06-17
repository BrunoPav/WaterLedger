import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/insurer/domain/entities/insurance_plan_entity.dart';
import 'package:water_ledger/features/insurer/domain/enums/insurance_plan_status.dart';
import 'package:water_ledger/features/insurer/domain/enums/insurance_plan_type.dart';
import 'package:water_ledger/features/insurer/domain/repositories/insurance_repository.dart';

class FirebaseInsuranceRepository implements InsuranceRepository {
  final _plans = FirebaseFirestore.instance.collection('insurancePlans');
  final _requests = FirebaseFirestore.instance.collection('creditRequests');

  Map<String, dynamic> _normalize(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) return MapEntry(key, value.toDate());
      if (value is Map<String, dynamic>) return MapEntry(key, _normalize(value));
      return MapEntry(key, value);
    });
  }

  @override
  Future<InsurancePlanEntity?> getInsurancePlan(String requestId) async {
    final doc = await _plans.doc(requestId).get();
    if (!doc.exists || doc.data() == null) return null;
    return InsurancePlanEntity.fromMap(_normalize(doc.data()!));
  }

  @override
  Stream<InsurancePlanEntity?> insurancePlanStream(String requestId) {
    return _plans.doc(requestId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return InsurancePlanEntity.fromMap(_normalize(snap.data()!));
    });
  }

  @override
  Future<void> createInsurancePlan({
    required String requestId,
    required String insurerId,
    required InsurancePlanType planType,
    required double coverageAmount,
    required double premiumRate,
    required String notes,
  }) async {
    final now = DateTime.now();
    final entity = InsurancePlanEntity(
      requestId: requestId,
      insurerId: insurerId,
      status: InsurancePlanStatus.active,
      planType: planType,
      coverageAmount: coverageAmount,
      premiumRate: premiumRate,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    final batch = FirebaseFirestore.instance.batch();
    batch.set(_plans.doc(requestId), entity.toMap());
    batch.update(_requests.doc(requestId), {
      'status': RequestStatus.insured.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  @override
  Future<void> rejectInsurance({
    required String requestId,
    required String insurerId,
    required String notes,
  }) async {
    final now = DateTime.now();
    final entity = InsurancePlanEntity(
      requestId: requestId,
      insurerId: insurerId,
      status: InsurancePlanStatus.rejected,
      planType: InsurancePlanType.standard,
      coverageAmount: 0,
      premiumRate: 0,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    final batch = FirebaseFirestore.instance.batch();
    batch.set(_plans.doc(requestId), entity.toMap());
    batch.update(_requests.doc(requestId), {
      'status': RequestStatus.rejected.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
