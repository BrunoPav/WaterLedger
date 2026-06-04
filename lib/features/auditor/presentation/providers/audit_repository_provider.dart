import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/auditor/data/repositories/firebase_audit_repository.dart';
import 'package:water_ledger/features/auditor/domain/entities/audit_entity.dart';
import 'package:water_ledger/features/auditor/domain/repositories/audit_repository.dart';
import 'package:water_ledger/features/auditor/domain/use_cases/add_observation_use_case.dart';
import 'package:water_ledger/features/auditor/domain/use_cases/delete_observation_use_case.dart';
import 'package:water_ledger/features/auditor/domain/use_cases/get_audit_use_case.dart';
import 'package:water_ledger/features/auditor/domain/use_cases/start_audit_use_case.dart';
import 'package:water_ledger/features/auditor/domain/use_cases/submit_audit_conclusion_use_case.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return FirebaseAuditRepository();
});

final startAuditUseCaseProvider = Provider<StartAuditUseCase>((ref) {
  return StartAuditUseCase(ref.watch(auditRepositoryProvider));
});

final addObservationUseCaseProvider = Provider<AddObservationUseCase>((ref) {
  return AddObservationUseCase(ref.watch(auditRepositoryProvider));
});

final deleteObservationUseCaseProvider = Provider<DeleteObservationUseCase>((ref) {
  return DeleteObservationUseCase(ref.watch(auditRepositoryProvider));
});

final submitAuditConclusionUseCaseProvider = Provider<SubmitAuditConclusionUseCase>((ref) {
  return SubmitAuditConclusionUseCase(ref.watch(auditRepositoryProvider));
});

final getAuditUseCaseProvider = Provider<GetAuditUseCase>((ref) {
  return GetAuditUseCase(ref.watch(auditRepositoryProvider));
});

/// Stream en vivo del documento de auditoría. Se invalida solo cuando Firestore
/// actualiza el documento (observaciones, conclusión, status).
final auditStreamProvider =
    StreamProvider.autoDispose.family<AuditEntity?, String>((ref, requestId) {
  return ref.watch(auditRepositoryProvider).auditStream(requestId);
});
