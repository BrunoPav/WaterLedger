import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuditorScreen extends StatelessWidget {
  const AuditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Auditor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contenido de la pantalla de auditor'),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/credit-issuance'),
              icon: Icon(Icons.insert_drive_file),
              label: Text('Ver Solicitud'),
            ),
          ],
        ),
      ),
    );
  }
}