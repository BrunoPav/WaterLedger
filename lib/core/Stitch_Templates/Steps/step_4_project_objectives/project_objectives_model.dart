class ProjectObjectivesModel {
  final String objetivoPrincipal;
  final String impactoHidricoEsperado;
  final String metasSustentabilidad;
  final String entornoAmbientalBeneficiado;

  const ProjectObjectivesModel({
    required this.objetivoPrincipal,
    required this.impactoHidricoEsperado,
    required this.metasSustentabilidad,
    required this.entornoAmbientalBeneficiado,
  });

  Map<String, dynamic> toJson() {
    return {
      'objetivoPrincipal': objetivoPrincipal,
      'impactoHidricoEsperado': impactoHidricoEsperado,
      'metasSustentabilidad': metasSustentabilidad,
      'entornoAmbientalBeneficiado': entornoAmbientalBeneficiado,
    };
  }
}