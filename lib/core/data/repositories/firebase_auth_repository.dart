import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:water_ledger/core/domain/entities/user_model.dart';
import 'package:water_ledger/core/domain/enums/user_permission.dart';
import 'package:water_ledger/core/domain/enums/user_role.dart';
import 'package:water_ledger/core/domain/enums/user_status.dart';
import 'package:water_ledger/core/domain/exceptions/auth_exception.dart';
import 'package:water_ledger/core/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _fetchUserModel(user.uid);
    });
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) {
    return _run(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fetchUserModel(credential.user!.uid);
    });
  }

  @override
  Future<UserModel> registerRetail({
    required String email,
    required String password,
    required String fullName,
    required String dni,
  }) {
    return _run(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final user = UserModel(
        uid: uid,
        email: email,
        displayName: fullName,
        role: UserRole.retail,
        status: UserStatus.active,
        permissions: [UserPermission.buyer],
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(uid).set({
        ...user.toFirestore(),
        'retailData': {'fullName': fullName, 'dni': dni},
      });
      return user;
    });
  }

  @override
  Future<UserModel> registerCompany({
    required String email,
    required String password,
    required String companyName,
    required String cuit,
  }) {
    return _run(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final user = UserModel(
        uid: uid,
        email: email,
        displayName: companyName,
        role: UserRole.company,
        status: UserStatus.active,
        permissions: [UserPermission.buyer],
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(uid).set({
        ...user.toFirestore(),
        'companyData': {'companyName': companyName, 'cuit': cuit},
      });
      return user;
    });
  }

  @override
  Future<UserModel> registerAuditor({
    required String email,
    required String password,
    required String auditorType,
    required Map<String, dynamic> companyData,
    required Map<String, dynamic> representativeData,
    required Map<String, dynamic> auditorRoleData,
  }) {
    return _run(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final user = UserModel(
        uid: uid,
        email: email,
        displayName: companyData['fantasyName'] as String? ?? '',
        role: UserRole.auditor,
        status: UserStatus.pending,
        permissions: [UserPermission.auditor],
        createdAt: DateTime.now(),
        auditorType: auditorType,
      );
      await _db.collection('users').doc(uid).set({
        ...user.toFirestore(),
        'companyData': companyData,
        'representativeData': representativeData,
        'auditorRoleData': auditorRoleData,
      });
      return user;
    });
  }

  @override
  Future<UserModel> registerCertifier({
    required String email,
    required String password,
    required Map<String, dynamic> companyData,
    required Map<String, dynamic> representativeData,
    required Map<String, dynamic> certifierRoleData,
  }) {
    return _run(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final user = UserModel(
        uid: uid,
        email: email,
        displayName: companyData['fantasyName'] as String? ?? '',
        role: UserRole.certifier,
        status: UserStatus.pending,
        permissions: [UserPermission.certifier],
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(uid).set({
        ...user.toFirestore(),
        'companyData': companyData,
        'representativeData': representativeData,
        'certifierRoleData': certifierRoleData,
      });
      return user;
    });
  }

  @override
  Future<UserModel> registerInsurer({
    required String email,
    required String password,
    required Map<String, dynamic> companyData,
    required Map<String, dynamic> representativeData,
    required Map<String, dynamic> insurerRoleData,
  }) {
    return _run(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final user = UserModel(
        uid: uid,
        email: email,
        displayName: companyData['fantasyName'] as String? ?? '',
        role: UserRole.insurer,
        status: UserStatus.pending,
        permissions: [UserPermission.insurer],
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(uid).set({
        ...user.toFirestore(),
        'companyData': companyData,
        'representativeData': representativeData,
        'insurerRoleData': insurerRoleData,
      });
      return user;
    });
  }

  @override
  Future<UserModel> registerAdmin({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _run(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final user = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        role: UserRole.admin,
        status: UserStatus.active,
        permissions: [UserPermission.admin],
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(uid).set(user.toFirestore());
      return user;
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _fetchUserModel(user.uid);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _run(() => _auth.sendPasswordResetEmail(email: email));
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> updates,
  }) async {
    // Si el caller incluye `displayName`, también lo sincronizamos con
    // FirebaseAuth para mantener consistencia entre auth.currentUser y Firestore.
    final newDisplayName = updates['displayName'];
    if (newDisplayName is String && _auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(newDisplayName);
    }
    await _db.collection('users').doc(uid).update(updates);
  }

  Future<UserModel> _fetchUserModel(String uid) async {
    // Retry con backoff: cuando el user se acaba de registrar, FirebaseAuth
    // emite el authStateChanges antes de que Firestore termine de escribir el doc.
    // Sin reintento, _fetchUserModel falla y deja al user "colgado" sin sesión usable.
    // 3 intentos × 400ms = hasta ~1.2s de tolerancia, suficiente para el race típico.
    // Además cada get() tiene su propio timeout de 5s para no colgarse forever
    // si Firestore queda esperando (red caída, reglas bloqueando, etc.).
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final doc = await _db
            .collection('users')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 5));
        if (doc.exists) {
          return UserModel.fromFirestore(doc.data()!, uid);
        }
      } on Exception catch (e) {
        // Si fue timeout o un error transitorio, dejamos que el retry lo intente.
        // En el último intento sí relanzamos como AuthException.
        if (attempt == maxAttempts) {
          throw AuthException(
            'No se pudo leer tu perfil. Revisá tu conexión y reintentá. ($e)',
            code: 'user-doc-fetch-failed',
          );
        }
      }
      if (attempt < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }
    throw AuthException(
      'No se encontró el perfil del usuario. Si te acabás de registrar, esperá unos segundos y reintentá.',
      code: 'user-doc-missing',
    );
  }

  /// Helper que envuelve cualquier operación de FirebaseAuth y traduce
  /// `FirebaseAuthException` a `AuthException` con mensaje user-friendly.
  /// Cualquier otro error se relanza tal cual.
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseAuthException(e);
    }
  }
}
