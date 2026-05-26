import 'package:water_ledger/core/domain/entities/user_model.dart';

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
}
