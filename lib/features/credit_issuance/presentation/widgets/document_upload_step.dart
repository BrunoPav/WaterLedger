import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/document_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/document_type.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/credit_request_notifier.dart';

// ── Design tokens (shared with wizard) ────────────────────────────────────────
const _bgColor               = Color(0xFFF7F9FB);
const _primaryColor          = Color(0xFF000000);
const _secondaryColor        = Color(0xFF006875);
const _cyanColor             = Color(0xFF00E3FD);
const _onSurfaceColor        = Color(0xFF191C1E);
const _onSurfaceVariantColor = Color(0xFF44474D);
const _surfaceHighColor      = Color(0xFFE6E8EA);
const _outlineVariantColor   = Color(0xFFC5C6CD);

const _docMeta = {
  DocumentType.technical:    (label: 'Documentación Técnica',    icon: Icons.engineering_outlined,      hint: 'Memorias descriptivas, planos, especificaciones'),
  DocumentType.environmental:(label: 'Documentación Ambiental',  icon: Icons.eco_outlined,              hint: 'Estudios de impacto ambiental, informes de campo'),
  DocumentType.legal:        (label: 'Documentación Legal',      icon: Icons.gavel_outlined,            hint: 'Habilitaciones, permisos, contratos relevantes'),
  DocumentType.financial:    (label: 'Documentación Financiera', icon: Icons.account_balance_outlined,  hint: 'Estados contables, presupuesto detallado'),
};

class _DocState {
  String? fileName;
  String? storageUrl;
  double uploadProgress = 0;
  bool uploading = false;
  String? error;
  bool get uploaded => storageUrl != null;
}

/// Paso 4 del wizard: selección y upload de documentos a Firebase Storage.
/// Los 4 tipos son opcionales — el usuario puede continuar sin subir ninguno.
class DocumentUploadStep extends ConsumerStatefulWidget {
  const DocumentUploadStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  ConsumerState<DocumentUploadStep> createState() => _DocumentUploadStepState();
}

class _DocumentUploadStepState extends ConsumerState<DocumentUploadStep> {
  final Map<DocumentType, _DocState> _docs = {
    for (final t in DocumentType.values) t: _DocState(),
  };
  bool _isSaving = false;

  Future<void> _pickAndUpload(DocumentType type) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;

    // Validar que el wizard ya creó el draft (requestId no vacío)
    final requestId = ref.read(creditRequestProvider).id;
    if (requestId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: la solicitud no fue iniciada. Volvé al paso 1.')),
      );
      return;
    }

    setState(() {
      _docs[type]!.uploading = true;
      _docs[type]!.uploadProgress = 0;
      _docs[type]!.error = null;
      _docs[type]!.fileName = picked.name;
    });

    UploadTask? task;
    try {
      final mime = _mimeType(picked.name);
      final storageRef = FirebaseStorage.instance
          .ref('creditRequests/$requestId/documents/${type.name}/${picked.name}');

      if (picked.bytes != null) {
        task = storageRef.putData(picked.bytes!, SettableMetadata(contentType: mime));
      } else if (picked.path != null) {
        task = storageRef.putFile(io.File(picked.path!), SettableMetadata(contentType: mime));
      } else {
        throw Exception('No se pudo acceder al archivo seleccionado.');
      }

      // Escuchar progreso con cancelación en error
      final sub = task.snapshotEvents.listen(
        (snap) {
          if (!mounted) return;
          final total = snap.totalBytes == 0 ? 1 : snap.totalBytes;
          setState(() => _docs[type]!.uploadProgress = snap.bytesTransferred / total);
        },
        onError: (_) {},  // el error se captura en el await task de abajo
        cancelOnError: true,
      );

      final snapshot = await task;
      await sub.cancel();
      final url = await snapshot.ref.getDownloadURL();

      if (!mounted) return;
      setState(() {
        _docs[type]!.storageUrl = url;
        _docs[type]!.uploading = false;
        _docs[type]!.uploadProgress = 1;
      });
    } on FirebaseException catch (e) {
      task?.cancel();
      if (!mounted) return;
      final msg = e.code == 'unauthorized'
          ? 'Sin permisos de Storage. Desplegá storage.rules en Firebase.'
          : 'Firebase Storage error [${e.code}]: ${e.message}';
      setState(() {
        _docs[type]!.uploading = false;
        _docs[type]!.error = msg;
      });
    } catch (e) {
      task?.cancel();
      if (!mounted) return;
      setState(() {
        _docs[type]!.uploading = false;
        _docs[type]!.error = e.toString();
      });
    }
  }

  Future<void> _continue() async {
    final uploaded = _docs.entries
        .where((e) => e.value.uploaded)
        .map((e) => DocumentEntity(
              id: '${e.key.name}_${DateTime.now().millisecondsSinceEpoch}',
              type: e.key,
              uploadedAt: DateTime.now(),
              isValid: true,
              storageUrl: e.value.storageUrl!,
            ))
        .toList();

    if (uploaded.isNotEmpty) {
      setState(() => _isSaving = true);
      try {
        await ref.read(creditRequestProvider.notifier).uploadDocuments(uploaded);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar documentos: $e')),
        );
        return;
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final uploadedCount = _docs.values.where((d) => d.uploaded).length;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Documentación',
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 26, fontWeight: FontWeight.w700, color: _primaryColor, letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adjuntá los documentos requeridos. Podés continuar sin subir todos, los auditores pueden solicitarlos durante la revisión.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: _onSurfaceVariantColor, height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  '$uploadedCount de 4 documentos cargados',
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                    color: uploadedCount > 0 ? _secondaryColor : _onSurfaceVariantColor,
                  ),
                ),
                const SizedBox(height: 24),
                ...DocumentType.values.map((type) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildDocCard(type),
                )),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _cyanColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _cyanColor.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: _secondaryColor, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Formatos aceptados: PDF, JPG, PNG. Los archivos se almacenan de forma segura.',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: _onSurfaceVariantColor, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildDocCard(DocumentType type) {
    final meta = _docMeta[type]!;
    final doc = _docs[type]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: doc.uploaded
            ? _secondaryColor.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: doc.uploaded
              ? _secondaryColor.withValues(alpha: 0.3)
              : doc.error != null
                  ? Colors.red.withValues(alpha: 0.4)
                  : _outlineVariantColor.withValues(alpha: 0.3),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.025), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: doc.uploaded ? _secondaryColor.withValues(alpha: 0.1) : _surfaceHighColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(meta.icon, color: doc.uploaded ? _secondaryColor : _onSurfaceVariantColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meta.label, style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w600, color: _onSurfaceColor)),
                    const SizedBox(height: 2),
                    Text(meta.hint, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: _onSurfaceVariantColor.withValues(alpha: 0.75))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (doc.uploaded)
                const Icon(Icons.check_circle_rounded, color: _secondaryColor, size: 22)
              else if (!doc.uploading)
                GestureDetector(
                  onTap: () => _pickAndUpload(type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Subir', style: TextStyle(fontFamily: 'Manrope', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
            ],
          ),
          if (doc.uploading) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: doc.uploadProgress,
                backgroundColor: _surfaceHighColor,
                valueColor: const AlwaysStoppedAnimation<Color>(_secondaryColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(doc.uploadProgress * 100).toStringAsFixed(0)}% subido...',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: _onSurfaceVariantColor),
            ),
          ],
          if (doc.uploaded && doc.fileName != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.attach_file, size: 14, color: _secondaryColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    doc.fileName!,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: _secondaryColor, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _pickAndUpload(type),
                  child: const Text('Reemplazar', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: _onSurfaceVariantColor, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ],
          if (doc.error != null) ...[
            const SizedBox(height: 8),
            Text('Error: ${doc.error}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.red)),
            TextButton(
              onPressed: () => _pickAndUpload(type),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 28)),
              child: const Text('Reintentar', style: TextStyle(fontSize: 12, color: _secondaryColor)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final anyUploading = _docs.values.any((d) => d.uploading);
    return Container(
      decoration: BoxDecoration(
        color: _bgColor.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: _outlineVariantColor.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: (anyUploading || _isSaving) ? null : widget.onBack,
                icon: const Icon(Icons.arrow_back, size: 18, color: _onSurfaceVariantColor),
                label: const Text('Atrás', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _onSurfaceVariantColor)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: (anyUploading || _isSaving) ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: const StadiumBorder(),
                ),
                child: (_isSaving || anyUploading)
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Continuar a Revisión', style: TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _mimeType(String filename) {
    final ext = filename.toLowerCase().split('.').last;
    switch (ext) {
      case 'pdf':  return 'application/pdf';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png':  return 'image/png';
      default:     return 'application/octet-stream';
    }
  }
}
