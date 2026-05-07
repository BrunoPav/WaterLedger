import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RetailRegisterScreen extends StatefulWidget {
  const RetailRegisterScreen({super.key});

  @override
  State<RetailRegisterScreen> createState() => _RetailRegisterScreenState();
}

class _RetailRegisterScreenState extends State<RetailRegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Investment interests — los seleccionados se guardan en un Set
  static const _allInterests = [
    'Aquifer Restoration',
    'Smart Infrastructure',
    'Desalination Tech',
    'Water Rights',
  ];
  final Set<String> _selectedInterests = {'Desalination Tech'};

  // Risk profile
  String _selectedRisk = 'Medium';
  static const _riskOptions = ['Low', 'Medium', 'High'];

  // Country dropdown
  String _selectedCountry = 'United States';
  static const _countries = [
    'United States',
    'United Kingdom',
    'Singapore',
    'Australia',
  ];

  // -- Design tokens (consistentes con el resto de auth screens) --
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBrandingSection(),
                  const SizedBox(height: 32),
                  _buildFormCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  HEADER con glassmorphism
  // ------------------------------------------------------------------ //
  Widget _buildHeader(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: _bgColor.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(
                color: _outlineVariantColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Row(
                      children: [
                        Icon(Icons.water_drop, color: _secondaryColor, size: 20),
                        const SizedBox(width: 7),
                        const Text(
                          'Water Ledger',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: _primaryColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    // Login link
                    Row(
                      children: [
                        const Text(
                          'Have an account? ',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: _onSurfaceVariantColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Login',
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  SECCIÓN DE BRANDING (propuesta de valor)
  // ------------------------------------------------------------------ //
  Widget _buildBrandingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge "RETAIL INVESTOR"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _cyanColor.withValues(alpha: 0.1),
            border: Border.all(color: _cyanColor.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(99),
          ),
          child: const Text(
            'RETAIL INVESTOR',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _secondaryColor,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Headline
        const Text(
          'Invest in a\nliquid future.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
            letterSpacing: -0.8,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Join Water Ledger to access institutional-grade water assets and sustainable infrastructure projects across the globe.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: _onSurfaceVariantColor,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 20),
        // Feature cards
        _buildFeatureCard(
          icon: Icons.verified_user_outlined,
          title: 'Institutional Trust',
          subtitle:
              'Regulatory compliant fintech platform for global water trading.',
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.eco_outlined,
          title: 'Environmental Impact',
          subtitle:
              'Support aquifer restoration and smart infrastructure directly.',
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceLowestColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _secondaryColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
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
  //  CARD FORMULARIO con glassmorphism
  // ------------------------------------------------------------------ //
  Widget _buildFormCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 20),
              // First Name + Last Name en fila
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      label: 'First Name',
                      controller: _firstNameController,
                      hint: 'John',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      label: 'Last Name',
                      controller: _lastNameController,
                      hint: 'Doe',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Email Address',
                controller: _emailController,
                hint: 'john.doe@finance.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Phone Number',
                controller: _phoneController,
                hint: '+1 (555) 000-0000',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildCountryDropdown(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 24),
              _buildInterestChips(),
              const SizedBox(height: 24),
              _buildRiskProfile(),
              const SizedBox(height: 32),
              _buildSubmitButton(context),
              const SizedBox(height: 16),
              _buildTermsText(),
            ],
          ),
        ),
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
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: _onSurfaceColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _onSurfaceVariantColor.withValues(alpha: 0.4),
              fontSize: 15,
            ),
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
  //  DROPDOWN DE PAÍS
  // ------------------------------------------------------------------ //
  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country',
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
              value: _selectedCountry,
              isExpanded: true,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: _onSurfaceColor,
              ),
              items: _countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedCountry = v ?? _selectedCountry),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  CAMPO PASSWORD con toggle de visibilidad
  // ------------------------------------------------------------------ //
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
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
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: _onSurfaceColor,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: _onSurfaceVariantColor.withValues(alpha: 0.4),
              fontSize: 15,
            ),
            suffixIcon: IconButton(
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
  //  CHIPS DE INTERESES DE INVERSIÓN (opcional)
  // ------------------------------------------------------------------ //
  Widget _buildInterestChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INVESTMENT INTERESTS (OPTIONAL)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _onSurfaceVariantColor,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allInterests.map((interest) {
            final selected = _selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _selectedInterests.remove(interest);
                } else {
                  _selectedInterests.add(interest);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? _secondaryColor.withValues(alpha: 0.07)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected ? _secondaryColor : _outlineVariantColor,
                    width: selected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? _secondaryColor : _onSurfaceVariantColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  SELECTOR DE PERFIL DE RIESGO (opcional)
  // ------------------------------------------------------------------ //
  Widget _buildRiskProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RISK PROFILE (OPTIONAL)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _onSurfaceVariantColor,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(_riskOptions.length, (i) {
            final option = _riskOptions[i];
            final selected = _selectedRisk == option;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : 4,
                  right: i == _riskOptions.length - 1 ? 0 : 4,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRisk = option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? _secondaryColor.withValues(alpha: 0.07)
                          : Colors.transparent,
                      border: Border.all(
                        color:
                            selected ? _secondaryColor : _outlineVariantColor,
                        width: selected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: selected
                              ? _secondaryColor
                              : _onSurfaceVariantColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  BOTÓN CREATE ACCOUNT
  // ------------------------------------------------------------------ //
  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/retail-register-success'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _onPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Create Account',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  TEXTO DE TÉRMINOS Y POLÍTICA
  // ------------------------------------------------------------------ //
  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: _onSurfaceVariantColor,
        ),
        children: [
          const TextSpan(text: 'By signing up, you agree to our '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'Terms of Service',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: _secondaryColor,
                  decoration: TextDecoration.underline,
                  decorationColor: _secondaryColor,
                ),
              ),
            ),
          ),
          const TextSpan(text: ' and '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
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
    );
  }
}
