import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/project_phase_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/milestones.dart';
import 'package:water_ledger/features/credit_issuance/domain/validators/roadmap_validator.dart';

const Map<Milestones, String> kMilestoneLabels = {
  Milestones.initialAudit: 'Auditoría Inicial',
  Milestones.meterInstalation: 'Instalación de Medidores',
  Milestones.infrastructureValidation: 'Validación de Infraestructura',
  Milestones.operativeSistem: 'Sistema Operativo',
  Milestones.firstWaterSavingRegistered: 'Primer Ahorro de Agua',
  Milestones.ambientalReportGenerated: 'Informe Ambiental',
  Milestones.proyectFinalized: 'Proyecto Finalizado',
  Milestones.impactVerificated: 'Impacto Verificado',
  Milestones.proyectReadyToInssue: 'Listo para Emitir',
};

/// Widget reutilizable con el editor de roadmap.
/// Usado tanto en el wizard (CreditIssuanceScreen) como en RoadmapEditorScreen standalone.
///
/// [onSaved]   — se llama al guardar un roadmap válido; requerido.
/// [onSubmit]  — si no es null, muestra el botón "Enviar Solicitud" (standalone only).
/// [onBack]    — callback para el botón Back.
class RoadmapEditorStep extends StatefulWidget {
  const RoadmapEditorStep({
    super.key,
    required this.onSaved,
    required this.onBack,
    this.onSubmit,
  });

  final Future<void> Function(RoadmapEntity) onSaved;
  final VoidCallback onBack;
  final Future<void> Function()? onSubmit;

  @override
  State<RoadmapEditorStep> createState() => _RoadmapEditorStepState();
}

class _RoadmapEditorStepState extends State<RoadmapEditorStep> {
  final List<PhaseEntity> _phases = [];
  final _phaseNameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final Set<Milestones> _selectedMilestones = {};
  bool _isSaving = false;

  static const _bgColor = Color(0xFFF7F9FB);
  static const _secondaryColor = Color(0xFF006875);
  static const _cyanColor = Color(0xFF00E3FD);
  static const _onSurfaceColor = Color(0xFF191C1E);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _surfaceContainerLowColor = Color(0xFFF2F4F6);
  static const _surfaceContainerHighColor = Color(0xFFE6E8EA);
  static const _outlineVariantColor = Color(0xFFC5C6CD);
  static const _primaryContainerColor = Color(0xFF0D1C32);

  @override
  void dispose() {
    _phaseNameController.dispose();
    super.dispose();
  }

  void _addPhase() {
    final name = _phaseNameController.text.trim();
    if (name.isEmpty || _startDate == null || _endDate == null || _selectedMilestones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completá nombre, fechas y al menos un hito.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de inicio no puede ser posterior a la de fin.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      _phases.add(PhaseEntity(
        name: name,
        startDate: _startDate!,
        endDate: _endDate!,
        milestones: _selectedMilestones.toList(),
      ));
      _phaseNameController.clear();
      _startDate = null;
      _endDate = null;
      _selectedMilestones.clear();
    });
  }

  void _removePhase(int index) => setState(() => _phases.removeAt(index));

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _secondaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) { _startDate = picked; } else { _endDate = picked; }
      });
    }
  }

  Future<void> _save() async {
    final roadmap = RoadmapEntity(phases: _phases);
    final errors = RoadmapValidator.validate(roadmap);
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.first), duration: const Duration(seconds: 3)),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.onSaved(roadmap);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _submit() async {
    final roadmap = RoadmapEntity(phases: _phases);
    final errors = RoadmapValidator.validate(roadmap);
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.first), duration: const Duration(seconds: 3)),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.onSaved(roadmap);
      if (widget.onSubmit != null) await widget.onSubmit!();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(),
                const SizedBox(height: 24),
                _buildPhaseConfigCard(),
                const SizedBox(height: 16),
                _buildTipCard(),
                const SizedBox(height: 16),
                _buildTimelineCard(),
              ],
            ),
          ),
        ),
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildHero() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Implementacion del Roadmap',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
            letterSpacing: -0.4,
            height: 1.2,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Defini el ciclo de vida de tu proyecto, hitos clave y fases de emisión de créditos de agua.",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: _onSurfaceVariantColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseConfigCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_calendar_outlined, color: _secondaryColor, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Configuración de Fase',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _label('Nombre de la Fase'),
              const SizedBox(height: 6),
              _textField(controller: _phaseNameController, hint: 'ej., Desarrollo de Infraestructura'),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Comienzo Estimado'),
                        const SizedBox(height: 6),
                        _datePicker(date: _startDate, onTap: () => _pickDate(isStart: true)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Finalización Estimada'),
                        const SizedBox(height: 6),
                        _datePicker(date: _endDate, onTap: () => _pickDate(isStart: false)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _label('Hitos Clave'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Milestones.values.map((m) {
                  final selected = _selectedMilestones.contains(m);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) { _selectedMilestones.remove(m); }
                      else { _selectedMilestones.add(m); }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? _secondaryColor.withValues(alpha: 0.07) : Colors.transparent,
                        border: Border.all(
                          color: selected ? _secondaryColor : _outlineVariantColor,
                          width: selected ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            kMilestoneLabels[m] ?? m.name,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? _secondaryColor : _onSurfaceVariantColor,
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 5),
                            const Icon(Icons.check_circle_rounded, size: 13, color: _secondaryColor),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _addPhase,
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: _secondaryColor, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Agregar Fase',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryContainerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tip institucional',
                style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Asegúrate de que tus hitos estén alineados con protocolos verificados. Una documentación clara en esta etapa acelera la certificación de créditos.',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withValues(alpha: 0.8), height: 1.55),
              ),
            ],
          ),
          Positioned(
            right: -16,
            bottom: -16,
            child: Icon(Icons.verified_user_outlined, size: 110, color: Colors.white.withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.timeline, color: _secondaryColor, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Linea de Tiempo del Proyecto',
                    style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF000000), letterSpacing: -0.2),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_phases.isEmpty) _buildEmptyTimeline() else ..._buildTimelineItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTimeline() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      child: Column(
        children: [
          Icon(Icons.event_outlined, size: 38, color: _onSurfaceVariantColor.withValues(alpha: 0.35)),
          const SizedBox(height: 10),
          Text('Aún no se agregaron fases', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor.withValues(alpha: 0.65))),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineItems() {
    return List.generate(_phases.length, (i) {
      return _buildTimelineItem(phase: _phases[i], index: i, isLast: i == _phases.length - 1, isCurrent: i == 0);
    });
  }

  Widget _buildTimelineItem({required PhaseEntity phase, required int index, required bool isLast, required bool isCurrent}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent ? _cyanColor.withValues(alpha: 0.2) : _surfaceContainerHighColor,
                    border: Border.all(color: _bgColor, width: 3),
                  ),
                  child: Center(
                    child: Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: isCurrent ? _secondaryColor : _outlineVariantColor),
                    ),
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: _outlineVariantColor.withValues(alpha: 0.3))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _surfaceContainerLowColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isCurrent ? _secondaryColor.withValues(alpha: 0.3) : _outlineVariantColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isCurrent) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                            child: const Text('ACTUAL', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, color: _secondaryColor, letterSpacing: 0.8)),
                          ),
                          const Spacer(),
                        ] else ...[
                          const Spacer(),
                        ],
                        GestureDetector(
                          onTap: () => _removePhase(index),
                          child: Icon(Icons.close, size: 18, color: _onSurfaceVariantColor.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(phase.name, style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w700, color: _onSurfaceColor)),
                    const SizedBox(height: 4),
                    Text('${_fmt(phase.startDate)} → ${_fmt(phase.endDate)}', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: _onSurfaceVariantColor.withValues(alpha: 0.85))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 4,
                      children: phase.milestones.map((m) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: _cyanColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(99)),
                        child: Text(kMilestoneLabels[m] ?? m.name, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: _secondaryColor)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: _bgColor.withValues(alpha: 0.8),
            border: Border(top: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.2))),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _isSaving ? null : widget.onBack,
                          icon: const Icon(Icons.arrow_back, size: 18, color: _onSurfaceVariantColor),
                          label: const Text('Atrás', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _onSurfaceVariantColor)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        child: _isSaving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Guardar y Continuar', style: TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  if (widget.onSubmit != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.send_outlined, size: 18),
                        label: const Text('Enviar Solicitud', style: TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: _onSurfaceVariantColor.withValues(alpha: 0.8), letterSpacing: 0.4));

  Widget _textField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: _onSurfaceColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _onSurfaceVariantColor.withValues(alpha: 0.4), fontSize: 15),
        filled: true,
        fillColor: _surfaceContainerLowColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _cyanColor, width: 2)),
      ),
    );
  }

  Widget _datePicker({required DateTime? date, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(color: _surfaceContainerLowColor, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null ? _fmt(date) : 'mm/dd/yyyy',
                style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: date != null ? _onSurfaceColor : _onSurfaceVariantColor.withValues(alpha: 0.4)),
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 18, color: _onSurfaceVariantColor.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
}
