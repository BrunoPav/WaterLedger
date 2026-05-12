import 'package:water_ledger/features/credit_issuance/domain/entities/document_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/document_type.dart';

class DocumentValidator {
  static List<String> validate(List<DocumentEntity> documents) {
    final errors = <String>[];

    final requiredTypes = {
      DocumentType.technical,
      DocumentType.environmental,
      DocumentType.legal,
      DocumentType.financial,
    };

    final uploadedTypes = documents.map((d) => d.type).toSet();

    for (final type in requiredTypes) {
      if (!uploadedTypes.contains(type)) {
        errors.add('Falta documentación ${type.name}.');
      }
    }

    return errors;
  }
}