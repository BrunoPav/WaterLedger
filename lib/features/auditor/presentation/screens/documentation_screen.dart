import 'package:flutter/material.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Documentación Requerida')),
      body: Center(
        child: Text('Que documentacion debo presentar para emitir bonos?'),        
      ),
    );
  }
}