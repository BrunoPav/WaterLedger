enum UserStatus {
  active,
  pending,
  rejected;

  String get value {
    switch (this) {
      case UserStatus.active:   return 'active';
      case UserStatus.pending:  return 'pending';
      case UserStatus.rejected: return 'rejected';
    }
  }

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserStatus.pending,
    );
  }
}
