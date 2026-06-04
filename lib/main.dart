import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:water_ledger/core/config/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Inicializa los datos de formato de fechas en español. Necesario porque
  // varias pantallas usan DateFormat con locale 'es' (admin dashboard,
  // detalle de solicitud pendiente).
  await initializeDateFormatting('es');
  runApp(
    const ProviderScope(child: MainApp())
  );
}

// ConsumerWidget (en vez de StatelessWidget) para poder leer appRouterProvider,
// cuyo redirect consulta sessionProvider y reacciona a cambios de auth de Firebase.
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
