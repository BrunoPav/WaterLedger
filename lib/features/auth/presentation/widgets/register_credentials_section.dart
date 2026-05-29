import 'package:flutter/material.dart';

class RegisterCredentialsSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  const RegisterCredentialsSection({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  }) : super(key: key);

  Widget _buildField({ // es un helper para no repetir código, no es un widget reutilizable
    required String label,
    required TextEditingController controller,
    String? hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(
          label: 'E-mail de la cuenta',
          controller: emailController,
          hint: 'admin@empresa.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'Contraseña',
          controller: passwordController,
          hint: 'Mínimo 8 caracteres',
          obscure: obscurePassword,
          suffix: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          ),
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'Confirmar contraseña',
          controller: confirmPasswordController,
          hint: 'Repetí la contraseña',
          obscure: obscureConfirmPassword,
          suffix: IconButton(
            onPressed: onToggleConfirmPassword,
            icon: Icon(obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recomendamos minimo 8 caracteres con al menos una mayúscula, números y un símbolo.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
