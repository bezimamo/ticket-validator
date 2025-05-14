//main.dart
import 'package:flutter/material.dart';
import 'qr_scanner_page.dart'; // Import the separate file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticket Scanner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const QrScannerPage(),
    );
  }
}
