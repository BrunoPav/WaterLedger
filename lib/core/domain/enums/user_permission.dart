enum UserPermission {
  buyer,
  issuer,
  auditor,
  certifier,
  insurer;

  String get value {
    switch (this) {
      case UserPermission.buyer:     return 'Buyer';
      case UserPermission.issuer:    return 'Issuer';
      case UserPermission.auditor:   return 'Auditor';
      case UserPermission.certifier: return 'Certifier';
      case UserPermission.insurer:   return 'Insurer';
    }
  }

  static UserPermission fromString(String value) {
    return UserPermission.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserPermission.buyer,
    );
  }
}
