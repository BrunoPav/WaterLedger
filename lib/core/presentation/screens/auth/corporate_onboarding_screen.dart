import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CorporateOnboardingScreen extends StatefulWidget {
  const CorporateOnboardingScreen({super.key});

  @override
  State<CorporateOnboardingScreen> createState() =>
      _CorporateOnboardingScreenState();
}

class _CorporateOnboardingScreenState
    extends State<CorporateOnboardingScreen> {
  int _currentStep = 0;
  static const int _totalSteps = 3;

  // Step 1 — Entity Information
  final _companyNameController = TextEditingController();
  final _legalNameController = TextEditingController();
  final _taxIdController = TextEditingController();
  String _selectedIndustry = 'Agriculture & Forestry';
  static const _industries = [
    'Agriculture & Forestry',
    'Industrial Manufacturing',
    'Renewable Energy',
    'Municipal Infrastructure',
  ];

  // Step 2 — Localization & Contact
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Step 3 — Access Credentials
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // -- Design tokens --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _onPrimaryColor = Color(0xFFFFFFFF);
  static const _secondaryColor = Color(0xFF006875);
  static const _cyanColor = Color(0xFF00E3FD);
  static const _onSurfaceColor = Color(0xFF191C1E);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _surfaceContainerLowColor = Color(0xFFF2F4F6);
  static const _surfaceLowestColor = Color(0xFFFFFFFF);
  static const _outlineVariantColor = Color(0xFFC5C6CD);

  @override
  void dispose() {
    _companyNameController.dispose();
    _legalNameController.dispose();
    _taxIdController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildHeader(),
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
  Widget _buildHeader() {
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    Text(
                      'Step ${_currentStep + 1} of $_totalSteps',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceVariantColor,
                        letterSpacing: 0.3,
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
  //  HERO
  // ------------------------------------------------------------------ //
  Widget _buildHero() {
    const subtitles = [
      'Complete the following details to register your organization within the global water market ecosystem.',
      'Tell us where your organization is located and how to reach you.',
      'Set up secure access credentials for your Water Ledger account.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Corporate\nOnboarding',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
            letterSpacing: -0.7,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            subtitles[_currentStep],
            key: ValueKey(_currentStep),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: _onSurfaceVariantColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  STEP INDICATOR (barra de progreso en 3 segmentos)
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
                    color: active
                        ? _cyanColor
                        : _outlineVariantColor.withValues(alpha: 0.35),
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

  // ------------------------------------------------------------------ //
  //  PASO ACTUAL
  // ------------------------------------------------------------------ //
  Widget _buildCurrentStep() {
    return switch (_currentStep) {
      0 => _buildEntityInformation(),
      1 => _buildLocalizationContact(),
      2 => _buildAccessCredentials(),
      _ => const SizedBox.shrink(),
    };
  }

  // ------------------------------------------------------------------ //
  //  CARD CONTENEDOR DE FORMULARIO
  // ------------------------------------------------------------------ //
  Widget _buildFormCard({required String title, required List<Widget> fields}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceLowestColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),
          ...fields,
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  CAMPO DE TEXTO REUTILIZABLE
  // ------------------------------------------------------------------ //
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
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
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: _onSurfaceColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _onSurfaceVariantColor.withValues(alpha: 0.45),
              fontSize: 15,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: _surfaceContainerLowColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _cyanColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  STEP 1 — Entity Information
  // ------------------------------------------------------------------ //
  Widget _buildEntityInformation() {
    return _buildFormCard(
      title: 'Entity Information',
      fields: [
        _buildField(
          label: 'Company name',
          controller: _companyNameController,
          hint: 'e.g. Aqua Global',
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'Legal name',
          controller: _legalNameController,
          hint: 'Full Registered Entity Name',
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'Tax ID / CUIT',
          controller: _taxIdController,
          hint: 'XX-XXXXXXXX-X',
        ),
        const SizedBox(height: 16),
        // Dropdown de sector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Industry sector',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
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
                  value: _selectedIndustry,
                  isExpanded: true,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: _onSurfaceColor,
                  ),
                  items: _industries
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedIndustry = v ?? _selectedIndustry),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  STEP 2 — Localization & Contact
  // ------------------------------------------------------------------ //
  Widget _buildLocalizationContact() {
    return _buildFormCard(
      title: 'Localization & Contact',
      fields: [
        _buildField(
          label: 'Country',
          controller: _countryController,
          hint: 'Select Country',
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'Phone number',
          controller: _phoneController,
          hint: '+1 (555) 000-0000',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'Address',
          controller: _addressController,
          hint: 'Street, City, State, ZIP',
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  STEP 3 — Access Credentials
  // ------------------------------------------------------------------ //
  Widget _buildAccessCredentials() {
    return _buildFormCard(
      title: 'Access Credentials',
      fields: [
        _buildField(
          label: 'Corporate email',
          controller: _emailController,
          hint: 'admin@company.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'Password',
          controller: _passwordController,
          hint: '••••••••',
          obscure: _obscurePassword,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: _onSurfaceVariantColor,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  BOTONES DE NAVEGACIÓN ENTRE PASOS
  // ------------------------------------------------------------------ //
  Widget _buildActions(BuildContext context) {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Column(
      children: [
        Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                        color: _outlineVariantColor.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: _onSurfaceColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isLastStep ? () {} : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: _onPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastStep ? 'Create Account' : 'Continue',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (isLastStep) ...[
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceVariantColor,
              ),
              children: [
                const TextSpan(text: 'By creating an account, you agree to our '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Institutional Terms of Service',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: _secondaryColor,
                        decoration: TextDecoration.underline,
                        decorationColor: _secondaryColor,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account? ',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceVariantColor,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: const Text(
                'Log in',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _secondaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
