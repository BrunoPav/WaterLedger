import 'package:water_ledger/features/certifier/domain/entities/certification_entity.dart';

abstract class CertificationRepository {
  Future<CertificationEntity?> getCertification(String requestId);

  Stream<CertificationEntity?> certificationStream(String requestId);

  /// Todas las certificaciones (emitidas o rechazadas) por un certificador.
  Future<List<CertificationEntity>> getCertifierCertifications(String certifierId);

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
