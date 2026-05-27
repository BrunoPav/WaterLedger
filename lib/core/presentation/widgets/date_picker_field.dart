import 'package:flutter/material.dart';

/// Campo de fecha read-only que abre un `showDatePicker` al tocarlo
/// y escribe el valor formateado como DD/MM/AAAA al `TextEditingController`.
///
/// Pensado para reemplazar los inputs de fecha de texto libre en los formularios
/// de registro (auditor, certifier, insurance). El resto del código sigue leyendo
/// `controller.text` igual que antes — el widget mantiene el contrato basado en
/// strings para no romper integraciones con Firestore que esperan ese formato.
class DatePickerField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final DateTime? firstDate;
  final DateTime? lastDate;

  // Tokens de diseño replicados del resto de los formularios para mantener
  // consistencia visual con los `_buildField` locales de cada screen.
  static const _onSurfaceColor = Color(0xFF191C1E);
  static const _onSurfaceVariantColor = Color(0xFF44474D);
  static const _surfaceContainerLowColor = Color(0xFFF2F4F6);
  static const _secondaryColor = Color(0xFF006875);

  const DatePickerField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = 'DD/MM/AAAA',
    this.firstDate,
    this.lastDate,
  });

  Future<void> _pickDate(BuildContext context) async {
    // Si el controller ya tenía una fecha (DD/MM/AAAA), arranca con ese valor.
    final parsed = _tryParseDdMmYyyy(controller.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: parsed ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _secondaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.text = _formatDdMmYyyy(picked);
    }
  }

  String _formatDdMmYyyy(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  DateTime? _tryParseDdMmYyyy(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        // El TextField es readOnly + onTap dispara el picker — así obtenemos
        // el look idéntico a los demás campos sin tener que recrear el styling.
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _pickDate(context),
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
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: _onSurfaceVariantColor,
            ),
            filled: true,
            fillColor: _surfaceContainerLowColor,
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
              borderSide: const BorderSide(color: Color(0xFF00E3FD), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
