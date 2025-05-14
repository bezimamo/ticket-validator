import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  String resultText = "";
  String status = "";
  bool isScanning = true;

  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  Future<void> validateTicket(String ticketId, String eventId) async {
    final url = Uri.parse('https://<your-convex-deployment>.convex.cloud/api/validateTicket'); // Replace this with your real Convex endpoint

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ticketId': ticketId,
        'eventId': eventId,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        status = json['status'];
        resultText = json['message'];
      });
    } else {
      setState(() {
        status = 'error';
        resultText = '❌ Server error';
      });
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!isScanning) return;

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;
    if (code == null) return;

    setState(() => isScanning = false);

    final parts = code.split(':');
    if (parts.length == 2) {
      await validateTicket(parts[0], parts[1]);
    } else {
      setState(() {
        resultText = "❌ Invalid QR Code Format";
        status = "invalid_format";
      });
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = {
      'valid': Colors.green,
      'used': Colors.orange,
      'wrong_event': Colors.red,
      'invalid_format': Colors.red,
      'error': Colors.grey,
    }[status];

    return Scaffold(
      appBar: AppBar(title: const Text("Scan Ticket")),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (resultText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: color ?? Colors.white,
                    child: Text(
                      resultText,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      resultText = "";
                      status = "";
                      isScanning = true;
                    });
                  },
                  child: const Text("🔁 Scan Again"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
