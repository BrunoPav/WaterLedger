import 'package:water_ledger/features/credit_issuance/domain/enums/document_type.dart';

class DocumentEntity {
  String id;
  DocumentType type;
  DateTime uploadedAt;
  bool isValid;

  DocumentEntity({
    required this.id,
    required this.type,
    required this.uploadedAt,
    required this.isValid,
  });
} 
