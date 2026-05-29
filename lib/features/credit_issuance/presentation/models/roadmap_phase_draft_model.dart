import 'package:flutter/material.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/project_phase_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/milestones.dart';

class RoadmapPhaseDraftModel {
  final TextEditingController nameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  final Set<Milestones> selectedMilestones = {};

  PhaseEntity? toEntity() {
    final name = nameController.text.trim();
    if (name.isEmpty && startDate == null && endDate == null) {
      return null;
    }
    
    return PhaseEntity(
      name: name,
      startDate: startDate!,
      endDate: endDate!,
      milestones: selectedMilestones.toList(),
    );
  }

  void reset() {
    nameController.clear();
    startDate = null;
    endDate = null;
    selectedMilestones.clear();
  }

  void dispose() {
    nameController.dispose();
  }
}