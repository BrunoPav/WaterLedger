import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Documento a subir en el alta B2B: el archivo elegido (puede ser null),
/// el `docType` (subcarpeta en Storage) y la clave de Firestore donde guardar
/// la URL resultante.
typedef B2bUploadDoc = ({PlatformFile? file, String docType, String firestoreKey});

/// Lógica compartida de selección y subida de documentos para los registros
/// B2B (auditor / certificador / asegurador).
///
/// Convención de Storage: `registrations/{uid}/{docType}/{filename}`.
mixin B2bRegisterUpload {
  /// Abre el file picker (PDF/JPG/PNG) y devuelve el archivo elegido, o null
  /// si el usuario canceló.
  Future<PlatformFile?> pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.first;
  }

  /// Sube los documentos no nulos (best-effort, en paralelo) y devuelve el
  /// mapa `{ firestoreKey: downloadUrl }` con los que se pudieron subir.
  Future<Map<String, dynamic>> uploadDocuments(
    String uid,
    List<B2bUploadDoc> docs,
  ) async {
    final urlUpdates = <String, dynamic>{};
    await Future.wait(docs.map((doc) async {
      final file = doc.file;
      if (file == null) return;
      try {
        final url = await _uploadFile(uid, doc.docType, file);
        if (url != null) urlUpdates[doc.firestoreKey] = url;
      } catch (_) {
        // best-effort: ignoramos fallos de subida individuales
      }
    }));
    return urlUpdates;
  }

  Future<String?> _uploadFile(
      String uid, String docType, PlatformFile file) async {
    final mime = _mimeType(file.name);
    final storageRef = FirebaseStorage.instance
        .ref('registrations/$uid/$docType/${file.name}');
    final UploadTask task;
    if (file.bytes != null) {
      task = storageRef.putData(
          file.bytes!, SettableMetadata(contentType: mime));
    } else if (file.path != null) {
      task = storageRef.putFile(
          io.File(file.path!), SettableMetadata(contentType: mime));
    } else {
      return null;
    }
    final snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  String _mimeType(String filename) {
    switch (filename.toLowerCase().split('.').last) {
      case 'pdf':  return 'application/pdf';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png':  return 'image/png';
      default:     return 'application/octet-stream';
    }
  }
}
