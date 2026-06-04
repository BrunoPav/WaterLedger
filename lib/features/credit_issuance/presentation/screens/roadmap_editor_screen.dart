import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/roadmap_entity.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/credit_request_notifier.dart';
import 'package:water_ledger/features/credit_issuance/presentation/widgets/roadmap_editor_step.dart';

class RoadmapEditorScreen extends ConsumerWidget {
  const RoadmapEditorScreen({super.key});

  static const _bgColor = Color(0xFFF7F9FB);
  static const _outlineVariantColor = Color(0xFFC5C6CD);
  static const _onSurfaceVariantColor = Color(0xFF44474D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: RoadmapEditorStep(
              onBack: () => context.pop(),
              onSaved: (RoadmapEntity roadmap) async {
                await ref.read(creditRequestProvider.notifier).updateRoadmap(roadmap);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Roadmap guardado correctamente ✓'),
                    backgroundColor: Color(0xFF006875),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              onSubmit: () async {
                await ref.read(creditRequestProvider.notifier).submitRequest();
                if (!context.mounted) return;
                context.push('/submission-confirmation');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: _bgColor.withValues(alpha: 0.7),
            border: Border(bottom: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.1))),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: _onSurfaceVariantColor, size: 22),
                    ),
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.water_drop, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Water Ledger',
                      style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: -0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
