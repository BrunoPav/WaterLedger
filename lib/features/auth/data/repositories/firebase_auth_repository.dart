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
      return _fetchUserModel(credential.user!.uid);
    });
  }

  @override
  Future<UserModel> registerRetail({
    required String email,
    required String password,
    required String fullName,
    required String dni,
    // Datos adicionales del inversor retail: antes el form los pedía pero no se
    // guardaban. Ahora llegan hasta acá y se persisten en retailData.
    String phone = '',
    String country = '',
    List<String> interests = const [],
    String riskProfile = '',
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
        'retailData': {
          'fullName': fullName,
          'dni': dni,
          'phone': phone,
          'country': country,
          'interests': interests,
          'riskProfile': riskProfile,
        },
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
    // Datos adicionales del onboarding corporativo: antes el form los pedía pero
    // no se guardaban. Ahora llegan hasta acá y se persisten en companyData.
    String legalName = '',
    String industry = '',
    String country = '',
    String phone = '',
    String address = '',
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
        'companyData': {
          'companyName': companyName,
          'cuit': cuit,
          'legalName': legalName,
          'industry': industry,
          'country': country,
          'phone': phone,
          'address': address,
        },
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
    // Versión anterior con polling 3 × 400ms — comentada porque tenía un race
    // condition durante el registro: createUserWithEmailAndPassword dispara
    // authStateChanges INMEDIATAMENTE, antes de que el set() del doc termine.
    // Si Firestore tardaba más de ~1.2s en escribir, _fetchUserModel tiraba
    // AuthException y dejaba al sessionProvider en error state. El usuario
    // quedaba logueado en Firebase Auth pero sin UserModel, y el router lo
    // pateaba a /login en loop.
    //
    // const maxAttempts = 3;
    // for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    //   try {
    //     final doc = await _db
    //         .collection('users')
    //         .doc(uid)
    //         .get()
    //         .timeout(const Duration(seconds: 5));
    //     if (doc.exists) {
    //       return UserModel.fromFirestore(doc.data()!, uid);
    //     }
    //   } on Exception catch (e) {
    //     if (attempt == maxAttempts) {
    //       throw AuthException(
    //         'No se pudo leer tu perfil. Revisá tu conexión y reintentá. ($e)',
    //         code: 'user-doc-fetch-failed',
    //       );
    //     }
    //   }
    //   if (attempt < maxAttempts) {
    //     await Future.delayed(const Duration(milliseconds: 400));
    //   }
    // }
    // throw AuthException(
    //   'No se encontró el perfil del usuario. Si te acabás de registrar, esperá unos segundos y reintentá.',
    //   code: 'user-doc-missing',
    // );

    // Versión nueva: escuchamos snapshots() en vivo y resolvemos en cuanto el
    // doc aparece. Esto sirve tanto si el doc ya existe (snapshot inicial) como
    // si está por escribirse en paralelo (snapshot subsecuente). Timeout de 10s
    // para no colgarse forever si nunca se materializa el doc (red caída, reglas
    // bloqueando, etc.).
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
