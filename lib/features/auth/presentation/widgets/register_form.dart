import 'dart:ui';
import 'package:flutter/material.dart';

// ======================================================================
// TOKENS
// ======================================================================

abstract class RegisterFormTokens {
  static const Color bgColor               = Color(0xFFF7F9FB);
  static const Color primaryColor          = Color(0xFF000000);
  static const Color onPrimaryColor        = Color(0xFFFFFFFF);
  static const Color secondaryColor        = Color(0xFF006875);
  static const Color cyanColor             = Color(0xFF00E3FD);
  static const Color onSurfaceColor        = Color(0xFF191C1E);
  static const Color onSurfaceVariantColor = Color(0xFF44474D);
  static const Color surfaceContainerLow   = Color(0xFFF2F4F6);
  static const Color surfaceContainer      = Color(0xFFECEEF0);
  static const Color surfaceLowest         = Color(0xFFFFFFFF);
  static const Color outlineVariant        = Color(0xFFC5C6CD);
  static const Color primaryContainer      = Color(0xFF0D1C32);
  static const Color onPrimaryContainer    = Color(0xFF76849F);
  static const Color cyanDim               = Color(0xFF00DAF3);
}

// ======================================================================
// REGISTER HEADER
// ======================================================================

class RegisterHeader extends StatelessWidget {
  final VoidCallback onBack;
  const RegisterHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: RegisterFormTokens.bgColor.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(
                color: RegisterFormTokens.outlineVariant.withValues(alpha: 0.1),
              ),
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
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: RegisterFormTokens.onSurfaceVariantColor,
                        size: 22,
                      ),
                    ),
                    const Text(
                      'Water Ledger',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: RegisterFormTokens.primaryColor,
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
}

// ======================================================================
// REGISTER HERO
// ======================================================================

class RegisterHero extends StatelessWidget {
  final String badgeText;
  final List<String> stepTitles;
  final List<String> stepSubtitles;
  final int currentStep;

  const RegisterHero({
    super.key,
    required this.badgeText,
    required this.stepTitles,
    required this.stepSubtitles,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: RegisterFormTokens.cyanColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: RegisterFormTokens.cyanColor.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            badgeText,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: RegisterFormTokens.secondaryColor,
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
              stepTitles[currentStep],
              key: ValueKey('title_$currentStep'),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: RegisterFormTokens.primaryColor,
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
            stepSubtitles[currentStep],
            key: ValueKey('sub_$currentStep'),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: RegisterFormTokens.onSurfaceVariantColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// REGISTER SECTION CARD
// ======================================================================

class RegisterSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const RegisterSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RegisterFormTokens.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RegisterFormTokens.outlineVariant.withValues(alpha: 0.3),
        ),
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
              Icon(icon, color: RegisterFormTokens.secondaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RegisterFormTokens.onSurfaceColor,
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
}

// ======================================================================
// REGISTER FIELD
// ======================================================================

class RegisterField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool obscure;
  final Widget? suffix;
  final int maxLines;

  const RegisterField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.suffix,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
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
              color: RegisterFormTokens.onSurfaceVariantColor.withValues(alpha: 0.8),
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
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: RegisterFormTokens.onSurfaceColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: RegisterFormTokens.onSurfaceVariantColor.withValues(alpha: 0.4),
              fontSize: 15,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: RegisterFormTokens.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
              borderSide: const BorderSide(color: RegisterFormTokens.cyanColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// REGISTER DROPDOWN FIELD
// ======================================================================

class RegisterDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const RegisterDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
              color: RegisterFormTokens.onSurfaceVariantColor.withValues(alpha: 0.8),
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: RegisterFormTokens.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: RegisterFormTokens.onSurfaceColor,
              ),
              items: items
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// REGISTER UPLOAD TILE
// ======================================================================

class RegisterUploadTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? fileName;
  final VoidCallback onTap;

  const RegisterUploadTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.fileName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasFile
              ? RegisterFormTokens.secondaryColor.withValues(alpha: 0.04)
              : RegisterFormTokens.surfaceContainerLow,
          border: Border.all(
            color: hasFile
                ? RegisterFormTokens.secondaryColor
                : RegisterFormTokens.outlineVariant,
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
                color: RegisterFormTokens.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: hasFile
                    ? RegisterFormTokens.secondaryColor
                    : RegisterFormTokens.onSurfaceVariantColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile ? fileName! : title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasFile
                          ? RegisterFormTokens.secondaryColor
                          : RegisterFormTokens.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile ? 'Archivo cargado ✓' : subtitle.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: RegisterFormTokens.onSurfaceVariantColor.withValues(alpha: 0.7),
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
              color: RegisterFormTokens.secondaryColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// REGISTER ADMIN APPROVAL CARD
// ======================================================================

class RegisterAdminApprovalCard extends StatelessWidget {
  final String body;
  const RegisterAdminApprovalCard({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RegisterFormTokens.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: RegisterFormTokens.primaryContainer.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: RegisterFormTokens.cyanDim, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aprobación administrativa requerida',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: RegisterFormTokens.onPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: RegisterFormTokens.onPrimaryContainer.withValues(alpha: 0.95),
                    height: 1.55,
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

// ======================================================================
// FORM CONTROLLER BUNDLES
// ======================================================================

// ======================================================================
// MULTI-CHIP SELECTOR (certificaciones / estándares / coberturas)
// ======================================================================

/// Grupo de "chips" seleccionables (multi-selección) reutilizable por los
/// registros B2B. Renderiza el `Wrap` de opciones; el estado (`Set`) y el
/// toggle los maneja la pantalla que lo usa.
class RegisterMultiChipSelector extends StatelessWidget {
  const RegisterMultiChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return GestureDetector(
          onTap: () => onToggle(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? RegisterFormTokens.cyanColor.withValues(alpha: 0.10)
                  : RegisterFormTokens.surfaceLowest,
              border: Border.all(
                color: isSelected
                    ? RegisterFormTokens.secondaryColor
                    : RegisterFormTokens.outlineVariant.withValues(alpha: 0.6),
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: RegisterFormTokens.secondaryColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  option,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? RegisterFormTokens.secondaryColor
                        : RegisterFormTokens.onSurfaceVariantColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class EmpresaFormControllers {
  final TextEditingController nombreFantasia  = TextEditingController();
  final TextEditingController razonSocial     = TextEditingController();
  final TextEditingController cuit            = TextEditingController();
  final TextEditingController pais            = TextEditingController();
  final TextEditingController provincia       = TextEditingController();
  final TextEditingController domicilioLegal  = TextEditingController();
  final TextEditingController fechaConstitucion = TextEditingController();
  final TextEditingController sitioWeb        = TextEditingController();
  final TextEditingController telefonoCorporativo = TextEditingController();
  final TextEditingController emailInstitucional  = TextEditingController();
  final TextEditingController correspondencia = TextEditingController();

  /// Datos institucionales de la empresa para Firestore.
  Map<String, dynamic> toFirestoreMap(String tipoSociedad) => {
        'fantasyName':         nombreFantasia.text.trim(),
        'razonSocial':         razonSocial.text.trim(),
        'cuit':                cuit.text.trim(),
        'tipoSociedad':        tipoSociedad,
        'pais':                pais.text.trim(),
        'provincia':           provincia.text.trim(),
        'domicilioLegal':      domicilioLegal.text.trim(),
        'fechaConstitucion':   fechaConstitucion.text.trim(),
        'sitioWeb':            sitioWeb.text.trim(),
        'telefonoCorporativo': telefonoCorporativo.text.trim(),
        'emailInstitucional':  emailInstitucional.text.trim(),
        'correspondencia':     correspondencia.text.trim(),
      };

  void dispose() {
    nombreFantasia.dispose();
    razonSocial.dispose();
    cuit.dispose();
    pais.dispose();
    provincia.dispose();
    domicilioLegal.dispose();
    fechaConstitucion.dispose();
    sitioWeb.dispose();
    telefonoCorporativo.dispose();
    emailInstitucional.dispose();
    correspondencia.dispose();
  }
}

class RepresentanteFormControllers {
  final TextEditingController nombreApellido  = TextEditingController();
  final TextEditingController dniCuil         = TextEditingController();
  final TextEditingController fechaNacimiento = TextEditingController();
  final TextEditingController nacionalidad    = TextEditingController();
  final TextEditingController email           = TextEditingController();
  final TextEditingController telefonoCelular = TextEditingController();
  final TextEditingController cargoFuncion    = TextEditingController();

  /// Datos del representante legal para Firestore.
  Map<String, dynamic> toFirestoreMap() => {
        'nombreApellido':  nombreApellido.text.trim(),
        'dniCuil':         dniCuil.text.trim(),
        'fechaNacimiento': fechaNacimiento.text.trim(),
        'nacionalidad':    nacionalidad.text.trim(),
        'email':           email.text.trim(),
        'telefonoCelular': telefonoCelular.text.trim(),
        'cargoFuncion':    cargoFuncion.text.trim(),
      };

  void dispose() {
    nombreApellido.dispose();
    dniCuil.dispose();
    fechaNacimiento.dispose();
    nacionalidad.dispose();
    email.dispose();
    telefonoCelular.dispose();
    cargoFuncion.dispose();
  }
}

class CredencialesFormControllers {
  final TextEditingController email           = TextEditingController();
  final TextEditingController password        = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  void dispose() {
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
  }
}

// ======================================================================
// SHARED STEP WIDGETS
// ======================================================================

// --- PASO 1: EMPRESA ---

class StepEmpresaForm extends StatelessWidget {
  final EmpresaFormControllers controllers;
  final String tipoSociedad;
  final ValueChanged<String?> onTipoSociedadChanged;

  static const _tiposSociedad = ['SA', 'SRL', 'SAS', 'Sociedad Simple', 'Otra'];

  const StepEmpresaForm({
    super.key,
    required this.controllers,
    required this.tipoSociedad,
    required this.onTipoSociedadChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RegisterSectionCard(
      title: 'Información básica',
      icon: Icons.corporate_fare,
      children: [
        RegisterField(
          label: 'Nombre de fantasía',
          controller: controllers.nombreFantasia,
          hint: 'e.g. Mi Empresa S.A.',
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'Razón social',
          controller: controllers.razonSocial,
          hint: 'Nombre legal completo',
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'CUIT',
          controller: controllers.cuit,
          hint: 'XX-XXXXXXXX-X',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        RegisterDropdownField(
          label: 'Tipo de sociedad',
          value: tipoSociedad,
          items: _tiposSociedad,
          onChanged: onTipoSociedadChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: RegisterField(
                label: 'País de constitución',
                controller: controllers.pais,
                hint: 'Argentina',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RegisterField(
                label: 'Provincia',
                controller: controllers.provincia,
                hint: 'Buenos Aires',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'Domicilio legal completo',
          controller: controllers.domicilioLegal,
          hint: 'Calle, Nro, Localidad, CP',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'Fecha de constitución',
          controller: controllers.fechaConstitucion,
          hint: 'DD/MM/AAAA',
          suffix: const Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: RegisterFormTokens.onSurfaceVariantColor,
          ),
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'Sitio web oficial',
          controller: controllers.sitioWeb,
          hint: 'https://www.empresa.com',
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'Teléfono corporativo',
          controller: controllers.telefonoCorporativo,
          hint: '+54 11 0000-0000',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'E-mail institucional',
          controller: controllers.emailInstitucional,
          hint: 'contacto@empresa.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'Dirección de correspondencia (si difiere)',
          controller: controllers.correspondencia,
          hint: 'Opcional',
          maxLines: 2,
        ),
      ],
    );
  }
}

// --- PASO 2: DOCUMENTACIÓN ---

class StepDocumentacionForm extends StatelessWidget {
  final String? estatutoFileName;
  final String? constanciaFiscalFileName;
  final String? balanceFileName;
  final VoidCallback onEstatutoTap;
  final VoidCallback onConstanciaFiscalTap;
  final VoidCallback onBalanceTap;

  const StepDocumentacionForm({
    super.key,
    this.estatutoFileName,
    this.constanciaFiscalFileName,
    this.balanceFileName,
    required this.onEstatutoTap,
    required this.onConstanciaFiscalTap,
    required this.onBalanceTap,
  });

  @override
  Widget build(BuildContext context) {
    return RegisterSectionCard(
      title: 'Documentación de respaldo',
      icon: Icons.cloud_upload_outlined,
      children: [
        RegisterUploadTile(
          icon: Icons.article_outlined,
          title: 'Estatuto o acta constitutiva',
          subtitle: 'PDF · Máx 10 MB',
          fileName: estatutoFileName,
          onTap: onEstatutoTap,
        ),
        const SizedBox(height: 12),
        RegisterUploadTile(
          icon: Icons.receipt_long_outlined,
          title: 'Constancia de inscripción fiscal',
          subtitle: 'AFIP / ARCA o equivalente',
          fileName: constanciaFiscalFileName,
          onTap: onConstanciaFiscalTap,
        ),
        const SizedBox(height: 12),
        RegisterUploadTile(
          icon: Icons.balance_outlined,
          title: 'Último balance firmado',
          subtitle: 'PDF · Máx 10 MB',
          fileName: balanceFileName,
          onTap: onBalanceTap,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: RegisterFormTokens.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: RegisterFormTokens.onSurfaceVariantColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Formatos aceptados: PDF · Máx. 10 MB por archivo',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: RegisterFormTokens.onSurfaceVariantColor.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- PASO 3: REPRESENTANTE ---

class StepRepresentanteForm extends StatelessWidget {
  final RepresentanteFormControllers controllers;
  final String? poderActaFileName;
  final String? docVinculoFileName;
  final VoidCallback onPoderActaTap;
  final VoidCallback onDocVinculoTap;

  const StepRepresentanteForm({
    super.key,
    required this.controllers,
    this.poderActaFileName,
    this.docVinculoFileName,
    required this.onPoderActaTap,
    required this.onDocVinculoTap,
  });

  @override
  Widget build(BuildContext context) {
    return RegisterSectionCard(
      title: 'Representante legal',
      icon: Icons.person_outline,
      children: [
        RegisterUploadTile(
          icon: Icons.gavel_outlined,
          title: 'Poder o acta habilitante',
          subtitle: 'Autoriza a operar en nombre de la empresa',
          fileName: poderActaFileName,
          onTap: onPoderActaTap,
        ),
        const SizedBox(height: 20),
        RegisterField(
          label: 'Nombre y apellido',
          controller: controllers.nombreApellido,
          hint: 'Juan Pérez',
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'DNI, pasaporte o CUIL',
          controller: controllers.dniCuil,
          hint: '20-12345678-3',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'Fecha de nacimiento',
          controller: controllers.fechaNacimiento,
          hint: 'DD/MM/AAAA',
          suffix: const Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: RegisterFormTokens.onSurfaceVariantColor,
          ),
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'Nacionalidad',
          controller: controllers.nacionalidad,
          hint: 'Argentina',
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'E-mail',
          controller: controllers.email,
          hint: 'representante@empresa.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'Teléfono celular',
          controller: controllers.telefonoCelular,
          hint: '+54 9 11 0000-0000',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'Cargo o función en la empresa',
          controller: controllers.cargoFuncion,
          hint: 'Director / Gerente',
        ),
        const SizedBox(height: 16),
        RegisterUploadTile(
          icon: Icons.badge_outlined,
          title: 'Documento que acredita el vínculo',
          subtitle: 'Nombramiento, poder o contrato laboral',
          fileName: docVinculoFileName,
          onTap: onDocVinculoTap,
        ),
      ],
    );
  }
}

// --- PASO 5: CREDENCIALES ---

class StepCredencialesForm extends StatelessWidget {
  final CredencialesFormControllers controllers;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final String emailHint;

  const StepCredencialesForm({
    super.key,
    required this.controllers,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    this.emailHint = 'cuenta@empresa.com',
  });

  @override
  Widget build(BuildContext context) {
    return RegisterSectionCard(
      title: 'Credenciales de la cuenta',
      icon: Icons.lock_outline,
      children: [
        RegisterField(
          label: 'E-mail de la cuenta',
          controller: controllers.email,
          hint: emailHint,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'Contraseña',
          controller: controllers.password,
          hint: 'Mínimo 8 caracteres',
          obscure: obscurePassword,
          suffix: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: RegisterFormTokens.onSurfaceVariantColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 16),
        RegisterField(
          label: 'Confirmar contraseña',
          controller: controllers.confirmPassword,
          hint: 'Repetí la contraseña',
          obscure: obscureConfirmPassword,
          suffix: IconButton(
            onPressed: onToggleConfirmPassword,
            icon: Icon(
              obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: RegisterFormTokens.onSurfaceVariantColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: RegisterFormTokens.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 16,
                color: RegisterFormTokens.onSurfaceVariantColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recomendamos al menos 8 caracteres con mayúsculas, números y un símbolo.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: RegisterFormTokens.onSurfaceVariantColor.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// REGISTER STEP + FORM
// ======================================================================

class RegisterStep {
  final String title;
  final Widget Function(BuildContext) builder;
  final String? Function()? validate;
  const RegisterStep({required this.title, required this.builder, this.validate});
}

class RegisterForm extends StatefulWidget {
  final List<RegisterStep> steps;
  final Widget? hero;
  final Widget Function(int current)? heroBuilder;
  final Widget? adminApprovalCard;
  final Future<void> Function()? onSubmit;

  const RegisterForm({
    super.key,
    required this.steps,
    this.hero,
    this.heroBuilder,
    this.adminApprovalCard,
    this.onSubmit,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  int _current = 0;
  bool _isSubmitting = false;

  void _next() {
    final error = widget.steps[_current].validate?.call();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_current < widget.steps.length - 1) {
      setState(() => _current++);
    } else {
      _handleSubmit();
    }
  }

  Future<void> _handleSubmit() async {
    if (widget.onSubmit == null) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit!();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _prev() {
    if (_current > 0) setState(() => _current--);
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_current];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.heroBuilder != null)
          widget.heroBuilder!(_current)
        else if (widget.hero != null)
          widget.hero!,
        const SizedBox(height: 20),
        _buildIndicator(),
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
            key: ValueKey(_current),
            child: step.builder(context),
          ),
        ),
        const SizedBox(height: 24),
        if (_current == widget.steps.length - 1 &&
            widget.adminApprovalCard != null) ...[
          widget.adminApprovalCard!,
          const SizedBox(height: 24),
        ],
        _buildActions(),
      ],
    );
  }

  Widget _buildIndicator() {
    return Row(
      children: List.generate(widget.steps.length, (i) {
        final active = i <= _current;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: active
                        ? RegisterFormTokens.cyanColor
                        : RegisterFormTokens.outlineVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < widget.steps.length - 1) const SizedBox(width: 6),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActions() {
    final isLast = _current == widget.steps.length - 1;
    return Row(
      children: [
        if (_current > 0) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _prev,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: RegisterFormTokens.outlineVariant.withValues(alpha: 0.6),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Atrás',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: RegisterFormTokens.onSurfaceColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: RegisterFormTokens.primaryColor,
              foregroundColor: RegisterFormTokens.onPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: RegisterFormTokens.onPrimaryColor,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? 'Enviar registro' : 'Continuar',
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
    );
  }
}
