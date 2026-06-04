import 'package:water_ledger/features/credit_issuance/domain/enums/document_type.dart';

class DocumentEntity {
  String id;
  DocumentType type;
  DateTime uploadedAt;
  bool isValid;
  String storageUrl;

  DocumentEntity({
    required this.id,
    required this.type,
    required this.uploadedAt,
    required this.isValid,
    this.storageUrl = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'uploadedAt': uploadedAt.toIso8601String(),
    'isValid': isValid,
    'storageUrl': storageUrl,
  };

  factory DocumentEntity.fromMap(Map<String, dynamic> map) => DocumentEntity(
    id: map['id'] ?? '',
    type: DocumentType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => DocumentType.technical,
    ),
    uploadedAt: map['uploadedAt'] is DateTime
        ? map['uploadedAt'] as DateTime
        : DateTime.tryParse(map['uploadedAt']?.toString() ?? '') ?? DateTime.now(),
    isValid: map['isValid'] ?? false,
    storageUrl: map['storageUrl'] ?? '',
  );
}
