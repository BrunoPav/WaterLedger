import 'dart:async';
import 'package:flutter/foundation.dart';

/// Adapter que convierte un Stream en un ChangeNotifier consumible
/// por `GoRouter.refreshListenable`.
///
/// Cada vez que el stream emite, se notifica al router para que re-evalúe
/// la lógica de `redirect`. Esto hace que el guard reaccione automáticamente
/// a logins/logouts sin necesidad de empujar manualmente la navegación.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Notificar el estado inicial para que el primer redirect se evalúe
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
