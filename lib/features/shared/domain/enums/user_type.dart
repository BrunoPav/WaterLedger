/// Tipo de usuario según el spec 4.1.4.1.
/// Modela la distinción Persona física vs Empresa, complementando UserRole.
enum UserType {
  person,
  company;

  String get value {
    switch (this) {
      case UserType.person:  return 'Person';
      case UserType.company: return 'Company';
    }
  }

  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserType.person,
    );
  }
}
