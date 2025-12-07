enum DocumentType {
  driverLicense,
  insuranceCard,
  medicalRecord,
  policeReport,
  photo,
  audio,
  other,
}

class Document {
  final String id;
  final String name;
  final DocumentType type;
  final String filePath;
  final DateTime createdAt;
  final String description;
  final int fileSize;

  Document({
    required this.id,
    required this.name,
    required this.type,
    required this.filePath,
    required this.createdAt,
    required this.description,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'filePath': filePath,
    'createdAt': createdAt.toIso8601String(),
    'description': description,
    'fileSize': fileSize,
  };

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json['id'],
    name: json['name'],
    type: DocumentType.values.byName(json['type']),
    filePath: json['filePath'],
    createdAt: DateTime.parse(json['createdAt']),
    description: json['description'],
    fileSize: json['fileSize'],
  );

  String get typeDisplayName {
    switch (type) {
      case DocumentType.driverLicense:
        return "Driver's License";
      case DocumentType.insuranceCard:
        return "Insurance Card";
      case DocumentType.medicalRecord:
        return "Medical Record";
      case DocumentType.policeReport:
        return "Police Report";
      case DocumentType.photo:
        return "Photo";
      case DocumentType.audio:
        return "Audio Recording";
      case DocumentType.other:
        return "Other Document";
    }
  }
}