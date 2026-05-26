import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/core/data/repositories/firebase_admin_repository.dart';
import 'package:water_ledger/core/domain/entities/user_model.dart';
import 'package:water_ledger/core/domain/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return FirebaseAdminRepository();
});

/// Stream en vivo de usuarios pendientes de aprobación.
final pendingUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(adminRepositoryProvider).pendingUsersStream();
});

/// Conteo de usuarios pendientes (para el KPI "User Approvals").
final pendingApprovalsCountProvider = StreamProvider<int>((ref) {
  return ref.watch(adminRepositoryProvider).pendingApprovalsCount();
});

/// Conteo en vivo de cualquier colección — usado para los KPIs "Active Projects",
/// "Certifications" y "Valuations" mientras esas colecciones no están pobladas.
final collectionCountProvider =
    StreamProvider.family<int, String>((ref, collectionPath) {
  return ref.watch(adminRepositoryProvider).collectionCount(collectionPath);
});

/// Documento completo del usuario, indexado por uid. Usado por la pantalla
/// de detalle de solicitud pendiente.
final userFullDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, uid) {
  return ref.watch(adminRepositoryProvider).fetchUserFullData(uid);
});
