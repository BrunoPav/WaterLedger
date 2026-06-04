class SustainabilityGoalEntity {
  String objective;
  String description;
  String benefittedEnvironment;

  SustainabilityGoalEntity({
    required this.objective,
    required this.description,
    required this.benefittedEnvironment,
  });

  Map<String, dynamic> toMap() => {
    'objective': objective,
    'description': description,
    'benefittedEnvironment': benefittedEnvironment,
  };

  factory SustainabilityGoalEntity.fromMap(Map<String, dynamic> map) =>
      SustainabilityGoalEntity(
        objective: map['objective'] ?? '',
        description: map['description'] ?? '',
        benefittedEnvironment: map['benefittedEnvironment'] ?? '',
      );
}