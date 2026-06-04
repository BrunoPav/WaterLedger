import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/auth/presentation/widgets/register_form.dart';

class InsuranceRegisterScreen extends StatefulWidget {
  const InsuranceRegisterScreen({super.key});

  @override
  State<InsuranceRegisterScreen> createState() =>
      _InsuranceRegisterScreenState();
}

class _InsuranceRegisterScreenState extends State<InsuranceRegisterScreen> {
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

  // Step 4 — Autorización + Cobertura (Insurance-specific)
  String _organismoSupervisor = 'SSN';
  static const _organismosSupervisor = ['SSN', 'CNV', 'SSF', 'Otro'];
  final _numeroAutorizacion = TextEditingController();
  final _resolucion         = TextEditingController();
  final _vigenciaResolucion = TextEditingController();
  final Set<String> _selectedCoberturas = {'Riesgo Ambiental'};
  static const _coberturaOptions = [
    'Riesgo Ambiental',
    'Riesgo Financiero',
    'Riesgo Operacional',
    'Sostenibilidad ESG',
    'Infraestructura Hídrica',
  ];

  // Step 5 — visibility state
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

  static const _stepTitles = [
    'Sobre la\nEmpresa',
    'Documentación\nRequerida',
    'Representante\nLegal',
    'Autorización\ny Cobertura',
    'Credenciales\nde la Cuenta',
  ];
  static const _stepSubtitles = [
    'Información institucional de la entidad aseguradora.',
    'Documentos legales y contables de la organización.',
    'Datos del usuario que operará en nombre de la empresa.',
    'Datos del organismo supervisor y áreas de seguro habilitadas.',
    'Configurá las credenciales con las que vas a acceder a la plataforma.',
  ];

  @override
  void dispose() {
    _empresa.dispose();
    _representante.dispose();
    _credenciales.dispose();
    _numeroAutorizacion.dispose();
    _resolucion.dispose();
    _vigenciaResolucion.dispose();
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
                  badgeText: 'REGISTRO ASEGURADOR',
                  stepTitles: _stepTitles,
                  stepSubtitles: _stepSubtitles,
                  currentStep: i,
                ),
                adminApprovalCard: const RegisterAdminApprovalCard(
                  body: 'Tu organización deberá ser revisada y aprobada por un '
                      'administrador antes de publicar planes de seguro.',
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
                    title: 'Autorización',
                    builder: (_) => _buildStepAutorizacion(),
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
                      emailHint: 'underwriting@empresa.com',
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
  //  PASO 4 — AUTORIZACIÓN + COBERTURA  (Insurance-specific)
  // ------------------------------------------------------------------ //
  Widget _buildStepAutorizacion() {
    return Column(
      children: [
        RegisterSectionCard(
          title: 'Autorización del organismo supervisor',
          icon: Icons.account_balance_outlined,
          children: [
            RegisterDropdownField(
              label: 'Organismo supervisor',
              value: _organismoSupervisor,
              items: _organismosSupervisor,
              onChanged: (v) => setState(
                  () => _organismoSupervisor = v ?? _organismoSupervisor),
            ),
            const SizedBox(height: 16),
            RegisterField(
              label: 'N° de autorización para operar',
              controller: _numeroAutorizacion,
              hint: 'FIN-99201-B',
            ),
            const SizedBox(height: 16),
            RegisterField(
              label: 'Resolución de la Superintendencia',
              controller: _resolucion,
              hint: 'Res. SSN N° 38.708',
            ),
            const SizedBox(height: 16),
            RegisterField(
              label: 'Vigencia de la resolución',
              controller: _vigenciaResolucion,
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
          title: 'Áreas de cobertura',
          icon: Icons.grid_view_outlined,
          children: [
            Text(
              'Seleccioná los tipos de riesgo y cobertura que tu organización '
              'está habilitada a ofrecer.',
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
              children: _coberturaOptions.map((cobertura) {
                final selected = _selectedCoberturas.contains(cobertura);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedCoberturas.remove(cobertura);
                    } else {
                      _selectedCoberturas.add(cobertura);
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
                          cobertura,
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
