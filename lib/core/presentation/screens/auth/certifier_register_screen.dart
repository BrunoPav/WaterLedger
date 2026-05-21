import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';

class CertifierRegisterScreen extends ConsumerStatefulWidget {
  const CertifierRegisterScreen({super.key});

  @override
  ConsumerState<CertifierRegisterScreen> createState() =>
      _CertifierRegisterScreenState();
}

class _CertifierRegisterScreenState extends ConsumerState<CertifierRegisterScreen> {
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

  // -- Step 4: Acreditación del certificador --
  final _entidadAcreditadoraController = TextEditingController();
  final _numeroAcreditacionController = TextEditingController();
  final _vigenciaAcreditacionController = TextEditingController();
  final _alcanceMaterialController = TextEditingController();
  final Set<String> _selectedEstandares = {'ISO 14046'};
  static const _estandarOptions = [
    'ISO 14046',
    'AWS',
    'VCS / Verra',
    'Gold Standard',
    'ISO 14064',
    'CDP Water',
  ];

  // -- Step 5: Credenciales de la cuenta --
  final _emailCuentaController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // -- Design tokens (alineados con DESIGN.md del template) --
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
  // Verde institucional del template (on-tertiary-container) para mensajes de aprobación.
  static const _approvalGreen = Color(0xFF469446);

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
    _entidadAcreditadoraController.dispose();
    _numeroAcreditacionController.dispose();
    _vigenciaAcreditacionController.dispose();
    _alcanceMaterialController.dispose();
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
      await ref.read(authRepositoryProvider).registerCertifier(
        email: email,
        password: password,
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
        certifierRoleData: {
          'accreditingEntity': _entidadAcreditadoraController.text.trim(),
          'accreditationNumber': _numeroAcreditacionController.text.trim(),
          'accreditationExpiry': _vigenciaAcreditacionController.text.trim(),
          'standards': _selectedEstandares.toList(),
          'materialScope': _alcanceMaterialController.text.trim(),
        },
      );
      if (!mounted) return;
      context.go('/certifier-register-success');
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
      'Acreditación\nde Certificación',
      'Credenciales\nde la Cuenta',
    ];
    const subtitles = [
      'Información institucional de la entidad certificadora.',
      'Documentos legales y contables de la organización.',
      'Datos del usuario que operará en nombre de la empresa.',
      'Organismo acreditador, estándar y alcance de la certificación.',
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
            'REGISTRO CERTIFICADOR',
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
      3 => _buildStepAcreditacion(),
      4 => _buildStepCredenciales(),
      _ => const SizedBox.shrink(),
    };
  }

  // ------------------------------------------------------------------ //
  //  HELPERS
  // ------------------------------------------------------------------ //
  // Section card del template: icono secundario + título grande (body-lg/bold).
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceLowestColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _secondaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _onSurfaceColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  // Section title sin card — para grupos como "Supporting Documentation".
  Widget _buildSectionTitle({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: _secondaryColor, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _onSurfaceColor,
              letterSpacing: -0.2,
            ),
          ),
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
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariantColor.withValues(alpha: 0.8),
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 4),
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
            // Estilo del template: bottom-border-only sobre fill, focus en cyan.
            border: const UnderlineInputBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              borderSide: BorderSide(color: _outlineVariantColor),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              borderSide: BorderSide(color: _outlineVariantColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              borderSide: BorderSide(color: _cyanColor, width: 2),
            ),
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
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariantColor.withValues(alpha: 0.8),
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _surfaceContainerLowColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(bottom: BorderSide(color: _outlineVariantColor)),
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

  // Bento card — basado en el template: borde dasheado, ícono+label centrados.
  Widget _buildBentoUpload({
    required String title,
    required IconData icon,
    String? fileName,
    required VoidCallback onTap,
  }) {
    final hasFile = fileName != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: hasFile ? _secondaryColor.withValues(alpha: 0.05) : _surfaceLowestColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? _secondaryColor : _outlineVariantColor.withValues(alpha: 0.5),
            width: hasFile ? 1.5 : 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFile ? Icons.check_circle_outline_rounded : icon,
              color: hasFile ? _secondaryColor : _onSurfaceVariantColor,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              hasFile ? 'Archivo cargado' : title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasFile ? _secondaryColor : _onSurfaceColor,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Upload row — sigue siendo útil para el doc del representante (paso 3) que tiene
  // texto descriptivo más largo que no encaja bien en bento vertical.
  Widget _buildUploadRow({
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
      title: 'Información básica',
      icon: Icons.corporate_fare,
      children: [
        _buildField(label: 'Nombre de fantasía', controller: _nombreFantasiaController, hint: 'e.g. Aqua Certifiers'),
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
        _buildField(
          label: 'Fecha de constitución',
          controller: _fechaConstitucionController,
          hint: 'DD/MM/AAAA',
          suffix: const Icon(Icons.calendar_today_outlined, size: 18, color: _onSurfaceVariantColor),
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
  //  PASO 2 — DOCUMENTACIÓN (bento style del template)
  // ------------------------------------------------------------------ //
  Widget _buildStepDocumentacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          title: 'Documentación de respaldo',
          icon: Icons.cloud_upload_outlined,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 16),
          child: Text(
            'Cargá los documentos legales y contables que respaldan la operación de la entidad.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: _onSurfaceVariantColor.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ),
        // Bento grid 2 columnas (la 3ra se expande full-width como en el template).
        Row(
          children: [
            Expanded(
              child: _buildBentoUpload(
                icon: Icons.description_outlined,
                title: 'Estatuto o acta constitutiva',
                fileName: _estatutoFileName,
                onTap: () => setState(() => _estatutoFileName = 'estatuto.pdf'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoUpload(
                icon: Icons.receipt_long_outlined,
                title: 'Constancia de inscripción fiscal',
                fileName: _constanciaFiscalFileName,
                onTap: () => setState(() => _constanciaFiscalFileName = 'constancia_fiscal.pdf'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildBentoUpload(
          icon: Icons.balance_outlined,
          title: 'Último balance firmado',
          fileName: _balanceFileName,
          onTap: () => setState(() => _balanceFileName = 'balance.pdf'),
        ),
        const SizedBox(height: 16),
        // Nota de formato
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _surfaceContainerLowColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: _onSurfaceVariantColor.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Formatos aceptados: PDF · Máx. 10 MB por archivo',
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
  //  PASO 3 — REPRESENTANTE
  // ------------------------------------------------------------------ //
  Widget _buildStepRepresentante() {
    return _buildSectionCard(
      title: 'Representante legal',
      icon: Icons.person_outline,
      children: [
        _buildUploadRow(
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
        _buildField(
          label: 'Fecha de nacimiento',
          controller: _fechaNacimientoController,
          hint: 'DD/MM/AAAA',
          suffix: const Icon(Icons.calendar_today_outlined, size: 18, color: _onSurfaceVariantColor),
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
        _buildUploadRow(
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
  //  PASO 4 — ACREDITACIÓN (Certificador específico)
  // ------------------------------------------------------------------ //
  Widget _buildStepAcreditacion() {
    return Column(
      children: [
        // Organismo y número de acreditación
        _buildSectionCard(
          title: 'Organismo acreditador',
          icon: Icons.verified_outlined,
          children: [
            _buildField(
              label: 'Entidad que lo acredita',
              controller: _entidadAcreditadoraController,
              hint: 'IRAM, ISO, GRI, Verra, etc.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    label: 'Nro. de acreditación',
                    controller: _numeroAcreditacionController,
                    hint: 'ACR-XXXXX',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    label: 'Vigencia',
                    controller: _vigenciaAcreditacionController,
                    hint: 'DD/MM/AAAA',
                    suffix: const Icon(Icons.calendar_today_outlined, size: 18, color: _onSurfaceVariantColor),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Estándares — chips multi-select estilo Operational Scope del template
        _buildSectionCard(
          title: 'Estándares de certificación',
          icon: Icons.workspace_premium_outlined,
          children: [
            Text(
              'Seleccioná los estándares bajo los cuales tu entidad está habilitada para certificar.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceVariantColor.withValues(alpha: 0.85),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? _cyanColor.withValues(alpha: 0.10) : _surfaceLowestColor,
                      border: Border.all(
                        color: selected ? _secondaryColor : _outlineVariantColor.withValues(alpha: 0.6),
                        width: selected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) ...[
                          const Icon(Icons.check_circle_rounded, size: 16, color: _secondaryColor),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          estandar,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? _secondaryColor : _onSurfaceVariantColor,
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
        // Alcance material
        _buildSectionCard(
          title: 'Alcance de la acreditación',
          icon: Icons.zoom_out_map_outlined,
          children: [
            _buildField(
              label: 'Qué tipos de proyecto puede certificar',
              controller: _alcanceMaterialController,
              hint: 'Detallá el alcance material: tipos de proyectos, sectores, regiones, etc.',
              maxLines: 4,
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
      icon: Icons.lock_outline,
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
  //  CARD — Aprobación administrativa (glass-panel + verde institucional)
  // ------------------------------------------------------------------ //
  Widget _buildAdminApprovalCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: _approvalGreen, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: _onSurfaceVariantColor,
                      height: 1.55,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Aprobación administrativa requerida — ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _approvalGreen,
                        ),
                      ),
                      TextSpan(
                        text: 'Tu organización deberá ser revisada y aprobada por un administrador de la plataforma antes de operar como certificadora.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
