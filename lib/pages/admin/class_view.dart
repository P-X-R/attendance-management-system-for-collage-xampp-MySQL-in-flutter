import 'package:flutter/material.dart';

class classview extends StatelessWidget {
  final String adminName;

  const classview({super.key, required this.adminName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('student Home')));
  }
}
