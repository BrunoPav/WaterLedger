import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_ledger/features/shared/domain/entities/user_model.dart';
import 'package:water_ledger/features/shared/domain/enums/user_role.dart';
import 'package:water_ledger/features/shared/domain/enums/user_status.dart';

/// Registro reducido para el feed "Recent Audit Log" del perfil admin.
/// Combina el dato del usuario afectado con la decisión que tomó el admin.
class AdminDecisionRecord {
  final String uid;
  final String displayName;
  final String email;
  final UserRole role;
  final UserStatus decision;
  final DateTime decidedAt;

  const AdminDecisionRecord({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    required this.decision,
    required this.decidedAt,
  });

  factory AdminDecisionRecord.fromFirestore(Map<String, dynamic> data, String uid) {
    return AdminDecisionRecord(
      uid: uid,
      displayName: (data['displayName'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      role: UserRole.fromString(data['role'] as String? ?? 'Retail'),
      decision: UserStatus.fromString(data['status'] as String? ?? 'pending'),
      decidedAt: (data['decisionAt'] as Timestamp).toDate(),
    );
  }
}

/// Operaciones que ejecuta un usuario con rol Admin sobre el resto de la plataforma.
abstract class AdminRepository {
  /// Stream en vivo de todos los usuarios cuyo `status` es `pending`.
  /// Ordenados por `createdAt` descendente.
  Stream<List<UserModel>> pendingUsersStream();

  /// Conteo en vivo de usuarios pendientes de aprobación.
  Stream<int> pendingApprovalsCount();

  /// Conteo en vivo de documentos de una colección. Usado para KPIs cuyos
  /// backing collections todavía no se implementaron — devuelve 0 si la
  /// colección no existe.
  Stream<int> collectionCount(String collectionPath);

  /// Documento completo del usuario (incluye subfields `companyData`,
  /// `representativeData` y `<role>RoleData` cuando aplican).
  Future<Map<String, dynamic>> fetchUserFullData(String uid);

  /// Marca al usuario como aprobado: `status = 'active'`.
  Future<void> approveUser(String uid);

  /// Marca al usuario como rechazado: `status = 'rejected'`.
  Future<void> rejectUser(String uid);

  /// Últimas N decisiones del admin (aprobaciones + rechazos) ordenadas por
  /// `decisionAt` descendente. Alimenta el feed "Recent Audit Log" del perfil.
  Stream<List<AdminDecisionRecord>> recentDecisionsStream({int limit});

  // ── 4.6.3 Supervisión ─────────────────────────────────────────────────────

  /// Stream de todas las solicitudes de crédito. Ordenadas por `createdAt` desc.
  /// Devuelve los documentos como Map para no acoplar core con features/credit_issuance.
  Stream<List<Map<String, dynamic>>> creditRequestsStream();

  // ── 4.6.2 Asignación operativa ────────────────────────────────────────────

  /// Stream de auditores activos disponibles para asignación.
  Stream<List<UserModel>> activeAuditorsStream();

  /// Asigna un auditor a una solicitud y cambia el estado a `underAudit`.
  Future<void> assignAuditor({
    required String requestId,
    required String auditorId,
    required String auditorName,
  });
}
