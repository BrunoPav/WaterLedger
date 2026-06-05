import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/auth/domain/exceptions/auth_exception.dart';
import 'package:water_ledger/features/auth/domain/validators/auth_validators.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/auth/presentation/widgets/b2b_register_upload.dart';
import 'package:water_ledger/features/auth/presentation/widgets/register_form.dart';

class AuditorRegisterScreen extends ConsumerStatefulWidget {
  const AuditorRegisterScreen({super.key});

  @override
  ConsumerState<AuditorRegisterScreen> createState() =>
      _AuditorRegisterScreenState();
}

class _AuditorRegisterScreenState
    extends ConsumerState<AuditorRegisterScreen> with B2bRegisterUpload {
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

  // Step 4 — Habilitación Profesional (Auditor-specific)
  final _matricula          = TextEditingController();
  final _entidadEmisora     = TextEditingController();
  final _organismoRegulador = TextEditingController();
  final _vigenciaMatricula  = TextEditingController();
  final _polizaMonto        = TextEditingController();
  final _polizaVigencia     = TextEditingController();
  final _anosExperiencia    = TextEditingController();
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

  // ------------------------------------------------------------------ //
  //  FILE PICKER
  // ------------------------------------------------------------------ //
  Future<void> _pickFile(String docType) async {
    final file = await pickDocument();
    if (file == null || !mounted) return;
    setState(() {
      switch (docType) {
        case 'estatuto':        _estatutoFile        = file;
        case 'constanciaFiscal': _constanciaFiscalFile = file;
        case 'balance':         _balanceFile         = file;
        case 'poderActa':       _poderActaFile       = file;
        case 'docVinculo':      _docVinculoFile      = file;
      }
    });
  }

  // ------------------------------------------------------------------ //
  //  SUBMIT — crea usuario, sube archivos, actualiza Firestore
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

    final auditorRoleData = {
      'matricula':          _matricula.text.trim(),
      'entidadEmisora':     _entidadEmisora.text.trim(),
      'organismoRegulador': _organismoRegulador.text.trim(),
      'vigenciaMatricula':  _vigenciaMatricula.text.trim(),
      'polizaMonto':        _polizaMonto.text.trim(),
      'polizaVigencia':     _polizaVigencia.text.trim(),
      'anosExperiencia':    _anosExperiencia.text.trim(),
      'certificaciones':    _selectedCertificaciones.toList(),
    };

    try {
      final user = await ref.read(authRepositoryProvider).registerAuditor(
        email: email,
        password: password,
        auditorType: _tipoSociedad,
        companyData: companyData,
        representativeData: representativeData,
        auditorRoleData: auditorRoleData,
      );

      // Subir documentos a Storage (best-effort) y recopilar URLs
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
                  badgeText: 'REGISTRO AUDITOR',
                  stepTitles: _stepTitles,
                  stepSubtitles: _stepSubtitles,
                  currentStep: i,
                ),
                adminApprovalCard: const RegisterAdminApprovalCard(
                  body: 'Tu cuenta quedará pendiente hasta ser revisada y aprobada '
                      'por un administrador de la plataforma.',
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
                      onEstatutoTap:        () { _pickFile('estatuto'); },
                      onConstanciaFiscalTap:() { _pickFile('constanciaFiscal'); },
                      onBalanceTap:         () { _pickFile('balance'); },
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
                    title: 'Habilitación',
                    validate: () => AuthValidators.firstError([
                      () => AuthValidators.required(_matricula.text.trim(), 'el número de matrícula'),
                      () => AuthValidators.required(_entidadEmisora.text.trim(), 'la entidad emisora'),
                      () => AuthValidators.required(_organismoRegulador.text.trim(), 'el organismo regulador'),
                    ]),
                    builder: (_) => _buildStepHabilitacion(),
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
  //  PASO 4 — HABILITACIÓN PROFESIONAL
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
            RegisterMultiChipSelector(
              options: _certOptions,
              selected: _selectedCertificaciones,
              onToggle: (cert) => setState(() {
                if (!_selectedCertificaciones.add(cert)) {
                  _selectedCertificaciones.remove(cert);
                }
              }),
            ),
          ],
        ),
      ],
    );
  }
}
