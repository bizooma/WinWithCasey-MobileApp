class MedicalRecord {
  final String id;
  final DateTime date;
  final String providerName;
  final String appointmentType;
  final int painLevel; // 1-10 scale
  final String symptoms;
  final String treatment;
  final String notes;
  final List<String> photoUrls;
  final double? cost;
  final bool insuranceCovered;

  MedicalRecord({
    required this.id,
    required this.date,
    required this.providerName,
    required this.appointmentType,
    required this.painLevel,
    required this.symptoms,
    required this.treatment,
    required this.notes,
    required this.photoUrls,
    this.cost,
    required this.insuranceCovered,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'providerName': providerName,
    'appointmentType': appointmentType,
    'painLevel': painLevel,
    'symptoms': symptoms,
    'treatment': treatment,
    'notes': notes,
    'photoUrls': photoUrls,
    'cost': cost,
    'insuranceCovered': insuranceCovered,
  };

  factory MedicalRecord.fromJson(Map<String, dynamic> json) => MedicalRecord(
    id: json['id'],
    date: DateTime.parse(json['date']),
    providerName: json['providerName'],
    appointmentType: json['appointmentType'],
    painLevel: json['painLevel'],
    symptoms: json['symptoms'],
    treatment: json['treatment'],
    notes: json['notes'],
    photoUrls: List<String>.from(json['photoUrls']),
    cost: json['cost'],
    insuranceCovered: json['insuranceCovered'],
  );
}

class MedicalAppointment {
  final String id;
  final DateTime scheduledDate;
  final String providerName;
  final String appointmentType;
  final String address;
  final String phoneNumber;
  final bool isCompleted;
  final String? medicalRecordId;

  MedicalAppointment({
    required this.id,
    required this.scheduledDate,
    required this.providerName,
    required this.appointmentType,
    required this.address,
    required this.phoneNumber,
    required this.isCompleted,
    this.medicalRecordId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'scheduledDate': scheduledDate.toIso8601String(),
    'providerName': providerName,
    'appointmentType': appointmentType,
    'address': address,
    'phoneNumber': phoneNumber,
    'isCompleted': isCompleted,
    'medicalRecordId': medicalRecordId,
  };

  factory MedicalAppointment.fromJson(Map<String, dynamic> json) =>
      MedicalAppointment(
        id: json['id'],
        scheduledDate: DateTime.parse(json['scheduledDate']),
        providerName: json['providerName'],
        appointmentType: json['appointmentType'],
        address: json['address'],
        phoneNumber: json['phoneNumber'],
        isCompleted: json['isCompleted'],
        medicalRecordId: json['medicalRecordId'],
      );
}