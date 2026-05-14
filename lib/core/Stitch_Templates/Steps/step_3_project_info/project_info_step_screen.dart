import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectInfoStepScreen extends StatefulWidget {
  const ProjectInfoStepScreen({super.key});

  @override
  State<ProjectInfoStepScreen> createState() => _ProjectInfoStepScreenState();
}

class _ProjectInfoStepScreenState extends State<ProjectInfoStepScreen> {
  final _formKey = GlobalKey<FormState>();

  final _projectNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _investmentController = TextEditingController();
  final _summaryController = TextEditingController();
  final _impactController = TextEditingController();

  String _category = 'Conservation';

  static const _background = Color(0xFFF7F9FB);
  static const _surface = Color(0xFFFFFFFF);
  static const _surfaceLow = Color(0xFFF2F4F6);
  static const _text = Color(0xFF191C1E);
  static const _textVariant = Color(0xFF44474D);
  static const _outlineVariant = Color(0xFFC5C6CD);
  static const _secondary = Color(0xFF006875);
  static const _cyan = Color(0xFF00E3FD);
  static const _mint = Color(0xFFA3F69C);

  @override
  void dispose() {
    _projectNameController.dispose();
    _locationController.dispose();
    _investmentController.dispose();
    _summaryController.dispose();
    _impactController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (!_formKey.currentState!.validate()) return;

    // Después esto debería conectarse con Riverpod / use case.
    // Por ahora solo navega al próximo paso.
    context.go('/roadmap-editor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      bottomNavigationBar: const _WaterLedgerBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 672),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _ProgressHeader(),
                      const SizedBox(height: 32),
                      _ProjectInfoCard(
                        formKey: _formKey,
                        projectNameController: _projectNameController,
                        locationController: _locationController,
                        investmentController: _investmentController,
                        summaryController: _summaryController,
                        impactController: _impactController,
                        category: _category,
                        onCategoryChanged: (value) {
                          if (value == null) return;
                          setState(() => _category = value);
                        },
                        onBack: () => context.pop(),
                        onContinue: _saveAndContinue,
                      ),
                      const SizedBox(height: 32),
                      const _InstitutionalVerificationCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB).withOpacity(0.92),
        border: Border(
          bottom: BorderSide(color: const Color(0xFFC5C6CD).withOpacity(0.20)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop_outlined, size: 28, color: Colors.black),
          const SizedBox(width: 16),
          const Text(
            'Water Ledger',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E8EA),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFC5C6CD).withOpacity(0.30),
              ),
            ),
            child: const Icon(Icons.person_outline, size: 22),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Step 2 of 6',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191C1E),
              ),
            ),
            Spacer(),
            Text(
              '33% Complete',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.65,
                color: Color(0xFF44474D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 6,
            color: const Color(0xFFE0E3E5),
            child: const FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.33,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF006875), Color(0xFF00E3FD)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectInfoCard extends StatelessWidget {
  const _ProjectInfoCard({
    required this.formKey,
    required this.projectNameController,
    required this.locationController,
    required this.investmentController,
    required this.summaryController,
    required this.impactController,
    required this.category,
    required this.onCategoryChanged,
    required this.onBack,
    required this.onContinue,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController projectNameController;
  final TextEditingController locationController;
  final TextEditingController investmentController;
  final TextEditingController summaryController;
  final TextEditingController impactController;
  final String category;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC5C6CD).withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Information',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191C1E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Provide the fundamental details of your water conservation or management initiative.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF44474D),
              ),
            ),
            const SizedBox(height: 32),

            _FieldLabel('Project Name'),
            _WaterLedgerTextField(
              controller: projectNameController,
              hintText: 'e.g. Murray-Darling Basin Recovery',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 24),

            _FieldLabel('Location'),
            _WaterLedgerTextField(
              controller: locationController,
              hintText: 'City, Region, or Coordinates',
              prefixIcon: Icons.location_on_outlined,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 24),

            _FieldLabel('Category'),
            DropdownButtonFormField<String>(
              value: category,
              decoration: _inputDecoration(),
              items: const [
                DropdownMenuItem(
                  value: 'Conservation',
                  child: Text('Conservation'),
                ),
                DropdownMenuItem(
                  value: 'Infrastructure',
                  child: Text('Infrastructure'),
                ),
                DropdownMenuItem(
                  value: 'Desalination',
                  child: Text('Desalination'),
                ),
                DropdownMenuItem(
                  value: 'Wastewater Recovery',
                  child: Text('Wastewater Recovery'),
                ),
              ],
              onChanged: onCategoryChanged,
            ),
            const SizedBox(height: 24),

            _FieldLabel('Estimated Investment (USD)'),
            _WaterLedgerTextField(
              controller: investmentController,
              hintText: '500,000',
              prefixIcon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 24),

            _FieldLabel('Project Summary'),
            _WaterLedgerTextField(
              controller: summaryController,
              hintText: "Briefly describe the project's core objectives...",
              maxLines: 4,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 24),

            _FieldLabel('Expected Environmental Impact'),
            _ImpactField(controller: impactController),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFF75777E)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Save and\nContinue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.65,
          color: Color(0xFF191C1E),
        ),
      ),
    );
  }
}

class _WaterLedgerTextField extends StatelessWidget {
  const _WaterLedgerTextField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: _inputDecoration(hintText: hintText, prefixIcon: prefixIcon),
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        color: Color(0xFF191C1E),
      ),
    );
  }
}

InputDecoration _inputDecoration({String? hintText, IconData? prefixIcon}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFF76849F),
      fontFamily: 'Inter',
      fontSize: 16,
    ),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, color: const Color(0xFF44474D)),
    filled: true,
    fillColor: const Color(0xFFF2F4F6),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFC5C6CD), width: 2),
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFC5C6CD), width: 2),
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF006875), width: 2),
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
    ),
  );
}

class _ImpactField extends StatelessWidget {
  const _ImpactField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00E3FD).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF006875).withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.eco_outlined, color: Color(0xFF006875)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  controller: controller,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText:
                        'Quantify the water saving or replenishment goals...',
                    hintStyle: TextStyle(
                      color: Color(0x8076849F),
                      fontFamily: 'Inter',
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    _ChipLabel(
                      text: 'REPLENISHMENT',
                      background: Color(0xFFA3F69C),
                      foreground: Color(0xFF002204),
                    ),
                    SizedBox(width: 8),
                    _ChipLabel(
                      text: 'BIODIVERSITY',
                      background: Color(0xFF9CF0FF),
                      foreground: Color(0xFF001F24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

class _InstitutionalVerificationCard extends StatelessWidget {
  const _InstitutionalVerificationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.60)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF006875).withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF006875),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Institutional Verification',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.65,
                    color: Color(0xFF191C1E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'All project data is registered for transparent impact reporting and auditing.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF44474D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterLedgerBottomNav extends StatelessWidget {
  const _WaterLedgerBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB).withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: const Color(0xFFC5C6CD).withOpacity(0.25)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(icon: Icons.home_outlined, label: 'Home'),
          _BottomNavItem(
            icon: Icons.pending_actions,
            label: 'Requests',
            selected: true,
          ),
          _BottomNavItem(icon: Icons.water_drop_outlined, label: 'Credits'),
          _BottomNavItem(icon: Icons.storefront_outlined, label: 'Market'),
          _BottomNavItem(icon: Icons.person_outline, label: 'Profile'),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF006875) : const Color(0xFF191C1E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: selected
          ? BoxDecoration(
              color: const Color(0xFF00E3FD).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.65,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
