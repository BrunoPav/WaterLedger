import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/credit_request_notifier.dart';

class HomeTemporal extends ConsumerWidget {
  const HomeTemporal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Temporal')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Contenido para probar pantallas'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.push('/auditor');
                },
                child: const Text('Ir a Auditor'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.push('/issuing-company');
                },
                child: const Text('Ir a Empresa Emisora'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(creditRequestProvider.notifier)
                      .createDraft('mock_company_id');

                  if (!context.mounted) return;

                  context.push('/roadmap-editor');
                },
                child: const Text('Ir a Roadmap Editor (Paso 4)'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.go('/project-info-test');
                },
                child: const Text('Ir a Project Info'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.go('/project-objectives-test');
                },
                child: const Text('Ir a Project Objectives'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}