import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_ledger/features/shared/domain/enums/user_permission.dart';
import 'package:water_ledger/features/shared/domain/enums/user_role.dart';
import 'package:water_ledger/features/shared/domain/enums/user_status.dart';
import 'package:water_ledger/features/shared/domain/enums/user_type.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final UserStatus status;
  final List<UserPermission> permissions;
  final DateTime createdAt;
  final String? auditorType; // 'financial' | 'environmental' | 'accounting'

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    required this.permissions,
    required this.createdAt,
    this.auditorType,
  });

  bool get canBuy    => permissions.contains(UserPermission.buyer);
  bool get canIssue  => permissions.contains(UserPermission.issuer);
  bool get canAudit  => permissions.contains(UserPermission.auditor)   && status == UserStatus.active;
  bool get canCertify => permissions.contains(UserPermission.certifier) && status == UserStatus.active;
  bool get canInsure => permissions.contains(UserPermission.insurer)   && status == UserStatus.active;
  bool get isAdmin   => role == UserRole.admin && status == UserStatus.active;
  bool get isActive  => status == UserStatus.active;
  bool get isPending => status == UserStatus.pending;

  /// 4.1.4.1 — distinción Persona vs Empresa derivada del rol.
  /// Solo `retail` es persona física, el resto opera como empresa.
  UserType get userType => role == UserRole.retail ? UserType.person : UserType.company;

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] as String,
      displayName: data['displayName'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String),
      status: UserStatus.fromString(data['status'] as String),
      permissions: (data['permissions'] as List<dynamic>)
          .map((p) => UserPermission.fromString(p as String))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      auditorType: data['auditorType'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role.value,
      'status': status.value,
      'permissions': permissions.map((p) => p.value).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      if (auditorType != null) 'auditorType': auditorType,
    };
  }
}
