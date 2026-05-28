import 'project_objectives_model.dart';

class ProjectObjectivesRepository {
  ProjectObjectivesModel? objetivosGuardados;

  Future<void> guardarObjetivos(ProjectObjectivesModel objetivos) async {
    await Future.delayed(const Duration(milliseconds: 600));
    objetivosGuardados = objetivos;
  }

  ProjectObjectivesModel? obtenerObjetivos() {
    return objetivosGuardados;
  }
}