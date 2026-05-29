import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/auth/presentation/widgets/register_form.dart';

class CertifierRegisterScreen extends StatefulWidget {
  const CertifierRegisterScreen({super.key});

  @override
  State<CertifierRegisterScreen> createState() =>
      _CertifierRegisterScreenState();
}

class _CertifierRegisterScreenState extends State<CertifierRegisterScreen> {
  // Shared steps 1–3 + 5
  final _empresa       = EmpresaFormControllers();
  final _representante = RepresentanteFormControllers();
  final _credenciales  = CredencialesFormControllers();

  // Step 1 — dropdown state
  String _tipoSociedad = 'SA';

  // Step 2 — upload state
  String? _estatutoFileName;
  String? _constanciaFiscalFileName;
  String? _balanceFileName;

  // Step 3 — upload state
  String? _poderActaFileName;
  String? _docVinculoFileName;

  // Step 4 — Acreditación del Certificador (Certifier-specific)
  final _entidadAcreditadora   = TextEditingController();
  final _numeroAcreditacion    = TextEditingController();
  final _vigenciaAcreditacion  = TextEditingController();
  final _alcanceMaterial       = TextEditingController();
  final Set<String> _selectedEstandares = {'ISO 14046'};
  static const _estandarOptions = [
    'ISO 14046',
    'AWS',
    'VCS / Verra',
    'Gold Standard',
    'ISO 14064',
    'CDP Water',
  ];

  // Step 5 — visibility state
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

  static const _stepTitles = [
    'Sobre la\nEmpresa',
    'Documentación\nRequerida',
    'Representante\nLegal',
    'Acreditación\nde Certificación',
    'Credenciales\nde la Cuenta',
  ];
  static const _stepSubtitles = [
    'Información institucional de la entidad certificadora.',
    'Documentos legales y contables de la organización.',
    'Datos del usuario que operará en nombre de la empresa.',
    'Organismo acreditador, estándar y alcance de la certificación.',
    'Configurá las credenciales con las que vas a acceder a la plataforma.',
  ];

  @override
  void dispose() {
    _empresa.dispose();
    _representante.dispose();
    _credenciales.dispose();
    _entidadAcreditadora.dispose();
    _numeroAcreditacion.dispose();
    _vigenciaAcreditacion.dispose();
    _alcanceMaterial.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RegisterFormTokens.bgColor,
      body: Column(
        children: [
          RegisterHeader(onBack: () => context.pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: RegisterForm(
                heroBuilder: (i) => RegisterHero(
                  badgeText: 'REGISTRO CERTIFICADOR',
                  stepTitles: _stepTitles,
                  stepSubtitles: _stepSubtitles,
                  currentStep: i,
                ),
                adminApprovalCard: const RegisterAdminApprovalCard(
                  body: 'Tu organización deberá ser revisada y aprobada por un '
                      'administrador de la plataforma antes de operar como certificadora.',
                ),
                onSubmit: () => context.go('/register-success'),
                steps: [
                  RegisterStep(
                    title: 'Empresa',
                    builder: (_) => StepEmpresaForm(
                      controllers: _empresa,
                      tipoSociedad: _tipoSociedad,
                      onTipoSociedadChanged: (v) =>
                          setState(() => _tipoSociedad = v ?? _tipoSociedad),
                    ),
                  ),
                  RegisterStep(
                    title: 'Documentación',
                    builder: (_) => StepDocumentacionForm(
                      estatutoFileName: _estatutoFileName,
                      constanciaFiscalFileName: _constanciaFiscalFileName,
                      balanceFileName: _balanceFileName,
                      onEstatutoTap: () =>
                          setState(() => _estatutoFileName = 'estatuto.pdf'),
                      onConstanciaFiscalTap: () => setState(
                          () => _constanciaFiscalFileName = 'constancia_fiscal.pdf'),
                      onBalanceTap: () =>
                          setState(() => _balanceFileName = 'balance.pdf'),
                    ),
                  ),
                  RegisterStep(
                    title: 'Representante',
                    builder: (_) => StepRepresentanteForm(
                      controllers: _representante,
                      poderActaFileName: _poderActaFileName,
                      docVinculoFileName: _docVinculoFileName,
                      onPoderActaTap: () =>
                          setState(() => _poderActaFileName = 'poder.pdf'),
                      onDocVinculoTap: () =>
                          setState(() => _docVinculoFileName = 'vinculo.pdf'),
                    ),
                  ),
                  RegisterStep(
                    title: 'Acreditación',
                    builder: (_) => _buildStepAcreditacion(),
                  ),
                  RegisterStep(
                    title: 'Credenciales',
                    builder: (_) => StepCredencialesForm(
                      controllers: _credenciales,
                      obscurePassword: _obscurePassword,
                      obscureConfirmPassword: _obscureConfirmPassword,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onToggleConfirmPassword: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  PASO 4 — ACREDITACIÓN DEL CERTIFICADOR  (Certifier-specific)
  // ------------------------------------------------------------------ //
  Widget _buildStepAcreditacion() {
    return Column(
      children: [
        RegisterSectionCard(
          title: 'Organismo acreditador',
          icon: Icons.verified_outlined,
          children: [
            RegisterField(
              label: 'Entidad que lo acredita',
              controller: _entidadAcreditadora,
              hint: 'IRAM, ISO, GRI, Verra, etc.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RegisterField(
                    label: 'Nro. de acreditación',
                    controller: _numeroAcreditacion,
                    hint: 'ACR-XXXXX',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RegisterField(
                    label: 'Vigencia',
                    controller: _vigenciaAcreditacion,
                    hint: 'DD/MM/AAAA',
                    suffix: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: RegisterFormTokens.onSurfaceVariantColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        RegisterSectionCard(
          title: 'Estándares de certificación',
          icon: Icons.workspace_premium_outlined,
          children: [
            Text(
              'Seleccioná los estándares bajo los cuales tu entidad está '
              'habilitada para certificar.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: RegisterFormTokens.onSurfaceVariantColor
                    .withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _estandarOptions.map((estandar) {
                final selected = _selectedEstandares.contains(estandar);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedEstandares.remove(estandar);
                    } else {
                      _selectedEstandares.add(estandar);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? RegisterFormTokens.cyanColor
                              .withValues(alpha: 0.10)
                          : RegisterFormTokens.surfaceLowest,
                      border: Border.all(
                        color: selected
                            ? RegisterFormTokens.secondaryColor
                            : RegisterFormTokens.outlineVariant
                                .withValues(alpha: 0.6),
                        width: selected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) ...[
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: RegisterFormTokens.secondaryColor,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          estandar,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? RegisterFormTokens.secondaryColor
                                : RegisterFormTokens.onSurfaceVariantColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RegisterSectionCard(
          title: 'Alcance de la acreditación',
          icon: Icons.zoom_out_map_outlined,
          children: [
            RegisterField(
              label: 'Qué tipos de proyecto puede certificar',
              controller: _alcanceMaterial,
              hint: 'Detallá el alcance: tipos de proyectos, sectores, regiones, etc.',
              maxLines: 4,
            ),
          ],
        ),
      ],
    );
  }
}
