import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_app/components/custom_drawer.dart';

class UploadFaculty extends StatefulWidget {
  final String adminName;

  const UploadFaculty({super.key, required this.adminName});

  @override
  _UploadFacultyState createState() => _UploadFacultyState();
}

class _UploadFacultyState extends State<UploadFaculty> {
  List<Map<String, String>> facultyList = [];
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

    List<Map<String, String>> tempFaculty = [];

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows.skip(1)) {
        if (row.length >= 5) {
          tempFaculty.add({
            "name": row[0]?.value.toString() ?? "",
            "username": row[1]?.value.toString() ?? "",
            "email": row[2]?.value.toString() ?? "",
            "password": row[3]?.value.toString() ?? "",
            "department_id": row[4]?.value.toString() ?? "",
          });
        }
      }
    }

    setState(() {
      facultyList = tempFaculty;
    });
  }

  Future<void> sendToServer() async {
    if (facultyList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No faculty to upload!")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    String apiUrl = "http://10.0.2.2/localconnect/upload_faculty.php";

    // ✅ Debugging: Print request body
    String requestBody = jsonEncode({"faculty": facultyList});
    print("Sending Request: $requestBody");

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: requestBody,
    );

    setState(() {
      isLoading = false;
    });

    // ✅ Debugging: Print response
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Faculty Uploaded Successfully!")),
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
      facultyList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Excel Upload Faculty",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[200],
      ),
      drawer: CustomDrawer(adminName: widget.adminName),
      body: Container(
        color: Colors.green[50],
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
                          ],
                        ),
                        TableRow(
                          children: [
                            tableCell("John Doe"),
                            tableCell("FAC123"),
                            tableCell("johndoe@example.com"),
                            tableCell("password123"),
                            tableCell("CSE"),
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
                  backgroundColor: Colors.green[400],
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
            if (facultyList.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📋 Preview (${facultyList.length} Faculty Members):",
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
                                ],
                                rows:
                                    facultyList.map((faculty) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(faculty['name']!)),
                                          DataCell(Text(faculty['username']!)),
                                          DataCell(Text(faculty['email']!)),
                                          DataCell(Text(faculty['password']!)),
                                          DataCell(
                                            Text(faculty['department_id']!),
                                          ),
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
