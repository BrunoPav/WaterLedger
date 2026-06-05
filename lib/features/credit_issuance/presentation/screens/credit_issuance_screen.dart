import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/sustainability_goal_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/water_project_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/project_category.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/credit_request_notifier.dart';
import 'package:water_ledger/features/credit_issuance/presentation/widgets/roadmap_editor_step.dart';
import 'package:water_ledger/features/credit_issuance/presentation/widgets/document_upload_step.dart';
import 'package:water_ledger/features/credit_issuance/domain/validators/water_project_validator.dart';
import 'package:water_ledger/features/credit_issuance/domain/validators/roadmap_validator.dart';
import 'package:water_ledger/features/credit_issuance/domain/validators/document_validator.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _bgColor               = Color(0xFFF7F9FB);
const _primaryColor          = Color(0xFF000000);
const _secondaryColor        = Color(0xFF006875);
const _cyanColor             = Color(0xFF00E3FD);
const _onSurfaceColor        = Color(0xFF191C1E);
const _onSurfaceVariantColor = Color(0xFF44474D);
const _surfaceLowColor       = Color(0xFFF2F4F6);
const _surfaceHighColor      = Color(0xFFE6E8EA);
const _outlineVariantColor   = Color(0xFFC5C6CD);

const _totalSteps = 6;

final Map<ProjectCategory, String> _categoryLabels = {
  ProjectCategory.industrial:     'Industrial',
  ProjectCategory.agricultural:   'Agricultural',
  ProjectCategory.sanitation:     'Sanitation',
  ProjectCategory.infrastructure: 'Infrastructure',
  ProjectCategory.recycling:      'Water Recycling',
};

class CreditIssuanceScreen extends ConsumerStatefulWidget {
  const CreditIssuanceScreen({super.key});

  @override
  ConsumerState<CreditIssuanceScreen> createState() => _CreditIssuanceScreenState();
}

class _CreditIssuanceScreenState extends ConsumerState<CreditIssuanceScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // ── Step 1: Project Info ────────────────────────────────────────────────────
  final _formKey1 = GlobalKey<FormState>();
  final _nameCtrl        = TextEditingController();
  final _locationCtrl    = TextEditingController();
  final _investmentCtrl  = TextEditingController();
  final _summaryCtrl     = TextEditingController();
  final _impactCtrl      = TextEditingController();
  ProjectCategory _category = ProjectCategory.infrastructure;

  // ── Step 2: Objectives + Credit Amount ─────────────────────────────────────
  final _formKey2        = GlobalKey<FormState>();
  final _objectiveCtrl   = TextEditingController();
  final _goalDescCtrl    = TextEditingController();
  final _environmentCtrl = TextEditingController();
  final _creditAmtCtrl   = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _investmentCtrl.dispose();
    _summaryCtrl.dispose();
    _impactCtrl.dispose();
    _objectiveCtrl.dispose();
    _goalDescCtrl.dispose();
    _environmentCtrl.dispose();
    _creditAmtCtrl.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  // ── Step 0: Company Confirmation ────────────────────────────────────────────
  Future<void> _handleStep0Confirm() async {
    final user = ref.read(sessionProvider).value;
    if (user == null) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(creditRequestProvider.notifier).createDraft(user.uid);
      _goToStep(1);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar la solicitud. Intentá nuevamente.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Step 1: Project Info ────────────────────────────────────────────────────
  void _handleStep1Next() {
    if (!_formKey1.currentState!.validate()) return;
    _goToStep(2);
  }

  // ── Step 2: Objectives + Credit Amount ─────────────────────────────────────
  Future<void> _handleStep2Save() async {
    if (!_formKey2.currentState!.validate()) return;
    final request = ref.read(creditRequestProvider);
    final project = WaterProjectEntity(
      id: request.id,
      name: _nameCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      category: _category,
      summary: _summaryCtrl.text.trim(),
      estimatedInvestment: double.tryParse(_investmentCtrl.text.replaceAll(',', '')) ?? 0,
      expectedWaterImpact: _impactCtrl.text.trim(),
      sustainabilityGoal: SustainabilityGoalEntity(
        objective: _objectiveCtrl.text.trim(),
        description: _goalDescCtrl.text.trim(),
        benefittedEnvironment: _environmentCtrl.text.trim(),
      ),
    );
    final amount = double.tryParse(_creditAmtCtrl.text.replaceAll(',', '')) ?? 0;

    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(creditRequestProvider.notifier);
      await notifier.updateProjectInfo(project);
      await notifier.updateCreditAmount(amount);
      _goToStep(3);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar. Verificá tu conexión e intentá nuevamente.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Step 3: Roadmap (delegated to RoadmapEditorStep) ───────────────────────
  Future<void> _handleRoadmapSaved(RoadmapEntity roadmap) async {
    await ref.read(creditRequestProvider.notifier).updateRoadmap(roadmap);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Roadmap guardado ✓'), backgroundColor: _secondaryColor, duration: Duration(seconds: 2)),
    );
    _goToStep(4);
  }

  // ── Step 5: Submit ──────────────────────────────────────────────────────────
  Future<void> _handleSubmit() async {
    final request = ref.read(creditRequestProvider);
    final project = request.project;
    final roadmap = request.roadmap;

    // Safety net bloqueante: proyecto, roadmap y monto
    // (pasos 1–4 ya lo validaron inline; esto cubre navegación directa al paso 5)
    final blockingErrors = <String>[];
    if (project == null) blockingErrors.add('Falta información del proyecto (completá el paso 2).');
    if (roadmap == null) blockingErrors.add('Debe completar el roadmap (completá el paso 4).');
    if (project != null) blockingErrors.addAll(WaterProjectValidator.validate(project));
    if (roadmap != null) blockingErrors.addAll(RoadmapValidator.validate(roadmap));
    if (request.creditAmount <= 0) blockingErrors.add('La cantidad de créditos debe ser mayor a cero.');

    if (blockingErrors.isNotEmpty) {
      _showValidationErrors(blockingErrors);
      return;
    }

    // Documentación: no bloqueante — el auditor puede solicitarla después
    if (DocumentValidator.validate(request.documents).isNotEmpty) {
      _showDocumentWarning();
      return;
    }

    await _doSubmit();
  }

  Future<void> _doSubmit() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(creditRequestProvider.notifier).submitRequest();
      if (!mounted) return;
      context.pushReplacement('/submission-confirmation');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar la solicitud. Verificá tu conexión e intentá nuevamente.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Bottom sheet bloqueante — errores de proyecto/roadmap/monto
  void _showValidationErrors(List<String> errors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: _outlineVariantColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 22),
                SizedBox(width: 10),
                Text(
                  'Revisá antes de enviar',
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 17, fontWeight: FontWeight.w700, color: _onSurfaceColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Corregí los siguientes problemas para poder enviar la solicitud:',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor, height: 1.5),
            ),
            const SizedBox(height: 16),
            ...errors.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 6, color: Colors.red),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(e, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: _onSurfaceColor, height: 1.4)),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Entendido', style: TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom sheet informativo — falta documentación (no bloqueante)
  void _showDocumentWarning() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: _outlineVariantColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.info_outline, color: _secondaryColor, size: 22),
                SizedBox(width: 10),
                Text(
                  'Documentación incompleta',
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 17, fontWeight: FontWeight.w700, color: _onSurfaceColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Todavía no cargaste toda la documentación requerida. Podés adjuntarla ahora o enviar la solicitud de todas formas — el auditor asignado podrá solicitarla durante el proceso de revisión.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: _onSurfaceVariantColor, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _goToStep(4);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Entendido', style: TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _doSubmit();
                },
                child: const Text(
                  'Enviar sin documentos',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: _onSurfaceVariantColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BUILD ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildProgressBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep0(),
                _buildStep1(),
                _buildStep2(),
                RoadmapEditorStep(
                  onBack: () => _goToStep(2),
                  onSaved: _handleRoadmapSaved,
                ),
                DocumentUploadStep(
                  onBack: () => _goToStep(3),
                  onNext: () => _goToStep(5),
                ),
                _buildStep5Review(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SHARED HEADER ───────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: _bgColor.withValues(alpha: 0.75),
            border: Border(bottom: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.15))),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      IconButton(
                        onPressed: () => _goToStep(_currentStep - 1),
                        icon: const Icon(Icons.arrow_back, color: _onSurfaceVariantColor, size: 22),
                      )
                    else
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close, color: _onSurfaceVariantColor, size: 22),
                      ),
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.water_drop, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Water Ledger',
                      style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700, color: _primaryColor, letterSpacing: -0.3),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        'Paso ${_currentStep + 1}/$_totalSteps',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: _onSurfaceVariantColor),
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

  Widget _buildProgressBar() {
    final progress = (_currentStep + 1) / _totalSteps;
    return Container(
      height: 4,
      color: _surfaceHighColor,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [_secondaryColor, _cyanColor]),
          ),
        ),
      ),
    );
  }

  // ── STEP 0: Company Confirmation ────────────────────────────────────────────
  Widget _buildStep0() {
    final user = ref.watch(sessionProvider).value;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Confirmá tu empresa', style: TextStyle(fontFamily: 'Manrope', fontSize: 26, fontWeight: FontWeight.w700, color: _primaryColor, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          const Text('Revisá que los datos de tu empresa sean correctos antes de iniciar la solicitud.', style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: _onSurfaceVariantColor, height: 1.5)),
          const SizedBox(height: 32),
          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rowInfo('Nombre / Razón social', user?.displayName ?? '—'),
                const Divider(height: 24),
                _rowInfo('Email', user?.email ?? '—'),
                const Divider(height: 24),
                _rowInfo('Rol', user?.role.value ?? '—'),
                const Divider(height: 24),
                _rowInfo('Estado', user?.status.value ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: _secondaryColor.withValues(alpha: 0.15))),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: _secondaryColor, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Si tus datos están desactualizados, editá tu perfil antes de continuar.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _secondaryColor, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleStep0Confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Confirmar e Iniciar Solicitud', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── STEP 1: Project Info ────────────────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Información del Proyecto', style: TextStyle(fontFamily: 'Manrope', fontSize: 26, fontWeight: FontWeight.w700, color: _primaryColor, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text('Completá los datos fundamentales de tu iniciativa hídrica.', style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: _onSurfaceVariantColor, height: 1.5)),
            const SizedBox(height: 32),
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Nombre del Proyecto'),
                  _textField(controller: _nameCtrl, hint: 'ej. Recuperación Cuenca del Plata'),
                  const SizedBox(height: 20),
                  _fieldLabel('Ubicación'),
                  _textField(controller: _locationCtrl, hint: 'Ciudad, región o coordenadas', prefix: Icons.location_on_outlined),
                  const SizedBox(height: 20),
                  _fieldLabel('Categoría'),
                  DropdownButtonFormField<ProjectCategory>(
                    initialValue: _category,
                    decoration: _inputDecoration(),
                    items: ProjectCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(_categoryLabels[c] ?? c.name))).toList(),
                    onChanged: (v) { if (v != null) setState(() => _category = v); },
                  ),
                  const SizedBox(height: 20),
                  _fieldLabel('Inversión Estimada (USD)'),
                  _textField(controller: _investmentCtrl, hint: '500,000', prefix: Icons.payments_outlined, type: TextInputType.number),
                  const SizedBox(height: 20),
                  _fieldLabel('Resumen del Proyecto'),
                  _textField(controller: _summaryCtrl, hint: 'Describí brevemente los objetivos centrales...', maxLines: 4),
                  const SizedBox(height: 20),
                  _fieldLabel('Impacto Ambiental Esperado'),
                  _textField(controller: _impactCtrl, hint: 'Cuantificá las metas de ahorro o reposición hídrica...', maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleStep1Next,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Guardar y Continuar', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 2: Objectives + Credit Amount ─────────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Objetivos y Créditos', style: TextStyle(fontFamily: 'Manrope', fontSize: 26, fontWeight: FontWeight.w700, color: _primaryColor, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text('Definí las metas de sustentabilidad y la cantidad de créditos hídricos a emitir.', style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: _onSurfaceVariantColor, height: 1.5)),
            const SizedBox(height: 32),
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Objetivo Principal'),
                  _textField(controller: _objectiveCtrl, hint: 'ej. Reducir el consumo de agua en un 30%'),
                  const SizedBox(height: 20),
                  _fieldLabel('Descripción del Objetivo'),
                  _textField(controller: _goalDescCtrl, hint: 'Explicá cómo se alcanzará el objetivo...', maxLines: 3),
                  const SizedBox(height: 20),
                  _fieldLabel('Entorno Ambiental Beneficiado'),
                  _textField(controller: _environmentCtrl, hint: 'ej. Cuenca del Río Paraná, ecosistemas ribereños'),
                  const SizedBox(height: 28),
                  Container(
                    height: 1,
                    color: _outlineVariantColor.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 28),
                  _fieldLabel('Créditos Hídricos a Emitir (estimado)'),
                  _textField(
                    controller: _creditAmtCtrl,
                    hint: 'ej. 10000',
                    prefix: Icons.water_drop_outlined,
                    type: TextInputType.number,
                    helperText: 'Cada crédito representa 1 m³ de agua conservada o recuperada.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleStep2Save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Guardar y Continuar', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 5: Review & Submit ─────────────────────────────────────────────────
  Widget _buildStep5Review() {
    final request = ref.watch(creditRequestProvider);
    final project = request.project;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Revisión Final', style: TextStyle(fontFamily: 'Manrope', fontSize: 26, fontWeight: FontWeight.w700, color: _primaryColor, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          const Text('Revisá el resumen antes de enviar tu solicitud. Una vez enviada no podrás editar los datos.', style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: _onSurfaceVariantColor, height: 1.5)),
          const SizedBox(height: 32),
          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Proyecto'),
                _rowInfo('Nombre', project?.name ?? '—'),
                _rowInfo('Ubicación', project?.location ?? '—'),
                _rowInfo('Categoría', project != null ? (_categoryLabels[project.category] ?? project.category.name) : '—'),
                _rowInfo('Inversión estimada', project != null ? 'USD ${project.estimatedInvestment.toStringAsFixed(0)}' : '—'),
                _rowInfo('Créditos a emitir', request.creditAmount > 0 ? '${request.creditAmount.toStringAsFixed(0)} m³' : '—'),
                const Divider(height: 28),
                _sectionTitle('Objetivo de Sustentabilidad'),
                _rowInfo('Objetivo', project?.sustainabilityGoal.objective ?? '—'),
                _rowInfo('Entorno beneficiado', project?.sustainabilityGoal.benefittedEnvironment ?? '—'),
                const Divider(height: 28),
                _sectionTitle('Roadmap'),
                _rowInfo('Fases registradas', '${request.roadmap?.phases.length ?? 0} fase(s)'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _secondaryColor, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: _isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_outlined, size: 20),
                      SizedBox(width: 10),
                      Text('Enviar Solicitud', style: TextStyle(fontFamily: 'Manrope', fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _goToStep(4),
            child: const Text('Volver', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: _onSurfaceVariantColor)),
          ),
        ],
      ),
    );
  }

  // ── SHARED HELPERS ──────────────────────────────────────────────────────────
  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3, color: _onSurfaceColor)),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    IconData? prefix,
    TextInputType? type,
    int maxLines = 1,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: _onSurfaceColor),
      decoration: _inputDecoration(hint: hint, prefix: prefix, helperText: helperText),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? prefix, String? helperText}) {
    return InputDecoration(
      hintText: hint,
      helperText: helperText,
      helperMaxLines: 2,
      hintStyle: TextStyle(color: _onSurfaceVariantColor.withValues(alpha: 0.45), fontFamily: 'Inter', fontSize: 15),
      prefixIcon: prefix != null ? Icon(prefix, color: _onSurfaceVariantColor, size: 20) : null,
      filled: true,
      fillColor: _surfaceLowColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.4))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _secondaryColor, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
    );
  }

  Widget _rowInfo(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _onSurfaceVariantColor.withValues(alpha: 0.75))),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _onSurfaceColor)),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700, color: _onSurfaceColor)),
  );
}
