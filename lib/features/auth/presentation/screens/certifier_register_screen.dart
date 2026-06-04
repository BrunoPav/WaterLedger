import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/domain/exceptions/auth_exception.dart';
import 'package:water_ledger/core/domain/validators/auth_validators.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/auth/presentation/widgets/register_form.dart';

class CertifierRegisterScreen extends ConsumerStatefulWidget {
  const CertifierRegisterScreen({super.key});

  @override
  ConsumerState<CertifierRegisterScreen> createState() =>
      _CertifierRegisterScreenState();
}

class _CertifierRegisterScreenState
    extends ConsumerState<CertifierRegisterScreen> {
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

  // Step 4 — Acreditación del Certificador (Certifier-specific)
  final _entidadAcreditadora  = TextEditingController();
  final _numeroAcreditacion   = TextEditingController();
  final _vigenciaAcreditacion = TextEditingController();
  final _alcanceMaterial      = TextEditingController();
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

  // ------------------------------------------------------------------ //
  //  FILE PICKER
  // ------------------------------------------------------------------ //
  Future<void> _pickFile(String docType) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;
    final file = result.files.first;
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

    final companyData = {
      'fantasyName':         _empresa.nombreFantasia.text.trim(),
      'razonSocial':         _empresa.razonSocial.text.trim(),
      'cuit':                _empresa.cuit.text.trim(),
      'tipoSociedad':        _tipoSociedad,
      'pais':                _empresa.pais.text.trim(),
      'provincia':           _empresa.provincia.text.trim(),
      'domicilioLegal':      _empresa.domicilioLegal.text.trim(),
      'fechaConstitucion':   _empresa.fechaConstitucion.text.trim(),
      'sitioWeb':            _empresa.sitioWeb.text.trim(),
      'telefonoCorporativo': _empresa.telefonoCorporativo.text.trim(),
      'emailInstitucional':  _empresa.emailInstitucional.text.trim(),
      'correspondencia':     _empresa.correspondencia.text.trim(),
    };

    final representativeData = {
      'nombreApellido':  _representante.nombreApellido.text.trim(),
      'dniCuil':         _representante.dniCuil.text.trim(),
      'fechaNacimiento': _representante.fechaNacimiento.text.trim(),
      'nacionalidad':    _representante.nacionalidad.text.trim(),
      'email':           _representante.email.text.trim(),
      'telefonoCelular': _representante.telefonoCelular.text.trim(),
      'cargoFuncion':    _representante.cargoFuncion.text.trim(),
    };

    final certifierRoleData = {
      'entidadAcreditadora':  _entidadAcreditadora.text.trim(),
      'numeroAcreditacion':   _numeroAcreditacion.text.trim(),
      'vigenciaAcreditacion': _vigenciaAcreditacion.text.trim(),
      'alcanceMaterial':      _alcanceMaterial.text.trim(),
      'estandares':           _selectedEstandares.toList(),
    };

    try {
      final user = await ref.read(authRepositoryProvider).registerCertifier(
        email: email,
        password: password,
        companyData: companyData,
        representativeData: representativeData,
        certifierRoleData: certifierRoleData,
      );

      final urlUpdates = <String, dynamic>{};

      Future<void> tryUpload(
          PlatformFile? file, String docType, String firestoreKey) async {
        if (file == null) return;
        try {
          final url = await _uploadFile(user.uid, docType, file);
          if (url != null) urlUpdates[firestoreKey] = url;
        } catch (_) {}
      }

      await Future.wait([
        tryUpload(_estatutoFile,         'estatuto',         'companyData.estatutoUrl'),
        tryUpload(_constanciaFiscalFile, 'constanciaFiscal', 'companyData.constanciaFiscalUrl'),
        tryUpload(_balanceFile,          'balance',          'companyData.balanceUrl'),
        tryUpload(_poderActaFile,        'poderActa',        'representativeData.poderActaUrl'),
        tryUpload(_docVinculoFile,       'docVinculo',       'representativeData.docVinculoUrl'),
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

  Future<String?> _uploadFile(
      String uid, String docType, PlatformFile file) async {
    final mime = _mimeType(file.name);
    final storageRef = FirebaseStorage.instance
        .ref('registrations/$uid/$docType/${file.name}');
    final UploadTask task;
    if (file.bytes != null) {
      task = storageRef.putData(
          file.bytes!, SettableMetadata(contentType: mime));
    } else if (file.path != null) {
      task = storageRef.putFile(
          io.File(file.path!), SettableMetadata(contentType: mime));
    } else {
      return null;
    }
    final snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  String _mimeType(String filename) {
    switch (filename.toLowerCase().split('.').last) {
      case 'pdf':  return 'application/pdf';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png':  return 'image/png';
      default:     return 'application/octet-stream';
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
                  badgeText: 'REGISTRO CERTIFICADOR',
                  stepTitles: _stepTitles,
                  stepSubtitles: _stepSubtitles,
                  currentStep: i,
                ),
                adminApprovalCard: const RegisterAdminApprovalCard(
                  body: 'Tu organización deberá ser revisada y aprobada por un '
                      'administrador de la plataforma antes de operar como certificadora.',
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
                    title: 'Acreditación',
                    validate: () => AuthValidators.firstError([
                      () => AuthValidators.required(_entidadAcreditadora.text.trim(), 'la entidad acreditadora'),
                      () => AuthValidators.required(_numeroAcreditacion.text.trim(), 'el número de acreditación'),
                    ]),
                    builder: (_) => _buildStepAcreditacion(),
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
  //  PASO 4 — ACREDITACIÓN DEL CERTIFICADOR
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
