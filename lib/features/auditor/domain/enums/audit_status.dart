enum AuditStatus {
  inProgress,
  submitted;

  static AuditStatus fromString(String value) => AuditStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => AuditStatus.inProgress,
      );
}
