import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:water_ledger/features/shared/domain/entities/user_model.dart';
import 'package:water_ledger/features/shared/domain/enums/user_permission.dart';
import 'package:water_ledger/features/shared/domain/enums/user_role.dart';
import 'package:water_ledger/features/shared/domain/enums/user_status.dart';
import 'package:water_ledger/features/auth/domain/exceptions/auth_exception.dart';
import 'package:water_ledger/features/auth/domain/repositories/auth_repository.dart';

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
      return _fetchUserModelForLogin(credential.user!.uid);
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
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .snapshots()
          .firstWhere((s) => s.exists)
          .timeout(const Duration(seconds: 10));
      return UserModel.fromFirestore(snap.data()!, uid);
    } on TimeoutException {
      throw AuthException(
        'No se encontró el perfil del usuario después de 10 segundos. Reintentá iniciando sesión.',
        code: 'user-doc-missing',
      );
    } on Exception catch (e) {
      throw AuthException(
        'No se pudo leer tu perfil. Revisá tu conexión y reintentá. ($e)',
        code: 'user-doc-fetch-failed',
      );
    }
  }

  /// Para el flujo de login: hace un get() directo sin esperar. Si el doc no
  /// existe, cierra la sesión de Auth y falla inmediatamente.
  Future<UserModel> _fetchUserModelForLogin(String uid) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));
      if (!doc.exists) {
        await _auth.signOut();
        throw AuthException(
          'No se encontró un perfil asociado a esta cuenta.',
          code: 'user-doc-missing',
        );
      }
      return UserModel.fromFirestore(doc.data()!, uid);
    } on TimeoutException {
      await _auth.signOut();
      throw AuthException(
        'No se pudo conectar con el servidor. Revisá tu conexión y reintentá.',
        code: 'user-doc-fetch-timeout',
      );
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthException(
        'No se pudo leer tu perfil. Revisá tu conexión y reintentá. ($e)',
        code: 'user-doc-fetch-failed',
      );
    }
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
