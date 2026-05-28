import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'project_objectives_model.dart';
import 'project_objectives_repository.dart';

final projectObjectivesRepositoryProvider =
    Provider<ProjectObjectivesRepository>((ref) {
  return ProjectObjectivesRepository();
});

final projectObjectivesProvider =
    FutureProvider.family<ProjectObjectivesModel, ProjectObjectivesModel>(
  (ref, objetivos) async {
    final repository = ref.read(projectObjectivesRepositoryProvider);
    await repository.guardarObjetivos(objetivos);
    return objetivos;
  },
);