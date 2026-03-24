import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/emergency_model.dart';

/// PDF generation service — FIR reports and safety reports
class PdfService {

  // ── FIR Report ────────────────────────────────────────────────────────────

  Future<File> generateFirReport(EmergencyModel emergency) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: pw.BoxDecoration(
                color: PdfColors.red800,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'FIRST INFORMATION REPORT (FIR)',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Women Safety Application — Incident Report',
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // FIR number & date
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('FIR No: ${emergency.id.substring(0, 20)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Date: ${_fmtDate(emergency.triggeredAt)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.red800),
            pw.SizedBox(height: 12),

            _firSection('1. Complainant Information', [
              _firRow('Full Name', emergency.userName),
              _firRow('Contact Number', emergency.userPhone),
              _firRow('Incident Date & Time', _fmtDateTime(emergency.triggeredAt)),
            ]),
            pw.SizedBox(height: 12),

            _firSection('2. Incident Location', [
              _firRow('Address', emergency.address),
              _firRow('GPS Coordinates',
                  '${emergency.latitude.toStringAsFixed(6)}, ${emergency.longitude.toStringAsFixed(6)}'),
              _firRow('Google Maps', emergency.googleMapsLink),
            ]),
            pw.SizedBox(height: 12),

            _firSection('3. Incident Details', [
              _firRow('Type of Emergency', 'Personal Safety Emergency — SOS Triggered'),
              _firRow('Alert Method', 'Power Button Triple-Click / SOS Button'),
              _firRow('Current Status', _statusText(emergency.status)),
            ]),
            pw.SizedBox(height: 12),

            _firSection('4. Police Response', [
              _firRow('Responding Officer', emergency.policeName ?? 'Not yet assigned'),
              _firRow('Officer ID', emergency.policeId ?? 'N/A'),
              _firRow('Response Status',
                  emergency.status == EmergencyStatus.helpRequested
                      ? 'Awaiting Response'
                      : _statusText(emergency.status)),
              _firRow('Rescue Completed At',
                  emergency.rescueCompletedAt != null
                      ? _fmtDateTime(emergency.rescueCompletedAt!)
                      : 'N/A'),
              _firRow('Police Arrival Time', emergency.policeArrivalTime ?? 'N/A'),
            ]),
            pw.SizedBox(height: 12),

            _firSection('5. Additional Notes', [
              pw.Text(
                emergency.safetyNotes?.isNotEmpty == true
                    ? emergency.safetyNotes!
                    : 'No additional notes provided.',
                style: const pw.TextStyle(fontSize: 11),
              ),
            ]),

            pw.Spacer(),

            // Signature row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _sigBox('Complainant Signature'),
                _sigBox('Officer Signature'),
                _sigBox('Station Seal'),
              ],
            ),
            pw.SizedBox(height: 16),

            // Footer
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                'Auto-generated by Women Safety App  |  '
                'Report ID: ${emergency.id}  |  '
                'Generated: ${_fmtDateTime(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/FIR_${emergency.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ── Safety Report (legacy) ────────────────────────────────────────────────

  Future<File> generateSafetyReport(EmergencyModel emergency) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              color: PdfColors.red,
              child: pw.Text(
                'SAFETY REPORT',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            _section('Incident Information', [
              _row('Report ID', emergency.id),
              _row('Date & Time', emergency.triggeredAt.toString()),
              _row('Status', _statusText(emergency.status)),
            ]),
            pw.SizedBox(height: 20),
            _section('User Information', [
              _row('Name', emergency.userName),
              _row('Phone', emergency.userPhone),
            ]),
            pw.SizedBox(height: 20),
            _section('Location Information', [
              _row('Address', emergency.address),
              _row('Latitude', emergency.latitude.toString()),
              _row('Longitude', emergency.longitude.toString()),
              _row('Google Maps', emergency.googleMapsLink),
            ]),
            pw.SizedBox(height: 20),
            if (emergency.policeName != null)
              _section('Police Response', [
                _row('Officer Name', emergency.policeName!),
                if (emergency.policeArrivalTime != null)
                  _row('Arrival Time', emergency.policeArrivalTime!),
                if (emergency.rescueCompletedAt != null)
                  _row('Rescue Completed', emergency.rescueCompletedAt.toString()),
                _row('Verified', emergency.isVerified ? 'Yes' : 'No'),
              ]),
            pw.SizedBox(height: 20),
            if (emergency.safetyNotes != null)
              _section('Safety Notes', [pw.Text(emergency.safetyNotes!)]),
            pw.Spacer(),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
              child: pw.Text(
                'Official safety report — Women Safety App',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/safety_report_${emergency.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ── Share / Print ─────────────────────────────────────────────────────────

  Future<void> sharePdf(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: pdfFile.path.split('/').last,
    );
  }

  Future<void> printPdf(File pdfFile) async {
    await Printing.layoutPdf(
      onLayout: (_) async => pdfFile.readAsBytes(),
    );
  }

  // ── FIR helpers ───────────────────────────────────────────────────────────

  pw.Widget _firSection(String title, List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red800)),
          pw.SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _firRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 160,
            child: pw.Text('$label:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          ),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 11))),
        ],
      ),
    );
  }

  pw.Widget _sigBox(String label) {
    return pw.Container(
      width: 140,
      height: 60,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Align(
        alignment: pw.Alignment.bottomCenter,
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Text(label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ),
      ),
    );
  }

  // ── Safety report helpers ─────────────────────────────────────────────────

  pw.Widget _section(String title, List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text('$label:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  String _statusText(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.helpRequested:
        return 'Help Requested';
      case EmergencyStatus.policeOnTheWay:
        return 'Police On The Way';
      case EmergencyStatus.rescued:
        return 'Rescued';
      case EmergencyStatus.safetyConfirmed:
        return 'Safety Confirmed';
    }
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';

  String _fmtDateTime(DateTime dt) =>
      '${_fmtDate(dt)}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
