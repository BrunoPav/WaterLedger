import 'package:water_ledger/features/shared/domain/entities/user_model.dart';

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
    // Datos adicionales del inversor retail. Antes se recolectaban en el form
    // pero se descartaban; ahora se persisten en retailData.
    String phone = '',
    String country = '',
    List<String> interests = const [],
    String riskProfile = '',
  });

  Future<UserModel> registerCompany({
    required String email,
    required String password,
    required String companyName,
    required String cuit,
    // Datos adicionales del onboarding corporativo. Antes el form de 3 pasos los
    // recolectaba (razón social, sector, país, teléfono, dirección) pero se
    // descartaban; ahora se persisten en companyData.
    String legalName = '',
    String industry = '',
    String country = '',
    String phone = '',
    String address = '',
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

  /// Envía un email con link de reset de contraseña al user indicado.
  /// Si el email no existe igual completa exitosamente (Firebase no lo
  /// expone por seguridad — anti-enumeration).
  Future<void> sendPasswordResetEmail({required String email});

  /// Aplica un patch parcial al documento del usuario en Firestore.
  /// Soporta paths con notación punto (ej: 'representativeData.phone').
  /// El `displayName` se sincroniza también con FirebaseAuth si está incluido.
  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> updates,
  });
}
