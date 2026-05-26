import 'package:water_ledger/core/domain/entities/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> registerRetail({
    required String email,
    required String password,
    required String fullName,
    required String dni,
  });

  Future<UserModel> registerCompany({
    required String email,
    required String password,
    required String companyName,
    required String cuit,
  });

  Future<UserModel> registerAuditor({
    required String email,
    required String password,
    required String auditorType,
    required Map<String, dynamic> companyData,
    required Map<String, dynamic> representativeData,
    required Map<String, dynamic> auditorRoleData,
  });

  Future<UserModel> registerCertifier({
    required String email,
    required String password,
    required Map<String, dynamic> companyData,
    required Map<String, dynamic> representativeData,
    required Map<String, dynamic> certifierRoleData,
  });

  Future<UserModel> registerInsurer({
    required String email,
    required String password,
    required Map<String, dynamic> companyData,
    required Map<String, dynamic> representativeData,
    required Map<String, dynamic> insurerRoleData,
  });

  /// Crea un usuario Admin activo. Usado por la pantalla `/admin-seed` (dev).
  Future<UserModel> registerAdmin({
    required String email,
    required String password,
    required String displayName,
  });

  Future<UserModel?> getCurrentUser();

  Future<void> logout();
}
