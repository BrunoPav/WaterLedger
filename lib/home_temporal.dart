import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/credit_request_notifier.dart';

class HomeTemporal extends ConsumerWidget {
  const HomeTemporal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Temporal')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Contenido para probar pantallas'),
            ElevatedButton(
              onPressed: () {
                context.push('/auditor');
              },
              child: Text('Ir a Auditor'),
            ),
            ElevatedButton(
              onPressed: () {
                context.push('/issuing-company');
              },
              child: Text('Ir a Empresa Emisora'),
            ),            
            ElevatedButton(
              onPressed: () async {
                // Crea un borrador con un companyId mockeado y navega al editor de roadmap
                await ref
                    .read(creditRequestProvider.notifier)
                    .createDraft('mock_company_id');
                if (!context.mounted) return;
                context.push('/roadmap-editor');
              },
              child: Text('Ir a Roadmap Editor (Paso 4)'),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/project-info-test');
              },
              child: const Text('Ir a Project Info'),
            ),
          ],
        ),
      ),
    );
  }
}
