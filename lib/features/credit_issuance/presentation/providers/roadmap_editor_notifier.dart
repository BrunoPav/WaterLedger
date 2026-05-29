import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/project_phase_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/presentation/models/roadmap_phase_draft_model.dart';
import 'package:water_ledger/features/credit_issuance/domain/validators/phase_validator.dart';

final roadmapEditorProvider = NotifierProvider<RoadmapEditorNotifier, RoadmapEntity>(
  RoadmapEditorNotifier.new,
);

class RoadmapEditorNotifier extends Notifier<RoadmapEntity> {
  @override
  RoadmapEntity build() {
    return RoadmapEntity(phases: []);
  }

  void addPhase(PhaseEntity phase) {
    state = RoadmapEntity(
      phases: [...state.phases, phase],
    );
  }

  List<String> addPhaseFromDraft(RoadmapPhaseDraftModel draft) {
    final phase = draft.toEntity();
    if (phase == null) {
      return ['Completá nombre, fechas y al menos un hito.'];
    }

    final errors = PhaseValidator.validate(phase);
    if (errors.isNotEmpty) return errors;

    addPhase(phase);
    return <String>[];
  }

  void removePhase(int index) {
    final updatedPhases = [...state.phases]..removeAt(index);
    state = RoadmapEntity(phases: updatedPhases);
  }

  void clear() {
    state = RoadmapEntity(phases: []);
  }
}