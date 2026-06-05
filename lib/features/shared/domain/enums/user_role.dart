enum UserRole {
  retail,
  company,
  issuer,
  auditor,
  certifier,
  insurer,
  admin;

  String get value {
    switch (this) {
      case UserRole.retail:    return 'Retail';
      case UserRole.company:   return 'Company';
      case UserRole.issuer:    return 'Issuer';
      case UserRole.auditor:   return 'Auditor';
      case UserRole.certifier: return 'Certifier';
      case UserRole.insurer:   return 'Insurer';
      case UserRole.admin:     return 'Admin';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.retail,
    );
  }
}
