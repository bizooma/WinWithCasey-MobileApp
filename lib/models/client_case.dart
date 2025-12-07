enum CaseStatus { intake, active, negotiating, settled, closed }

class ClientCase {
  final String id;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final DateTime createdAt;
  final CaseStatus status;
  final String accidentReportId;
  final List<String> documents;
  final List<CaseMilestone> milestones;
  final List<CommunicationEntry> communications;
  final String attorneyNotes;

  ClientCase({
    required this.id,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.createdAt,
    required this.status,
    required this.accidentReportId,
    required this.documents,
    required this.milestones,
    required this.communications,
    required this.attorneyNotes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientName': clientName,
    'clientEmail': clientEmail,
    'clientPhone': clientPhone,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'accidentReportId': accidentReportId,
    'documents': documents,
    'milestones': milestones.map((m) => m.toJson()).toList(),
    'communications': communications.map((c) => c.toJson()).toList(),
    'attorneyNotes': attorneyNotes,
  };

  factory ClientCase.fromJson(Map<String, dynamic> json) => ClientCase(
    id: json['id'],
    clientName: json['clientName'],
    clientEmail: json['clientEmail'],
    clientPhone: json['clientPhone'],
    createdAt: DateTime.parse(json['createdAt']),
    status: CaseStatus.values.byName(json['status']),
    accidentReportId: json['accidentReportId'],
    documents: List<String>.from(json['documents']),
    milestones: (json['milestones'] as List)
        .map((m) => CaseMilestone.fromJson(m))
        .toList(),
    communications: (json['communications'] as List)
        .map((c) => CommunicationEntry.fromJson(c))
        .toList(),
    attorneyNotes: json['attorneyNotes'],
  );
}

class CaseMilestone {
  final String title;
  final String description;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final bool isCompleted;

  CaseMilestone({
    required this.title,
    required this.description,
    this.dueDate,
    this.completedDate,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'dueDate': dueDate?.toIso8601String(),
    'completedDate': completedDate?.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory CaseMilestone.fromJson(Map<String, dynamic> json) => CaseMilestone(
    title: json['title'],
    description: json['description'],
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    completedDate: json['completedDate'] != null 
        ? DateTime.parse(json['completedDate']) : null,
    isCompleted: json['isCompleted'],
  );
}

class CommunicationEntry {
  final String id;
  final DateTime timestamp;
  final String message;
  final bool fromClient;
  final String? attachmentPath;

  CommunicationEntry({
    required this.id,
    required this.timestamp,
    required this.message,
    required this.fromClient,
    this.attachmentPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'message': message,
    'fromClient': fromClient,
    'attachmentPath': attachmentPath,
  };

  factory CommunicationEntry.fromJson(Map<String, dynamic> json) =>
      CommunicationEntry(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        message: json['message'],
        fromClient: json['fromClient'],
        attachmentPath: json['attachmentPath'],
      );
}