import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/certifier/data/repositories/firebase_certification_repository.dart';
import 'package:water_ledger/features/certifier/domain/entities/certification_entity.dart';
import 'package:water_ledger/features/certifier/domain/repositories/certification_repository.dart';
import 'package:water_ledger/features/certifier/domain/use_cases/get_certification_use_case.dart';
import 'package:water_ledger/features/certifier/domain/use_cases/issue_certificate_use_case.dart';
import 'package:water_ledger/features/certifier/domain/use_cases/reject_certification_use_case.dart';

final certificationRepositoryProvider = Provider<CertificationRepository>((ref) {
  return FirebaseCertificationRepository();
});

final getCertificationUseCaseProvider = Provider<GetCertificationUseCase>((ref) {
  return GetCertificationUseCase(ref.watch(certificationRepositoryProvider));
});

final issueCertificateUseCaseProvider = Provider<IssueCertificateUseCase>((ref) {
  return IssueCertificateUseCase(ref.watch(certificationRepositoryProvider));
});

final rejectCertificationUseCaseProvider = Provider<RejectCertificationUseCase>((ref) {
  return RejectCertificationUseCase(ref.watch(certificationRepositoryProvider));
});

final certificationStreamProvider =
    StreamProvider.autoDispose.family<CertificationEntity?, String>((ref, requestId) {
  return ref.watch(certificationRepositoryProvider).certificationStream(requestId);
});
