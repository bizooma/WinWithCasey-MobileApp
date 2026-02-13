import 'package:flutter/foundation.dart';
import 'package:impactguide/models/accident_report.dart';
import 'package:impactguide/services/identity_service.dart';
import 'package:impactguide/services/location_service.dart';
import 'package:impactguide/supabase/supabase_config.dart';

class AccidentReportEmailService {
  static const String _functionName = 'send-accident-report-email';

  /// Best-effort email send.
  ///
  /// This is intended for temporary testing (currently hard-coded to Joe's email
  /// by default in the Edge Function).
  static Future<void> sendAccidentReportSubmittedEmail(AccidentReport report) async {
    try {
      final id = IdentityService.instance;
      final coordsString = (report.latitude != null && report.longitude != null)
          ? LocationService.formatCoordinates(report.latitude!, report.longitude!)
          : 'Unavailable';
      final mapsLink = (report.latitude != null && report.longitude != null)
          ? 'https://maps.google.com/?q=${report.latitude},${report.longitude}'
          : 'N/A';

      final clientLine = [
        if (id.name != null) id.name,
        if (id.phone != null) id.phone,
        if (id.email != null) id.email,
      ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' • ');

      final subject =
          'Accident Report ${report.id}${coordsString != 'Unavailable' ? ' – $coordsString' : ''}${clientLine.isNotEmpty ? ' – $clientLine' : ''}';

      final text = StringBuffer()
        ..writeln('App: Win With CASEY')
        ..writeln('User ID: ${id.userId}')
        ..writeln('Client: ${clientLine.isNotEmpty ? clientLine : 'N/A'}')
        ..writeln('Accident Report ID: ${report.id}')
        ..writeln('Time: ${report.timestamp.toLocal()}')
        ..writeln('Coordinates: $coordsString')
        ..writeln('Maps: $mapsLink')
        ..writeln('Description: ${report.description}')
        ..writeln('Injuries: ${report.injuryDescription}')
        ..writeln('Witnesses: ${report.witnesses.join(', ')}')
        ..writeln('Police Report #: ${report.policeReportNumber}')
        ..writeln('Emergency services called: ${report.emergencyServicesCalled ? 'Yes' : 'No'}');

      await SupabaseConfig.client.functions.invoke(
        _functionName,
        body: {
          // Keep `to` optional so we can override server-side defaults later.
          'subject': subject,
          'text': text.toString(),
          'report': report.toJson(),
        },
      );
    } catch (e) {
      debugPrint('AccidentReportEmailService failed: $e');
    }
  }
}
