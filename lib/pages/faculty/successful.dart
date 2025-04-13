import 'package:attendance_app/pages/faculty/Widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AttendanceConfirmation extends StatelessWidget {
  final String subjectName;
  final List<String> presentStudents;
  final List<String> absentStudents;

  const AttendanceConfirmation({
    super.key,
    required this.subjectName,
    required this.presentStudents,
    required this.absentStudents,
  });

  void generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Attendance Report",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Subject: $subjectName",
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Present Students:",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                ...presentStudents.map((student) => pw.Text(student)),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Absent Students:",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                ...absentStudents.map((student) => pw.Text(student)),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFD7),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      drawer: FacultyDrawer(facultyName: "Lini Miss."),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double titleFontSize = screenWidth * 0.06; // 6% of screen width
          double iconSize = screenWidth * 0.1; // 10% of screen width
          double spacing = screenWidth * 0.02; // 2% of screen width

          return Padding(
            padding: EdgeInsets.all(spacing),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Attendance Recorded!",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing * 2),
                  // Download button with white background and slight curve (radius 10)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.download,
                        size: iconSize,
                        color: Colors.black,
                      ),
                      onPressed: () => generatePdf(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
