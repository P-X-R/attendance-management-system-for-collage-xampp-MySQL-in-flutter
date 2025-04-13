import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_app/components/custom_drawer.dart';

class UploadStudents extends StatefulWidget {
  final String adminName;

  const UploadStudents({super.key, required this.adminName});

  @override
  _UploadStudentsState createState() => _UploadStudentsState();
}

class _UploadStudentsState extends State<UploadStudents> {
  List<Map<String, String>> studentList = [];
  bool isLoading = false;

  Future<void> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      readExcel(file);
    }
  }

  void readExcel(File file) async {
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    List<Map<String, String>> tempStudents = [];

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows.skip(1)) {
        if (row.length >= 6) {
          tempStudents.add({
            "name": row[0]?.value.toString() ?? "",
            "username": row[1]?.value.toString() ?? "",
            "email": row[2]?.value.toString() ?? "",
            "password": row[3]?.value.toString() ?? "",
            "department_id": row[4]?.value.toString() ?? "",
            "semester": row[5]?.value.toString() ?? "",
          });
        }
      }
    }

    setState(() {
      studentList = tempStudents;
    });
  }

  Future<void> sendToServer() async {
    if (studentList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No students to upload!")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    String apiUrl = "http://10.0.2.2/localconnect/upload_students.php";

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"students": studentList}),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Students Uploaded Successfully!")),
        );
        clearSelection();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload Failed: ${data['message']}")),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Server Error!")));
    }
  }

  void clearSelection() {
    setState(() {
      studentList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Excel Upload Students",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[200], // Dark green header
      ),
      drawer: CustomDrawer(adminName: widget.adminName),
      body: Container(
        color: Colors.green[50], // Light green background
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.green[100],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📄 Excel Format Guide",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    SizedBox(height: 10),
                    Table(
                      border: TableBorder.all(),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.green[200]),
                          children: [
                            tableCell("Name"),
                            tableCell("Username"),
                            tableCell("Email"),
                            tableCell("Password"),
                            tableCell("Dept. ID"),
                            tableCell("Semester"),
                          ],
                        ),
                        TableRow(
                          children: [
                            tableCell("John Doe"),
                            tableCell("UCE123"),
                            tableCell("john@example.com"),
                            tableCell("password123"),
                            tableCell("CSE"),
                            tableCell("S3"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: pickExcelFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400], // Green button
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Pick Excel File",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (studentList.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📋 Preview (${studentList.length} Students):",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                border: TableBorder.all(),
                                columns: [
                                  DataColumn(label: Text("Name")),
                                  DataColumn(label: Text("Username")),
                                  DataColumn(label: Text("Email")),
                                  DataColumn(label: Text("Password")),
                                  DataColumn(label: Text("Dept. ID")),
                                  DataColumn(label: Text("Semester")),
                                ],
                                rows:
                                    studentList.map((student) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(student['name']!)),
                                          DataCell(Text(student['username']!)),
                                          DataCell(Text(student['email']!)),
                                          DataCell(Text(student['password']!)),
                                          DataCell(
                                            Text(student['department_id']!),
                                          ),
                                          DataCell(Text(student['semester']!)),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: isLoading ? null : sendToServer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[400],
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child:
                              isLoading
                                  ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    "Upload",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                        ElevatedButton(
                          onPressed: clearSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            "Clear",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}
