import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/core/presentation/widgets/date_picker_field.dart';

class AuditorRegisterScreen extends ConsumerStatefulWidget {
  const AuditorRegisterScreen({super.key});

  @override
  ConsumerState<AuditorRegisterScreen> createState() => _AuditorRegisterScreenState();
}

class _AuditorRegisterScreenState extends ConsumerState<AuditorRegisterScreen> {
  int _currentStep = 0;
  // Actualizado de 4 a 5 al sumar el paso de credenciales de la cuenta al final del flujo:
  // static const int _totalSteps = 4;
  static const int _totalSteps = 5;

  // -- Step 1: Empresa --
  final _nombreFantasiaController = TextEditingController();
  final _razonSocialController = TextEditingController();
  final _cuitController = TextEditingController();
  String _tipoSociedad = 'SA';
  static const _tiposSociedad = ['SA', 'SRL', 'SAS', 'Sociedad Simple', 'Otra'];
  final _paisController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _domicilioLegalController = TextEditingController();
  final _fechaConstitucionController = TextEditingController();
  final _sitioWebController = TextEditingController();
  final _telefonoCorporativoController = TextEditingController();
  final _emailInstitucionalController = TextEditingController();
  final _correspondenciaController = TextEditingController();

  // -- Step 2: Documentación --
  String? _estatutoFileName;
  String? _constanciaFiscalFileName;
  String? _balanceFileName;

  // -- Step 3: Representante --
  String? _poderActaFileName;
  final _nombreApellidoController = TextEditingController();
  final _dniCuilController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _nacionalidadController = TextEditingController();
  final _emailRepController = TextEditingController();
  final _telefonoCelularController = TextEditingController();
  final _cargoFuncionController = TextEditingController();
  String? _docVinculoFileName;

  // -- Step 4: Habilitación Profesional --
  final _matriculaController = TextEditingController();
  final _entidadEmisoraController = TextEditingController();
  final _organismoReguladorController = TextEditingController();
  final _vigenciaMatriculaController = TextEditingController();
  final _polizaMontoController = TextEditingController();
  final _polizaVigenciaController = TextEditingController();
  final _anosExperienciaController = TextEditingController();
  final Set<String> _selectedCertificaciones = {'ISO 14001'};
  static const _certOptions = ['ISO 14001', 'GRI', 'ISO 14046', 'AWS', 'Verra'];

  // -- Step 5: Credenciales de la cuenta --
  final _emailCuentaController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // -- Design tokens --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _onPrimaryColor = Color(0xFFFFFFFF);
  static const _secondaryColor = Color(0xFF006875);
  static const _cyanColor = Color(0xFF00E3FD);
  static const _onSurfaceColor = Color(0xFF191C1E);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _surfaceContainerLowColor = Color(0xFFF2F4F6);
  static const _surfaceContainerColor = Color(0xFFECEEF0);
  static const _surfaceLowestColor = Color(0xFFFFFFFF);
  static const _outlineVariantColor = Color(0xFFC5C6CD);

  @override
  void dispose() {
    _nombreFantasiaController.dispose();
    _razonSocialController.dispose();
    _cuitController.dispose();
    _paisController.dispose();
    _provinciaController.dispose();
    _domicilioLegalController.dispose();
    _fechaConstitucionController.dispose();
    _sitioWebController.dispose();
    _telefonoCorporativoController.dispose();
    _emailInstitucionalController.dispose();
    _correspondenciaController.dispose();
    _nombreApellidoController.dispose();
    _dniCuilController.dispose();
    _fechaNacimientoController.dispose();
    _nacionalidadController.dispose();
    _emailRepController.dispose();
    _telefonoCelularController.dispose();
    _cargoFuncionController.dispose();
    _matriculaController.dispose();
    _entidadEmisoraController.dispose();
    _organismoReguladorController.dispose();
    _vigenciaMatriculaController.dispose();
    _polizaMontoController.dispose();
    _polizaVigenciaController.dispose();
    _anosExperienciaController.dispose();
    _emailCuentaController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _handleRegister() async {
    final email = _emailCuentaController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá email y contraseña')),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).registerAuditor(
        email: email,
        password: password,
        auditorType: 'financial', // el tipo se asignará cuando el Admin apruebe
        companyData: {
          'fantasyName': _nombreFantasiaController.text.trim(),
          'legalName': _razonSocialController.text.trim(),
          'cuit': _cuitController.text.trim(),
          'societyType': _tipoSociedad,
          'country': _paisController.text.trim(),
          'province': _provinciaController.text.trim(),
          'legalAddress': _domicilioLegalController.text.trim(),
          'incorporationDate': _fechaConstitucionController.text.trim(),
          'website': _sitioWebController.text.trim(),
          'phone': _telefonoCorporativoController.text.trim(),
          'institutionalEmail': _emailInstitucionalController.text.trim(),
          'mailingAddress': _correspondenciaController.text.trim(),
        },
        representativeData: {
          'fullName': _nombreApellidoController.text.trim(),
          'idNumber': _dniCuilController.text.trim(),
          'birthDate': _fechaNacimientoController.text.trim(),
          'nationality': _nacionalidadController.text.trim(),
          'email': _emailRepController.text.trim(),
          'phone': _telefonoCelularController.text.trim(),
          'position': _cargoFuncionController.text.trim(),
        },
        auditorRoleData: {
          'licenseNumber': _matriculaController.text.trim(),
          'licenseEntity': _entidadEmisoraController.text.trim(),
          'regulatoryBody': _organismoReguladorController.text.trim(),
          'licenseExpiry': _vigenciaMatriculaController.text.trim(),
          'insuranceCoverage': _polizaMontoController.text.trim(),
          'insuranceExpiry': _polizaVigenciaController.text.trim(),
          'yearsExperience': _anosExperienciaController.text.trim(),
          'certifications': _selectedCertificaciones.toList(),
        },
      );
      if (!mounted) return;
      context.go('/auditor-register-success');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrarse: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(),
                  const SizedBox(height: 20),
                  _buildStepIndicator(),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_currentStep),
                      child: _buildCurrentStep(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_currentStep == _totalSteps - 1) ...[
                    _buildAdminApprovalCard(),
                    const SizedBox(height: 24),
                  ],
                  _buildActions(context),
                ],
              ),
            ),
          ),
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
  //  HERO — título y subtítulo animados por paso
  // ------------------------------------------------------------------ //
  Widget _buildHero() {
    const titles = [
      'Sobre la\nEmpresa',
      'Documentación\nRequerida',
      'Representante\nLegal',
      'Habilitación\nProfesional',
      'Credenciales\nde la Cuenta',
    ];
    const subtitles = [
      'Información institucional de la firma auditora.',
      'Documentos legales y contables de la organización.',
      'Datos del usuario que operará en nombre de la empresa.',
      'Matrícula, organismo regulador y certificaciones del auditor.',
      'Configurá las credenciales con las que vas a acceder a la plataforma.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _cyanColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: _cyanColor.withValues(alpha: 0.25)),
          ),
          child: const Text(
            'REGISTRO AUDITOR',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _secondaryColor,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              titles[_currentStep],
              key: ValueKey('title_$_currentStep'),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
                letterSpacing: -0.7,
                height: 1.15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            subtitles[_currentStep],
            key: ValueKey('sub_$_currentStep'),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: _onSurfaceVariantColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  STEP INDICATOR — 4 barras
  // ------------------------------------------------------------------ //
  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(_totalSteps, (i) {
        final active = i <= _currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: active ? _cyanColor : _outlineVariantColor.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < _totalSteps - 1) const SizedBox(width: 6),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    return switch (_currentStep) {
      0 => _buildStepEmpresa(),
      1 => _buildStepDocumentacion(),
      2 => _buildStepRepresentante(),
      3 => _buildStepHabilitacion(),
      4 => _buildStepCredenciales(),
      _ => const SizedBox.shrink(),
    };
  }

  // ------------------------------------------------------------------ //
  //  HELPERS
  // ------------------------------------------------------------------ //
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceLowestColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariantColor.withValues(alpha: 0.7),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _onSurfaceVariantColor.withValues(alpha: 0.8),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          maxLines: maxLines,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: _onSurfaceColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _onSurfaceVariantColor.withValues(alpha: 0.4), fontSize: 15),
            suffixIcon: suffix,
            filled: true,
            fillColor: _surfaceContainerLowColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _cyanColor, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _onSurfaceVariantColor.withValues(alpha: 0.8),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _surfaceContainerLowColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: _onSurfaceColor),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    String? fileName,
    required VoidCallback onTap,
  }) {
    final hasFile = fileName != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasFile ? _secondaryColor.withValues(alpha: 0.04) : Colors.transparent,
          border: Border.all(
            color: hasFile ? _secondaryColor : _outlineVariantColor.withValues(alpha: 0.6),
            width: hasFile ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _surfaceContainerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: hasFile ? _secondaryColor : _onSurfaceVariantColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile ? fileName : title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasFile ? _secondaryColor : _onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile ? 'Archivo cargado ✓' : subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: _onSurfaceVariantColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              hasFile ? 'Cambiar' : 'Cargar',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  PASO 1 — EMPRESA
  // ------------------------------------------------------------------ //
  Widget _buildStepEmpresa() {
    return _buildSectionCard(
      title: 'Datos de la empresa',
      children: [
        _buildField(label: 'Nombre de fantasía', controller: _nombreFantasiaController, hint: 'e.g. Aqua Auditors'),
        const SizedBox(height: 16),
        _buildField(label: 'Razón social', controller: _razonSocialController, hint: 'Nombre legal completo'),
        const SizedBox(height: 16),
        _buildField(label: 'CUIT', controller: _cuitController, hint: 'XX-XXXXXXXX-X', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Tipo de sociedad',
          value: _tipoSociedad,
          items: _tiposSociedad,
          onChanged: (v) => setState(() => _tipoSociedad = v ?? _tipoSociedad),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildField(label: 'País de constitución', controller: _paisController, hint: 'Argentina')),
            const SizedBox(width: 12),
            Expanded(child: _buildField(label: 'Provincia', controller: _provinciaController, hint: 'Buenos Aires')),
          ],
        ),
        const SizedBox(height: 16),
        _buildField(label: 'Domicilio legal completo', controller: _domicilioLegalController, hint: 'Calle, Nro, Localidad, CP', maxLines: 2),
        const SizedBox(height: 16),
        DatePickerField(
          label: 'Fecha de constitución',
          controller: _fechaConstitucionController,
          // Solo fechas pasadas tienen sentido para constitución de empresa.
          lastDate: DateTime.now(),
        ),
        const SizedBox(height: 16),
        _buildField(label: 'Sitio web oficial', controller: _sitioWebController, hint: 'https://www.empresa.com', keyboardType: TextInputType.url),
        const SizedBox(height: 16),
        _buildField(label: 'Teléfono corporativo', controller: _telefonoCorporativoController, hint: '+54 11 0000-0000', keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _buildField(label: 'E-mail institucional', controller: _emailInstitucionalController, hint: 'contacto@empresa.com', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildField(label: 'Dirección de correspondencia (si difiere)', controller: _correspondenciaController, hint: 'Opcional', maxLines: 2),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  PASO 2 — DOCUMENTACIÓN
  // ------------------------------------------------------------------ //
  Widget _buildStepDocumentacion() {
    return _buildSectionCard(
      title: 'Documentación legal',
      children: [
        _buildUploadCard(
          icon: Icons.description_outlined,
          title: 'Estatuto o acta constitutiva',
          subtitle: 'PDF · Máx. 10 MB',
          fileName: _estatutoFileName,
          onTap: () => setState(() => _estatutoFileName = 'estatuto.pdf'),
        ),
        const SizedBox(height: 12),
        _buildUploadCard(
          icon: Icons.receipt_long_outlined,
          title: 'Constancia de inscripción fiscal',
          subtitle: 'AFIP / ARCA o equivalente · PDF',
          fileName: _constanciaFiscalFileName,
          onTap: () => setState(() => _constanciaFiscalFileName = 'constancia_fiscal.pdf'),
        ),
        const SizedBox(height: 12),
        _buildUploadCard(
          icon: Icons.balance_outlined,
          title: 'Último balance firmado',
          subtitle: 'PDF · Máx. 10 MB',
          fileName: _balanceFileName,
          onTap: () => setState(() => _balanceFileName = 'balance.pdf'),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  PASO 3 — REPRESENTANTE
  // ------------------------------------------------------------------ //
  Widget _buildStepRepresentante() {
    return _buildSectionCard(
      title: 'Representante legal',
      children: [
        _buildUploadCard(
          icon: Icons.gavel_outlined,
          title: 'Poder o acta habilitante',
          subtitle: 'Documento que autoriza operar en nombre de la empresa',
          fileName: _poderActaFileName,
          onTap: () => setState(() => _poderActaFileName = 'poder.pdf'),
        ),
        const SizedBox(height: 20),
        _buildField(label: 'Nombre y apellido', controller: _nombreApellidoController, hint: 'Juan Pérez'),
        const SizedBox(height: 16),
        _buildField(label: 'DNI, pasaporte o CUIL', controller: _dniCuilController, hint: '20-12345678-3', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        DatePickerField(
          label: 'Fecha de nacimiento',
          controller: _fechaNacimientoController,
          // Nadie nace en el futuro.
          lastDate: DateTime.now(),
        ),
        const SizedBox(height: 16),
        _buildField(label: 'Nacionalidad', controller: _nacionalidadController, hint: 'Argentina'),
        const SizedBox(height: 16),
        _buildField(label: 'E-mail', controller: _emailRepController, hint: 'representante@empresa.com', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildField(label: 'Teléfono celular', controller: _telefonoCelularController, hint: '+54 9 11 0000-0000', keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _buildField(label: 'Cargo o función en la empresa', controller: _cargoFuncionController, hint: 'Director / Gerente'),
        const SizedBox(height: 16),
        _buildUploadCard(
          icon: Icons.badge_outlined,
          title: 'Documento que acredita el vínculo',
          subtitle: 'Nombramiento, poder o contrato laboral',
          fileName: _docVinculoFileName,
          onTap: () => setState(() => _docVinculoFileName = 'vinculo.pdf'),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  PASO 4 — HABILITACIÓN PROFESIONAL (Auditor específico)
  // ------------------------------------------------------------------ //
  Widget _buildStepHabilitacion() {
    return Column(
      children: [
        // Matrícula y organismo
        _buildSectionCard(
          title: 'Matrícula y organismo',
          children: [
            Row(
              children: [
                Expanded(child: _buildField(label: 'Nro. de matrícula / registro', controller: _matriculaController, hint: 'MP-XXXXX')),
                const SizedBox(width: 12),
                Expanded(child: _buildField(label: 'Entidad emisora', controller: _entidadEmisoraController, hint: 'FACPCE')),
              ],
            ),
            const SizedBox(height: 16),
            _buildField(label: 'Organismo regulador', controller: _organismoReguladorController, hint: 'FACPCE, IFAC-member, etc.'),
            const SizedBox(height: 16),
            DatePickerField(
              label: 'Fecha de vigencia de la matrícula',
              controller: _vigenciaMatriculaController,
              // La vigencia es a futuro respecto al alta.
              firstDate: DateTime.now(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Póliza de seguro
        _buildSectionCard(
          title: 'Póliza de responsabilidad profesional',
          children: [
            Row(
              children: [
                Expanded(child: _buildField(label: 'Monto de cobertura', controller: _polizaMontoController, hint: 'USD 500.000', keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                  child: DatePickerField(
                    label: 'Vigencia de la póliza',
                    controller: _polizaVigenciaController,
                    firstDate: DateTime.now(),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Experiencia y certificaciones
        _buildSectionCard(
          title: 'Experiencia y certificaciones',
          children: [
            _buildField(
              label: 'Años de experiencia en proyectos hídricos o ambientales',
              controller: _anosExperienciaController,
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
                color: _onSurfaceVariantColor.withValues(alpha: 0.7),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                          cert,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? _secondaryColor : _onSurfaceVariantColor,
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.check_circle_rounded, size: 14, color: _secondaryColor),
                        ],
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

  // ------------------------------------------------------------------ //
  //  PASO 5 — CREDENCIALES DE LA CUENTA
  // ------------------------------------------------------------------ //
  Widget _buildStepCredenciales() {
    return _buildSectionCard(
      title: 'Credenciales de la cuenta',
      children: [
        _buildField(
          label: 'E-mail de la cuenta',
          controller: _emailCuentaController,
          hint: 'admin@empresa.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'Contraseña',
          controller: _passwordController,
          hint: 'Mínimo 8 caracteres',
          obscure: _obscurePassword,
          suffix: IconButton(
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: _onSurfaceVariantColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'Confirmar contraseña',
          controller: _confirmPasswordController,
          hint: 'Repetí la contraseña',
          obscure: _obscureConfirmPassword,
          suffix: IconButton(
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: _onSurfaceVariantColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _surfaceContainerLowColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, size: 16, color: _onSurfaceVariantColor.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recomendamos al menos 8 caracteres con mayúsculas, números y un símbolo.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: _onSurfaceVariantColor.withValues(alpha: 0.85),
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
  //  CARD — Aprobación administrativa
  // ------------------------------------------------------------------ //
  Widget _buildAdminApprovalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gpp_maybe_outlined, color: _secondaryColor, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aprobación administrativa requerida',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _onSurfaceColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tu cuenta quedará pendiente hasta ser revisada y aprobada por un administrador de la plataforma.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _onSurfaceVariantColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  BOTONES DE NAVEGACIÓN
  // ------------------------------------------------------------------ //
  Widget _buildActions(BuildContext context) {
    final isLastStep = _currentStep == _totalSteps - 1;
    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _prevStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Atrás', style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: _onSurfaceColor)),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading ? null : (isLastStep ? _handleRegister : _nextStep),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: _onPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastStep ? 'Enviar registro' : 'Continuar',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
