enum AuditRecommendation {
  approve,
  reject,
  needsMoreInfo;

  String get label => switch (this) {
        AuditRecommendation.approve => 'Aprobar',
        AuditRecommendation.reject => 'Rechazar',
        AuditRecommendation.needsMoreInfo => 'Solicitar más información',
      };

  static AuditRecommendation fromString(String value) =>
      AuditRecommendation.values.firstWhere(
        (r) => r.name == value,
        orElse: () => AuditRecommendation.needsMoreInfo,
      );
}
