import 'package:water_ledger/features/certifier/domain/entities/certification_entity.dart';

abstract class CertificationRepository {
  Future<CertificationEntity?> getCertification(String requestId);

  Stream<CertificationEntity?> certificationStream(String requestId);

  /// Emite el certificado y transiciona creditRequest → 'insured'.
  Future<void> issueCertificate({
    required String requestId,
    required String certifierId,
    required String notes,
  });

  /// Rechaza y transiciona creditRequest → 'rejected'.
  Future<void> rejectCertification({
    required String requestId,
    required String certifierId,
    required String notes,
  });
}
