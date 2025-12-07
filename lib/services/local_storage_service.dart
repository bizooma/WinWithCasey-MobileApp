import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/accident_report.dart';
import '../models/client_case.dart';
import '../models/medical_record.dart';

class LocalStorageService {
  static const String _accidentReportsKey = 'accident_reports';
  static const String _clientCasesKey = 'client_cases';
  static const String _medicalAppointmentsKey = 'medical_appointments';
  static const String _medicalRecordsKey = 'medical_records';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  // Accident Reports
  Future<List<AccidentReport>> getAccidentReports() async {
    final prefs = await _prefs();
    final jsonStr = prefs.getString(_accidentReportsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => AccidentReport.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAccidentReport(AccidentReport report) async {
    final prefs = await _prefs();
    final existing = await getAccidentReports();
    existing.add(report);
    final encoded = jsonEncode(existing.map((e) => e.toJson()).toList());
    await prefs.setString(_accidentReportsKey, encoded);
  }

  // Client Cases
  Future<List<ClientCase>> getClientCases() async {
    final prefs = await _prefs();
    final jsonStr = prefs.getString(_clientCasesKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => ClientCase.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveClientCase(ClientCase clientCase) async {
    final prefs = await _prefs();
    final existing = await getClientCases();
    existing.add(clientCase);
    final encoded = jsonEncode(existing.map((e) => e.toJson()).toList());
    await prefs.setString(_clientCasesKey, encoded);
  }

  // Medical Appointments
  Future<List<MedicalAppointment>> getMedicalAppointments() async {
    final prefs = await _prefs();
    final jsonStr = prefs.getString(_medicalAppointmentsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => MedicalAppointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveMedicalAppointment(MedicalAppointment appointment) async {
    final prefs = await _prefs();
    final existing = await getMedicalAppointments();
    existing.add(appointment);
    final encoded = jsonEncode(existing.map((e) => e.toJson()).toList());
    await prefs.setString(_medicalAppointmentsKey, encoded);
  }

  // Medical Records
  Future<List<MedicalRecord>> getMedicalRecords() async {
    final prefs = await _prefs();
    final jsonStr = prefs.getString(_medicalRecordsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => MedicalRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveMedicalRecord(MedicalRecord record) async {
    final prefs = await _prefs();
    final existing = await getMedicalRecords();
    existing.add(record);
    final encoded = jsonEncode(existing.map((e) => e.toJson()).toList());
    await prefs.setString(_medicalRecordsKey, encoded);
  }
}
