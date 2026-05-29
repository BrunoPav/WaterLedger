import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/auth/presentation/widgets/register_form.dart';

class AuditorRegisterScreen extends StatefulWidget {
  const AuditorRegisterScreen({super.key});

  @override
  State<AuditorRegisterScreen> createState() => _AuditorRegisterScreenState();
}

class _AuditorRegisterScreenState extends State<AuditorRegisterScreen> {
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

  // Step 4 — Habilitación Profesional (Auditor-specific)
  final _matricula            = TextEditingController();
  final _entidadEmisora       = TextEditingController();
  final _organismoRegulador   = TextEditingController();
  final _vigenciaMatricula    = TextEditingController();
  final _polizaMonto          = TextEditingController();
  final _polizaVigencia       = TextEditingController();
  final _anosExperiencia      = TextEditingController();
  final Set<String> _selectedCertificaciones = {'ISO 14001'};
  static const _certOptions = ['ISO 14001', 'GRI', 'ISO 14046', 'AWS', 'Verra'];

  // Step 5 — visibility state
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

  static const _stepTitles = [
    'Sobre la\nEmpresa',
    'Documentación\nRequerida',
    'Representante\nLegal',
    'Habilitación\nProfesional',
    'Credenciales\nde la Cuenta',
  ];
  static const _stepSubtitles = [
    'Información institucional de la firma auditora.',
    'Documentos legales y contables de la organización.',
    'Datos del usuario que operará en nombre de la empresa.',
    'Matrícula, organismo regulador y certificaciones del auditor.',
    'Configurá las credenciales con las que vas a acceder a la plataforma.',
  ];

  @override
  void dispose() {
    _empresa.dispose();
    _representante.dispose();
    _credenciales.dispose();
    _matricula.dispose();
    _entidadEmisora.dispose();
    _organismoRegulador.dispose();
    _vigenciaMatricula.dispose();
    _polizaMonto.dispose();
    _polizaVigencia.dispose();
    _anosExperiencia.dispose();
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
                  badgeText: 'REGISTRO AUDITOR',
                  stepTitles: _stepTitles,
                  stepSubtitles: _stepSubtitles,
                  currentStep: i,
                ),
                adminApprovalCard: const RegisterAdminApprovalCard(
                  body: 'Tu cuenta quedará pendiente hasta ser revisada y aprobada '
                      'por un administrador de la plataforma.',
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
                    title: 'Habilitación',
                    builder: (_) => _buildStepHabilitacion(),
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
  //  PASO 4 — HABILITACIÓN PROFESIONAL  (Auditor-specific)
  // ------------------------------------------------------------------ //
  Widget _buildStepHabilitacion() {
    return Column(
      children: [
        RegisterSectionCard(
          title: 'Matrícula y organismo',
          icon: Icons.verified_outlined,
          children: [
            Row(
              children: [
                Expanded(
                  child: RegisterField(
                    label: 'Nro. de matrícula / registro',
                    controller: _matricula,
                    hint: 'MP-XXXXX',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RegisterField(
                    label: 'Entidad emisora',
                    controller: _entidadEmisora,
                    hint: 'FACPCE',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RegisterField(
              label: 'Organismo regulador',
              controller: _organismoRegulador,
              hint: 'FACPCE, IFAC-member, etc.',
            ),
            const SizedBox(height: 16),
            RegisterField(
              label: 'Fecha de vigencia de la matrícula',
              controller: _vigenciaMatricula,
              hint: 'DD/MM/AAAA',
              suffix: const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: RegisterFormTokens.onSurfaceVariantColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RegisterSectionCard(
          title: 'Póliza de responsabilidad profesional',
          icon: Icons.verified_outlined,
          children: [
            Row(
              children: [
                Expanded(
                  child: RegisterField(
                    label: 'Monto de cobertura',
                    controller: _polizaMonto,
                    hint: 'USD 500.000',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RegisterField(
                    label: 'Vigencia de la póliza',
                    controller: _polizaVigencia,
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
          title: 'Experiencia y certificaciones',
          icon: Icons.workspace_premium_outlined,
          children: [
            RegisterField(
              label: 'Años de experiencia en proyectos hídricos o ambientales',
              controller: _anosExperiencia,
              hint: '5',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Text(
              'CERTIFICACIONES AMBIENTALES',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: RegisterFormTokens.onSurfaceVariantColor
                    .withValues(alpha: 0.7),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _certOptions.map((cert) {
                final selected = _selectedCertificaciones.contains(cert);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedCertificaciones.remove(cert);
                    } else {
                      _selectedCertificaciones.add(cert);
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
                          cert,
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
      ],
    );
  }
}
