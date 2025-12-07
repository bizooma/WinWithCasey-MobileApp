import 'package:flutter/foundation.dart';

class AccidentReport {
  final String id;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String locationDescription;
  final List<String> photoUrls;
  final List<String> audioUrls;
  final String description;
  final List<String> witnesses;
  final String injuryDescription;
  final bool emergencyServicesCalled;
  final String policeReportNumber;

  const AccidentReport({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.locationDescription,
    required this.photoUrls,
    required this.audioUrls,
    required this.description,
    required this.witnesses,
    required this.injuryDescription,
    required this.emergencyServicesCalled,
    required this.policeReportNumber,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'locationDescription': locationDescription,
        'photoUrls': photoUrls,
        'audioUrls': audioUrls,
        'description': description,
        'witnesses': witnesses,
        'injuryDescription': injuryDescription,
        'emergencyServicesCalled': emergencyServicesCalled,
        'policeReportNumber': policeReportNumber,
      };

  factory AccidentReport.fromJson(Map<String, dynamic> json) => AccidentReport(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        locationDescription: json['locationDescription'] as String? ?? '',
        photoUrls: List<String>.from(json['photoUrls'] ?? const <String>[]),
        audioUrls: List<String>.from(json['audioUrls'] ?? const <String>[]),
        description: json['description'] as String? ?? '',
        witnesses: List<String>.from(json['witnesses'] ?? const <String>[]),
        injuryDescription: json['injuryDescription'] as String? ?? '',
        emergencyServicesCalled: json['emergencyServicesCalled'] as bool? ?? false,
        policeReportNumber: json['policeReportNumber'] as String? ?? '',
      );
}
