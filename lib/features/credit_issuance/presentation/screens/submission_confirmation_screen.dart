import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/credit_request_notifier.dart';

class SubmissionConfirmationScreen extends ConsumerWidget {
  const SubmissionConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(creditRequestProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Ícono de éxito animado
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E3FD).withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 70,
                  color: Color(0xFF00DAF3),
                ),
              ),
              const SizedBox(height: 32),

              // Título
              const Text(
                'Solicitud Enviada\nExitosamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Subtítulo
              const Text(
                'Tu solicitud de emisión de crédito ha sido registrada en el sistema.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: Color(0xFF44474D),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFC5C6CD).withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      label: 'ID de Solicitud',
                      value: request.id,
                      isCopyable: true,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      label: 'Estado',
                      value: request.status.name.toUpperCase(),
                      valueColor: const Color(0xFF006875),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      label: 'Fecha de Envío',
                      value: _formatDate(request.updatedAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/request-tracking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ir al Seguimiento',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón secundario: Ir al Dashboard
              TextButton(
                onPressed: () => context.go('/splash'),
                child: const Text(
                  'Volver al Dashboard',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF006875),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color valueColor = const Color(0xFF000000),
    bool isCopyable = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF44474D),
            letterSpacing: 0.3,
          ),
        ),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  onPressed: () {
                    // para implementar la función de copiar al portapapeles
                  },
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'No disponible';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
