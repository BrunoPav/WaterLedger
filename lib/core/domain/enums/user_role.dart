enum UserRole {
  retail,
  company,
  auditor,
  certifier,
  insurer;

  String get value {
    switch (this) {
      case UserRole.retail:    return 'Retail';
      case UserRole.company:   return 'Company';
      case UserRole.auditor:   return 'Auditor';
      case UserRole.certifier: return 'Certifier';
      case UserRole.insurer:   return 'Insurer';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.retail,
    );
  }
}
