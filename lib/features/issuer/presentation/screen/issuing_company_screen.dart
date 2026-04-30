import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IssuingCompanyScreen extends StatelessWidget {
  const IssuingCompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Empresa Emisora')),
      body: _DocumentsView(),
    );
  }
}

class _DocumentsView extends StatelessWidget {
  const _DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Wrap(
          children: [
            ElevatedButton(
              onPressed: () => context.push('/documentation'),
              child: Text('Subir Documento'),
            ),
              ElevatedButton.icon(
                  onPressed: () => context.push('/credit-issuance'),
                  icon: const Icon(Icons.insert_drive_file),
                  label: const Text('Ver Solicitud')),
          ],
        ),
      ),
    );
  }
}
