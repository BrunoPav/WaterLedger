import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:water_ledger/core/domain/entities/user_model.dart';
import 'package:water_ledger/core/domain/enums/user_permission.dart';
import 'package:water_ledger/core/domain/enums/user_role.dart';
import 'package:water_ledger/core/domain/enums/user_status.dart';
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
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fetchUserModel(credential.user!.uid);
  }

  @override
  Future<UserModel> registerRetail({
    required String email,
    required String password,
    required String fullName,
    required String dni,
  }) async {
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
  }

  @override
  Future<UserModel> registerCompany({
    required String email,
    required String password,
    required String companyName,
    required String cuit,
  }) async {
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
  }

  @override
  Future<UserModel> registerAuditor({
    required String email,
    required String password,
    required String auditorType,
    required Map<String, dynamic> companyData,
    required Map<String, dynamic> representativeData,
    required Map<String, dynamic> auditorRoleData,
  }) async {
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
  }

  @override
  Future<UserModel> registerCertifier({
    required String email,
    required String password,
    required Map<String, dynamic> companyData,
    required Map<String, dynamic> representativeData,
    required Map<String, dynamic> certifierRoleData,
  }) async {
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
  }

  @override
  Future<UserModel> registerInsurer({
    required String email,
    required String password,
    required Map<String, dynamic> companyData,
    required Map<String, dynamic> representativeData,
    required Map<String, dynamic> insurerRoleData,
  }) async {
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
  }

  @override
  Future<UserModel> registerAdmin({
    required String email,
    required String password,
    required String displayName,
  }) async {
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

  Future<UserModel> _fetchUserModel(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('Usuario no encontrado: $uid');
    return UserModel.fromFirestore(doc.data()!, uid);
  }
}
