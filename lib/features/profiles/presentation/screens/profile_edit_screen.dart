import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/core/domain/entities/user_model.dart';
import 'package:water_ledger/core/domain/enums/user_role.dart';
import 'package:water_ledger/core/domain/enums/user_status.dart';
import 'package:water_ledger/core/domain/exceptions/auth_exception.dart';
import 'package:water_ledger/core/domain/validators/auth_validators.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_top_bar.dart';

/// Pantalla única de edición de perfil. Se adapta según el `UserRole` del
/// usuario logueado: cambia el label del badge y los campos visibles.
///
/// Los campos sensibles (email, CUIT, datos de la empresa cargados en
/// onboarding) se muestran en modo display-only — esos cambios requieren
/// proceso de soporte (re-verificación de identidad).
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _displayNameController = TextEditingController();
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _hydrateFromUser(UserModel user) {
    if (_initialized) return;
    _displayNameController.text = user.displayName;
    _initialized = true;
  }

  Future<void> _save(UserModel user) async {
    final newName = _displayNameController.text.trim();

    // Validación cliente
    final error = AuthValidators.required(newName, 'el nombre');
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    // No-op si nada cambió
    if (newName == user.displayName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para guardar')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(authRepositoryProvider).updateProfile(
        uid: user.uid,
        updates: {'displayName': newName},
      );
      if (!mounted) return;
      // Re-fetchar el UserModel para que las pantallas que watchean
      // sessionProvider vean el nuevo displayName.
      ref.invalidate(sessionProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado ✓'),
          backgroundColor: DashboardTokens.secondaryColor,
          duration: Duration(seconds: 2),
        ),
      );
      context.pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      appBar: DashboardTopBar(
        leading: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back,
                color: DashboardTokens.onSurfaceVariantColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 4),
            const TopBarTitled(title: 'Edit Profile'),
          ],
        ),
      ),
      body: sessionAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: DashboardTokens.secondaryColor,
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Error cargando perfil: $e',
              style: const TextStyle(color: DashboardTokens.errorColor),
            ),
          ),
        ),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          _hydrateFromUser(user);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarHeader(user),
                const SizedBox(height: 28),
                const _Label('EDITABLE'),
                const SizedBox(height: 8),
                _buildEditableCard(),
                const SizedBox(height: 24),
                const _Label('READ-ONLY'),
                const SizedBox(height: 8),
                _buildReadOnlyCard(user),
                const SizedBox(height: 12),
                _buildSensitiveDataNotice(user),
                const SizedBox(height: 28),
                _buildSaveButton(user),
              ],
            ),
          );
        },
      ),
    );
  }

  // ----- Header con avatar + nombre actual (vista previa)
  Widget _buildAvatarHeader(UserModel user) {
    final initial = user.displayName.trim().isEmpty
        ? '·'
        : user.displayName.trim()[0].toUpperCase();
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DashboardTokens.cyanColor.withValues(alpha: 0.12),
            border: Border.all(
              color: DashboardTokens.cyanColor.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: DashboardTokens.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _roleLabel(user.role),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DashboardTokens.onSurfaceVariantColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ----- Card con los campos editables (por ahora: displayName)
  Widget _buildEditableCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel('Display name'),
              const SizedBox(height: 6),
              _editableField(
                controller: _displayNameController,
                hint: 'Cómo verá tu nombre el resto de la plataforma',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----- Card con datos de solo lectura del UserModel
  Widget _buildReadOnlyCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          _readonlyRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          const Divider(
            height: 22,
            color: DashboardTokens.outlineVariantColor,
          ),
          _readonlyRow(
            icon: Icons.badge_outlined,
            label: 'Account role',
            value: _roleLabel(user.role),
          ),
          const Divider(
            height: 22,
            color: DashboardTokens.outlineVariantColor,
          ),
          _readonlyRow(
            icon: Icons.verified_outlined,
            label: 'Account status',
            value: _statusLabel(user.status, isAdmin: user.role == UserRole.admin),
          ),
          const Divider(
            height: 22,
            color: DashboardTokens.outlineVariantColor,
          ),
          _readonlyRow(
            icon: Icons.event_outlined,
            label: 'Member since',
            value: DateFormat('MMM y').format(user.createdAt),
          ),
        ],
      ),
    );
  }

  // ----- Aviso de qué datos no se pueden editar acá
  Widget _buildSensitiveDataNotice(UserModel user) {
    final hasCompanyData = user.role != UserRole.retail && user.role != UserRole.admin;
    final extra = hasCompanyData
        ? ' Los datos de la empresa, representante legal y habilitación profesional cargados en el registro tampoco pueden modificarse desde acá.'
        : '';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceContainerLowColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: DashboardTokens.onSurfaceVariantColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'El email no se cambia desde la app (Firebase Auth lo bloquea por seguridad — contactá soporte si necesitás otro).$extra',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: DashboardTokens.onSurfaceVariantColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- Botón Save sticky abajo
  Widget _buildSaveButton(UserModel user) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : () => _save(user),
        style: ElevatedButton.styleFrom(
          backgroundColor: DashboardTokens.primaryColor,
          foregroundColor: DashboardTokens.onPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save changes',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // ----- Helpers de UI
  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.8),
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _editableField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        color: DashboardTokens.onSurfaceColor,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.4),
          fontSize: 14,
        ),
        filled: true,
        fillColor: DashboardTokens.surfaceContainerLowColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DashboardTokens.cyanColor, width: 2),
        ),
      ),
    );
  }

  Widget _readonlyRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: DashboardTokens.surfaceContainerColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: DashboardTokens.onSurfaceVariantColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: DashboardTokens.onSurfaceVariantColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DashboardTokens.onSurfaceColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _roleLabel(UserRole role) {
    return switch (role) {
      UserRole.retail => 'Retail Investor',
      UserRole.company => 'Registered Company',
      UserRole.auditor => 'Certified Auditor',
      UserRole.certifier => 'Certification Entity',
      UserRole.insurer => 'Insurance Provider',
      UserRole.admin => 'System Administrator',
    };
  }

  String _statusLabel(UserStatus status, {bool isAdmin = false}) {
    if (isAdmin) return 'Superuser';
    return switch (status) {
      UserStatus.active => 'Active',
      UserStatus.pending => 'Pending approval',
      UserStatus.rejected => 'Rejected',
    };
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: DashboardTokens.onSurfaceVariantColor,
        letterSpacing: 1.0,
      ),
    );
  }
}
