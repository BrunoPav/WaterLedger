enum RequestStatus {
  draft,
  pending,
  underAudit,
  certified,
  insured,
  valued,
  published,
  rejected;

  String get label => switch (this) {
        draft => 'Borrador',
        pending => 'Pendiente',
        underAudit => 'En Auditoría',
        certified => 'En Certificación',
        insured => 'En Aseguramiento',
        valued => 'Valorizado',
        published => 'Publicado',
        rejected => 'Rechazado',
      };

  static RequestStatus fromString(String value) => RequestStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => RequestStatus.draft,
      );
}
