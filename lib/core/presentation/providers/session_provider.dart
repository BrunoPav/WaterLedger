import 'package:flutter_riverpod/flutter_riverpod.dart';

class Session {
  final String? companyId;
  final bool isCompany;

  const Session({this.companyId, this.isCompany = false});
}

// Provider para simular sesion de empresa autenticada, siempre da true. 
// En una implementación real, esto debería integrarse con el sistema de autenticación real.
final sessionProvider = Provider<Session>((ref) {
  //aca iria la logica de la validacion
  return const Session(companyId: 'mock_company_id', isCompany: true);
});
