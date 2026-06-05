import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/auth/domain/exceptions/auth_exception.dart';
import 'package:water_ledger/features/auth/domain/validators/auth_validators.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/auth/presentation/widgets/b2b_register_upload.dart';
import 'package:water_ledger/features/auth/presentation/widgets/register_form.dart';

class InsuranceRegisterScreen extends ConsumerStatefulWidget {
  const InsuranceRegisterScreen({super.key});

  @override
  ConsumerState<InsuranceRegisterScreen> createState() =>
      _InsuranceRegisterScreenState();
}

class _InsuranceRegisterScreenState
    extends ConsumerState<InsuranceRegisterScreen> with B2bRegisterUpload {
  // Shared steps 1–3 + 5
  final _empresa       = EmpresaFormControllers();
  final _representante = RepresentanteFormControllers();
  final _credenciales  = CredencialesFormControllers();

  // Step 1 — dropdown state
  String _tipoSociedad = 'SA';

  // Step 2 — picked files
  PlatformFile? _estatutoFile;
  PlatformFile? _constanciaFiscalFile;
  PlatformFile? _balanceFile;

  // Step 3 — picked files
  PlatformFile? _poderActaFile;
  PlatformFile? _docVinculoFile;

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

  // ------------------------------------------------------------------ //
  //  FILE PICKER
  // ------------------------------------------------------------------ //
  Future<void> _pickFile(String docType) async {
    final file = await pickDocument();
    if (file == null || !mounted) return;
    setState(() {
      switch (docType) {
        case 'estatuto':         _estatutoFile         = file;
        case 'constanciaFiscal': _constanciaFiscalFile = file;
        case 'balance':          _balanceFile          = file;
        case 'poderActa':        _poderActaFile        = file;
        case 'docVinculo':       _docVinculoFile       = file;
      }
    });
  }

  // ------------------------------------------------------------------ //
  //  SUBMIT
  // ------------------------------------------------------------------ //
  Future<void> _submit() async {
    final email    = _credenciales.email.text.trim();
    final password = _credenciales.password.text;
    final confirm  = _credenciales.confirmPassword.text;

    if (password != confirm) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    final companyData = _empresa.toFirestoreMap(_tipoSociedad);
    final representativeData = _representante.toFirestoreMap();

    final insurerRoleData = {
      'organismoSupervisor': _organismoSupervisor,
      'numeroAutorizacion':  _numeroAutorizacion.text.trim(),
      'resolucion':          _resolucion.text.trim(),
      'vigenciaResolucion':  _vigenciaResolucion.text.trim(),
      'coberturas':          _selectedCoberturas.toList(),
    };

    try {
      final user = await ref.read(authRepositoryProvider).registerInsurer(
        email: email,
        password: password,
        companyData: companyData,
        representativeData: representativeData,
        insurerRoleData: insurerRoleData,
      );

      final urlUpdates = await uploadDocuments(user.uid, [
        (file: _estatutoFile,         docType: 'estatuto',         firestoreKey: 'companyData.estatutoUrl'),
        (file: _constanciaFiscalFile, docType: 'constanciaFiscal', firestoreKey: 'companyData.constanciaFiscalUrl'),
        (file: _balanceFile,          docType: 'balance',          firestoreKey: 'companyData.balanceUrl'),
        (file: _poderActaFile,        docType: 'poderActa',        firestoreKey: 'representativeData.poderActaUrl'),
        (file: _docVinculoFile,       docType: 'docVinculo',       firestoreKey: 'representativeData.docVinculoUrl'),
      ]);

      if (urlUpdates.isNotEmpty) {
        await ref
            .read(authRepositoryProvider)
            .updateProfile(uid: user.uid, updates: urlUpdates);
      }

      if (!mounted) return;
      context.go('/register-success');
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ocurrió un error inesperado. Intentá nuevamente.')),
      );
    }
  }

  // ------------------------------------------------------------------ //
  //  BUILD
  // ------------------------------------------------------------------ //
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
                onSubmit: _submit,
                steps: [
                  RegisterStep(
                    title: 'Empresa',
                    validate: () => AuthValidators.firstError([
                      () => AuthValidators.required(_empresa.nombreFantasia.text.trim(), 'el nombre de fantasía'),
                      () => AuthValidators.required(_empresa.razonSocial.text.trim(), 'la razón social'),
                      () => AuthValidators.cuit(_empresa.cuit.text.trim()),
                      () => AuthValidators.required(_empresa.pais.text.trim(), 'el país'),
                      () => AuthValidators.required(_empresa.domicilioLegal.text.trim(), 'el domicilio legal'),
                    ]),
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
                      estatutoFileName: _estatutoFile?.name,
                      constanciaFiscalFileName: _constanciaFiscalFile?.name,
                      balanceFileName: _balanceFile?.name,
                      onEstatutoTap:         () { _pickFile('estatuto'); },
                      onConstanciaFiscalTap: () { _pickFile('constanciaFiscal'); },
                      onBalanceTap:          () { _pickFile('balance'); },
                    ),
                  ),
                  RegisterStep(
                    title: 'Representante',
                    validate: () => AuthValidators.firstError([
                      () => AuthValidators.required(_representante.nombreApellido.text.trim(), 'el nombre y apellido'),
                      () => AuthValidators.required(_representante.dniCuil.text.trim(), 'el DNI o CUIL'),
                      () => AuthValidators.email(_representante.email.text.trim()),
                      () => AuthValidators.phone(_representante.telefonoCelular.text.trim()),
                      () => AuthValidators.required(_representante.cargoFuncion.text.trim(), 'el cargo o función'),
                    ]),
                    builder: (_) => StepRepresentanteForm(
                      controllers: _representante,
                      poderActaFileName: _poderActaFile?.name,
                      docVinculoFileName: _docVinculoFile?.name,
                      onPoderActaTap:  () { _pickFile('poderActa'); },
                      onDocVinculoTap: () { _pickFile('docVinculo'); },
                    ),
                  ),
                  RegisterStep(
                    title: 'Autorización',
                    validate: () => AuthValidators.firstError([
                      () => AuthValidators.required(_numeroAutorizacion.text.trim(), 'el número de autorización'),
                      () => AuthValidators.required(_resolucion.text.trim(), 'la resolución'),
                    ]),
                    builder: (_) => _buildStepAutorizacion(),
                  ),
                  RegisterStep(
                    title: 'Credenciales',
                    validate: () => AuthValidators.firstError([
                      () => AuthValidators.email(_credenciales.email.text.trim()),
                      () => AuthValidators.password(_credenciales.password.text),
                      () => AuthValidators.passwordConfirm(_credenciales.confirmPassword.text, _credenciales.password.text),
                    ]),
                    builder: (_) => StepCredencialesForm(
                      controllers: _credenciales,
                      obscurePassword: _obscurePassword,
                      obscureConfirmPassword: _obscureConfirmPassword,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onToggleConfirmPassword: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
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
  //  PASO 4 — AUTORIZACIÓN + COBERTURA
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
            RegisterMultiChipSelector(
              options: _coberturaOptions,
              selected: _selectedCoberturas,
              onToggle: (cobertura) => setState(() {
                if (!_selectedCoberturas.add(cobertura)) {
                  _selectedCoberturas.remove(cobertura);
                }
              }),
            ),
          ],
        ),
      ],
    );
  }
}
