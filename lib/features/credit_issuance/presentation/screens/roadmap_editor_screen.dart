import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/project_phase_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/milestones.dart';
import 'package:water_ledger/features/credit_issuance/domain/validators/roadmap_validator.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/credit_request_notifier.dart';

// Labels legibles para cada hito del enum
const Map<Milestones, String> _milestoneLabels = {
  Milestones.initialAudit: 'Initial Audit',
  Milestones.meterInstalation: 'Meter Installation',
  Milestones.infrastructureValidation: 'Infrastructure Validation',
  Milestones.operativeSistem: 'Operative System',
  Milestones.firstWaterSavingRegistered: 'First Water Saving',
  Milestones.ambientalReportGenerated: 'Environmental Report',
  Milestones.proyectFinalized: 'Project Finalized',
  Milestones.impactVerificated: 'Impact Verified',
  Milestones.proyectReadyToInssue: 'Ready to Issue',
};

class RoadmapEditorScreen extends ConsumerStatefulWidget {
  const RoadmapEditorScreen({super.key});

  @override
  ConsumerState<RoadmapEditorScreen> createState() => _RoadmapEditorScreenState();
}

class _RoadmapEditorScreenState extends ConsumerState<RoadmapEditorScreen> {
  // Lista persistida de fases ya cargadas
  final List<PhaseEntity> _phases = [];

  // Buffer de la fase que el usuario está completando ahora mismo
  final _phaseNameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final Set<Milestones> _selectedMilestones = {};

  // -- Design tokens (consistentes con resto de la app) --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _onPrimaryColor = Color(0xFFFFFFFF);
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

  // ------------------------------------------------------------------ //
  //  BUFFER → PhaseEntity
  // ------------------------------------------------------------------ //
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

  void _removePhase(int index) {
    setState(() => _phases.removeAt(index));
  }

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
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveAndContinue() async {
    final roadmap = RoadmapEntity(phases: _phases);
    final errors = RoadmapValidator.validate(roadmap);
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.first), duration: const Duration(seconds: 3)),
      );
      return;
    }

    try {
      await ref.read(creditRequestProvider.notifier).updateRoadmap(roadmap);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Roadmap guardado correctamente ✓'),
          backgroundColor: _secondaryColor,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  // ------------------------------------------------------------------ //
  //  BUILD
  // ------------------------------------------------------------------ //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepProgress(),
                  const SizedBox(height: 24),
                  _buildHero(),
                  const SizedBox(height: 24),
                  _buildPhaseConfigCard(),
                  const SizedBox(height: 16),
                  _buildInstitutionalTipCard(),
                  const SizedBox(height: 16),
                  _buildTimelineCard(),
                ],
              ),
            ),
          ),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  HEADER
  // ------------------------------------------------------------------ //
  Widget _buildHeader(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: _bgColor.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.1)),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: _onSurfaceVariantColor, size: 22),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.water_drop, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Water Ledger',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _primaryColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  STEP PROGRESS — "Step 4 of 6 · 66% Complete"
  // ------------------------------------------------------------------ //
  Widget _buildStepProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP 4 OF 6',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _secondaryColor,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '66% Complete',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _onSurfaceVariantColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Stack(
            children: [
              Container(
                height: 6,
                color: _surfaceContainerHighColor,
              ),
              FractionallySizedBox(
                widthFactor: 0.66,
                child: Container(
                  height: 6,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_secondaryColor, _cyanColor],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  HERO — título y descripción
  // ------------------------------------------------------------------ //
  Widget _buildHero() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Implementation Roadmap',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
            letterSpacing: -0.4,
            height: 1.2,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Define your project's lifecycle, key milestones, and water credit issuance phases.",
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

  // ------------------------------------------------------------------ //
  //  CARD — Phase Configuration (editor de fase actual)
  // ------------------------------------------------------------------ //
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
                  Icon(Icons.edit_calendar_outlined, color: _secondaryColor, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Phase Configuration',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel('Project Phase Name'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _phaseNameController,
                hint: 'e.g., Infrastructure Development',
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Start Date'),
                        const SizedBox(height: 6),
                        _buildDatePickerButton(
                          date: _startDate,
                          onTap: () => _pickDate(isStart: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Estimated Completion'),
                        const SizedBox(height: 6),
                        _buildDatePickerButton(
                          date: _endDate,
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildLabel('Key Milestones'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Milestones.values.map((m) {
                  final selected = _selectedMilestones.contains(m);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) {
                        _selectedMilestones.remove(m);
                      } else {
                        _selectedMilestones.add(m);
                      }
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
                            _milestoneLabels[m] ?? m.name,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? _secondaryColor : _onSurfaceVariantColor,
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 5),
                            Icon(Icons.check_circle_rounded, size: 13, color: _secondaryColor),
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
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: _secondaryColor, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Add Phase',
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

  // ------------------------------------------------------------------ //
  //  CARD — Institutional Tip
  // ------------------------------------------------------------------ //
  Widget _buildInstitutionalTipCard() {
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
                'Institutional Tip',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ensure your milestones align with verified verification protocols. Clear documentation at this stage expedites credit certification and marketplace listing.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.55,
                ),
              ),
            ],
          ),
          // Ícono decorativo difuminado en la esquina
          Positioned(
            right: -16,
            bottom: -16,
            child: Icon(
              Icons.verified_user_outlined,
              size: 110,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  CARD — Visual Timeline
  // ------------------------------------------------------------------ //
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
              Row(
                children: [
                  Icon(Icons.timeline, color: _secondaryColor, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Visual Timeline',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_phases.isEmpty)
                _buildEmptyTimeline()
              else
                ..._buildTimelineItems(),
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
          Text(
            'No phases added yet',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: _onSurfaceVariantColor.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineItems() {
    final items = <Widget>[];
    for (var i = 0; i < _phases.length; i++) {
      final phase = _phases[i];
      final isLast = i == _phases.length - 1;
      final isCurrent = i == 0;
      items.add(_buildTimelineItem(
        phase: phase,
        index: i,
        isLast: isLast,
        isCurrent: isCurrent,
      ));
    }
    return items;
  }

  Widget _buildTimelineItem({
    required PhaseEntity phase,
    required int index,
    required bool isLast,
    required bool isCurrent,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Columna izquierda: dot + línea conectora
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent
                        ? _cyanColor.withValues(alpha: 0.2)
                        : _surfaceContainerHighColor,
                    border: Border.all(color: _bgColor, width: 3),
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent ? _secondaryColor : _outlineVariantColor,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _outlineVariantColor.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Card de la fase
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _surfaceContainerLowColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? _secondaryColor.withValues(alpha: 0.3)
                        : _outlineVariantColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isCurrent) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _secondaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CURRENT',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _secondaryColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const Spacer(),
                        ] else
                          const Spacer(),
                        GestureDetector(
                          onTap: () => _removePhase(index),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: _onSurfaceVariantColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      phase.name,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_fmtDate(phase.startDate)} → ${_fmtDate(phase.endDate)}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _onSurfaceVariantColor.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: phase.milestones.map((m) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _cyanColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            _milestoneLabels[m] ?? m.name,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _secondaryColor,
                            ),
                          ),
                        );
                      }).toList(),
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

  // ------------------------------------------------------------------ //
  //  BOTTOM ACTIONS (sticky)
  // ------------------------------------------------------------------ //
  Widget _buildBottomActions(BuildContext context) {
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
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, size: 18, color: _onSurfaceVariantColor),
                      label: const Text(
                        'Back',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _onSurfaceVariantColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: _onPrimaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: const StadiumBorder(),
                      elevation: 1,
                    ),
                    child: const Text(
                      'Save and Continue',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  HELPERS
  // ------------------------------------------------------------------ //
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _onSurfaceVariantColor.withValues(alpha: 0.8),
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _cyanColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildDatePickerButton({required DateTime? date, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _surfaceContainerLowColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null ? _fmtDate(date) : 'mm/dd/yyyy',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: date != null
                      ? _onSurfaceColor
                      : _onSurfaceVariantColor.withValues(alpha: 0.4),
                ),
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 18, color: _onSurfaceVariantColor.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
  }
}
