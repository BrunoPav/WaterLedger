import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeTemporal extends StatelessWidget {
  const HomeTemporal({super.key});

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {
                  context.push('/prueba-credito');
                },
                child: Text('Ir a Prueba de Crédito'),
              ),  
              
          ],
        ),
      ),
    );
  }
}