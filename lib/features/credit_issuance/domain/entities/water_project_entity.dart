import 'package:water_ledger/features/credit_issuance/domain/entities/sustainability_goal_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/project_category.dart';

class WaterProjectEntity {
    String id;
    String name;
    String ubication;
    ProjectCategory category;
    String sumary;
    double estimatedInvestment;
    String expectedWaterImpact;
    SustainabilityGoalEntity sustainabilityGoal;

  WaterProjectEntity({
    required this.id,
    required this.name,
    required this.ubication,
    required this.category,
    required this.sumary,
    required this.estimatedInvestment,
    required this.expectedWaterImpact,
    required this.sustainabilityGoal,
  });
}