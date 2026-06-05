import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:water_ledger/features/shared/domain/entities/user_model.dart';
import 'package:water_ledger/features/auth/domain/repositories/auth_repository.dart';

// class Session { ... } — reemplazada por UserModel en core/domain/entities/user_model.dart
// final sessionProvider = Provider<Session> — reemplazado por StreamProvider<UserModel?> con Firebase real

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final sessionProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
