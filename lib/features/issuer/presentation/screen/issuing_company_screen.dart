import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/credit_request_notifier.dart';

class IssuingCompanyScreen extends ConsumerWidget {
  const IssuingCompanyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empresa Emisora')),
      body: _DocumentsView(),
    );
  }
}

class _DocumentsView extends ConsumerWidget {
  const _DocumentsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Wrap(
          spacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/documentation'),
              child: const Text('Subir Documento'),
            ),
            ElevatedButton.icon(
              onPressed: () => context.push('/credit-issuance'),
              icon: const Icon(Icons.insert_drive_file),
              label: const Text('Ver Solicitud'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final session = ref.read(sessionProvider);
                if (!session.isCompany || session.companyId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Acceso denegado: no hay empresa autenticada')),
                  );
                  return;// aca se puede redireccionar a una pantalla home o de login
                }

                // Crear borrador para la empresa autenticada
                try {
                  await ref.read(creditRequestProvider.notifier).createDraft(session.companyId!);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creando borrador: $e')),
                  );
                  return;
                }

                if (!context.mounted) return;
                context.push('/roadmap-editor');
              },
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Nueva Solicitud'),
            ),
          ],
        ),
      ),
    );
  }
}
