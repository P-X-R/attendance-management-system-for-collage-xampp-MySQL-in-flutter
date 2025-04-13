import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart' show SpinKitThreeBounce;
import 'package:attendance_app/components/custom_drawer.dart';

class PromoteStudentsScreen extends StatefulWidget {
  final String adminName;

  const PromoteStudentsScreen({super.key, required this.adminName});

  @override
  _PromoteStudentsScreenState createState() => _PromoteStudentsScreenState();
}

class _PromoteStudentsScreenState extends State<PromoteStudentsScreen> {
  bool isLoading = false;

  Future<void> updateSemesters(String action) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse("http://10.0.2.2/localconnect/update_semesters.php");

    try {
      final response = await http.post(
        url,
        body: {'action': action}, // Send action type to PHP
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: data['success'] ? Colors.green : Colors.red,
          ),
        );
      } else {
        throw Exception("Invalid response from server");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showConfirmationDialog(String action) async {
    String actionText = action == "promote" ? "Promote" : "Demote";
    String message =
        action == "promote"
            ? "Are you sure you want to promote all students to the next semester?"
            : "Are you sure you want to demote all students to the previous semester?";

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "$actionText Students",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                updateSemesters(action);
              },
              icon: Icon(
                action == "promote" ? Icons.arrow_upward : Icons.arrow_downward,
              ),
              label: Text("Yes, $actionText"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text("Manage Student Semesters"),
        backgroundColor: Colors.green[100],
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
      ),
      drawer: CustomDrawer(adminName: widget.adminName),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Promote Button
              ElevatedButton.icon(
                onPressed:
                    isLoading ? null : () => _showConfirmationDialog("promote"),
                icon: Icon(Icons.arrow_upward, color: Colors.white),
                label:
                    isLoading
                        ? SpinKitThreeBounce(color: Colors.white, size: 20.0)
                        : Text("Promote All Students"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 14),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Demote Button
              ElevatedButton.icon(
                onPressed:
                    isLoading ? null : () => _showConfirmationDialog("demote"),
                icon: Icon(Icons.arrow_downward, color: Colors.white),
                label:
                    isLoading
                        ? SpinKitThreeBounce(color: Colors.white, size: 20.0)
                        : Text("Demote All Students"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 14),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
