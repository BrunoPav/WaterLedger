class CreditRequest {
  String id;
  String issuerCompanyId;
  String projectName;
  int creditAmount;
  String documents;
  RequestStatus status;
  DateTime createdAt;

  CreditRequest({
    required this.id,
    required this.issuerCompanyId,
    required this.projectName,
    required this.creditAmount,
    required this.documents,
    required this.status,
    required this.createdAt,
  });
}

enum RequestStatus { pending, approved, rejected }
