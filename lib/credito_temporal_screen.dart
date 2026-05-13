import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/credit_request_notifier.dart';

class CreditoTemporal extends ConsumerWidget {
  const CreditoTemporal({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Credito Temporal')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Contenido para probar funciones'),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(creditRequestProvider.notifier).createDraft('manuel');
              },
              child: Text('Crear borrador'),
            ),
            ElevatedButton(
              onPressed: () { 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BorradorScreen()),
                );
              },
              child: Text('ver borrador creado'),
            ),
          ],
        ),
      ),
    );
  }
}

class BorradorScreen extends ConsumerWidget {
  const BorradorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Borrador')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ID Solicitud: ${ref.watch(creditRequestProvider).id}'),
            Text('Estado: ${ref.watch(creditRequestProvider).status.name}'),
            Text('Empresa: ${ref.watch(creditRequestProvider).issuerCompanyId}')
          ],
        ),
      ),
    );
  }
}
