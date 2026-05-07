import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum _AccountType { retailInvestor, company }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  _AccountType _selected = _AccountType.retailInvestor;

  // -- Design tokens (mismo sistema que login_screen) --
  static const _bgColor = Color(0xFFF7F9FB);
  static const _primaryColor = Color(0xFF000000);
  static const _onPrimaryColor = Color(0xFFFFFFFF);
  static const _secondaryColor = Color(0xFF006875);
  static const _cyanColor = Color(0xFF00E3FD); // secondary-container
  static const _onSurfaceColor = Color(0xFF191C1E);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _surfaceLowestColor = Color(0xFFFFFFFF);
  static const _outlineVariantColor = Color(0xFFC5C6CD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                children: [
                  _buildTitleSection(),
                  const SizedBox(height: 32),
                  _buildCard(
                    type: _AccountType.retailInvestor,
                    icon: Icons.person_outline,
                    title: 'Retail Investor',
                    description: 'Explore and invest in water credits',
                    features: [
                      (Icons.show_chart, 'Micro-investments'),
                      (Icons.account_balance_wallet_outlined, 'Digital Wallet'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    type: _AccountType.company,
                    icon: Icons.corporate_fare,
                    title: 'Company / Organization',
                    description:
                        'Buy credits or request issuance for water sustainability projects',
                    features: [
                      (Icons.verified_outlined, 'Project Issuance'),
                      (Icons.pie_chart_outline, 'ESG Reporting'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildActions(context),
                ],
              ),
            ),
          ),
          _buildFooter(),
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
                    IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(
                        Icons.close,
                        color: _onSurfaceVariantColor,
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
  //  TÍTULO
  // ------------------------------------------------------------------ //
  Widget _buildTitleSection() {
    return const Column(
      children: [
        Text(
          'How do you want\nto register?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
            letterSpacing: -0.7,
            height: 1.2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Choose the account type that best describes your goals in the water credit ecosystem.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: _onSurfaceVariantColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  TARJETAS SELECCIONABLES
  // ------------------------------------------------------------------ //
  Widget _buildCard({
    required _AccountType type,
    required IconData icon,
    required String title,
    required String description,
    required List<(IconData, String)> features,
  }) {
    final isSelected = _selected == type;

    return GestureDetector(
      onTap: () => setState(() => _selected = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceLowestColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _cyanColor
                : _outlineVariantColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          // selection-ring: box-shadow 0 0 0 4px cyan
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _cyanColor.withValues(alpha: 0.35),
                    blurRadius: 0,
                    spreadRadius: 3,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono de tipo de cuenta
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _secondaryColor.withValues(alpha: 0.1)
                        : _primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: isSelected ? _secondaryColor : _onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: _onSurfaceVariantColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  color: _outlineVariantColor.withValues(alpha: 0.2),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: 12),
                // Feature chips
                Row(
                  children: features
                      .map(
                        (f) => Expanded(
                          child: Row(
                            children: [
                              Icon(f.$1,
                                  size: 16, color: _secondaryColor),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  f.$2,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _onSurfaceVariantColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            // Check badge cuando está seleccionado
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: _cyanColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: _secondaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  ACCIONES
  // ------------------------------------------------------------------ //
  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_selected == _AccountType.company) {
                context.push('/corporate-onboarding');
              } else {
                context.push('/retail-register');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: _onPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
              elevation: 2,
            ),
            child: const Text(
              'Continue with Registration',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account? ',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
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
                  fontWeight: FontWeight.w600,
                  color: _secondaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ //
  //  FOOTER
  // ------------------------------------------------------------------ //
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: _outlineVariantColor.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFooterBadge(Icons.lock_outline, 'End-to-end encrypted'),
                const SizedBox(width: 20),
                _buildFooterBadge(
                    Icons.verified_user_outlined, 'Institutional Grade Security'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '© 2024 Water Ledger Inc. All rights reserved.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: _onSurfaceVariantColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _onSurfaceVariantColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _onSurfaceVariantColor,
          ),
        ),
      ],
    );
  }
}
