import 'package:flutter/material.dart';
import 'project_objectives_model.dart';
import 'project_objectives_repository.dart';

class ProjectObjectivesStepScreen extends StatefulWidget {
  const ProjectObjectivesStepScreen({super.key});

  @override
  State<ProjectObjectivesStepScreen> createState() =>
      _ProjectObjectivesStepScreenState();
}

class _ProjectObjectivesStepScreenState
    extends State<ProjectObjectivesStepScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ProjectObjectivesRepository repository = ProjectObjectivesRepository();

  final TextEditingController objetivoPrincipalController =
      TextEditingController();
  final TextEditingController impactoHidricoController =
      TextEditingController();
  final TextEditingController metasSustentabilidadController =
      TextEditingController();
  final TextEditingController entornoAmbientalController =
      TextEditingController();

  bool cargando = false;
  ProjectObjectivesModel? objetivosGuardados;

  @override
  void dispose() {
    objetivoPrincipalController.dispose();
    impactoHidricoController.dispose();
    metasSustentabilidadController.dispose();
    entornoAmbientalController.dispose();
    super.dispose();
  }

  String? validarCampo(String? value) {
    String? mensaje;

    if (value == null || value.trim().isEmpty) {
      mensaje = 'Este campo es obligatorio';
    } else if (value.trim().length < 10) {
      mensaje = 'Debe tener al menos 10 caracteres';
    }

    return mensaje;
  }

  Future<void> guardarObjetivos() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        cargando = true;
      });

      final objetivos = ProjectObjectivesModel(
        objetivoPrincipal: objetivoPrincipalController.text.trim(),
        impactoHidricoEsperado: impactoHidricoController.text.trim(),
        metasSustentabilidad: metasSustentabilidadController.text.trim(),
        entornoAmbientalBeneficiado: entornoAmbientalController.text.trim(),
      );

      await repository.guardarObjetivos(objetivos);

      setState(() {
        cargando = false;
        objetivosGuardados = objetivos;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Objetivos del proyecto cargados correctamente'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Project Objectives'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 28),
                _buildFormulario(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF14B8A6),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carga de objetivos del proyecto',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Definí los objetivos hídricos, el impacto esperado y las metas ambientales del proyecto.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextArea(
                    controller: objetivoPrincipalController,
                    label: 'Objetivo principal',
                    hint:
                        'Ej: Reducir el consumo de agua potable en el proceso productivo.',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildTextArea(
                    controller: impactoHidricoController,
                    label: 'Impacto hídrico esperado',
                    hint:
                        'Ej: Se espera ahorrar 15.000 litros de agua por mes.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextArea(
                    controller: metasSustentabilidadController,
                    label: 'Metas de sustentabilidad',
                    hint:
                        'Ej: Reducir un 25% el consumo de agua en 12 meses.',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildTextArea(
                    controller: entornoAmbientalController,
                    label: 'Entorno ambiental beneficiado',
                    hint:
                        'Ej: Cuenca local, napas subterráneas o ecosistema cercano.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: cargando ? null : () {
                    objetivoPrincipalController.clear();
                    impactoHidricoController.clear();
                    metasSustentabilidadController.clear();
                    entornoAmbientalController.clear();
                    setState(() {
                      objetivosGuardados = null;
                    });
                  },
                  child: const Text('Limpiar'),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: cargando ? null : guardarObjetivos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Guardar objetivos'),
                  ),
                ),
              ],
            ),
            if (objetivosGuardados != null) _buildResumen(objetivosGuardados!),
          ],
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      validator: validarCampo,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF2563EB),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildResumen(ProjectObjectivesModel objetivos) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 26),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF99F6E4),
        ),
      ),
      child: const Text(
        'Objetivos guardados correctamente.',
        style: TextStyle(
          color: Color(0xFF065F46),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}