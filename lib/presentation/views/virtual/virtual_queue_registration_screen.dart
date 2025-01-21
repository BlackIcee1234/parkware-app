import 'package:flutter/material.dart';
import 'package:parkware/controllers/user_controller.dart';
import 'package:parkware/domain/models/attraction.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:parkware/presentation/views/virtual/virtual_queue_status_page.dart';

class VirtualQueueRegistrationPage extends StatefulWidget {
  final Attraction attraction;
  final int personsCount;

  const VirtualQueueRegistrationPage({
    Key? key,
    required this.attraction,
    required this.personsCount,
  }) : super(key: key);

  @override
  _VirtualQueueRegistrationPageState createState() =>
      _VirtualQueueRegistrationPageState();
}

class _VirtualQueueRegistrationPageState
    extends State<VirtualQueueRegistrationPage> {
  List<String> registrations = [];
  bool isLoading = false;
  TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro en la Fila Virtual'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Atracción: ${widget.attraction.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Número de Personas: ${widget.personsCount}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Por favor, proporciona el código QR de tu pulsera:',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _scanQR,
              icon: Icon(Icons.camera_alt),
              label: Text('Escanear Código QR'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            if (isLoading) Center(child: CircularProgressIndicator()),
            Text(
              'Registros:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: registrations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.verified, color: Colors.green),
                    title: Text('Verificado', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          registrations.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: registrations.length == widget.personsCount
          ? FloatingActionButton(
              onPressed: () {
                _registerInQueue();
              },
              child: Icon(Icons.arrow_forward),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }

  void _scanQR() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#FFFFFF", "Cancelar", true, ScanMode.QR);
      if (barcodeScanRes != '-1') {
        _verifyQRCode(barcodeScanRes);
      }
    } on PlatformException {
      // Handle exception
    }
  }

  Future<void> _verifyQRCode(String qrCode) async {
    // Verificar si el código QR ya está registrado
    if (registrations.contains(qrCode)) {
      _showErrorDialog("Este código QR ya ha sido registrado");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://parkware-ten.vercel.app/api/qrcode/verify'); // Cambia esto a tu URL de API
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': qrCode}),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true &&
          responseBody['message'] == "Este código QR está activo") {
        setState(() {
          registrations.add(qrCode);
        });
      } else {
        _showErrorDialog("Este código QR no está activo");
      }
    } else {
      _showErrorDialog("Error verificando el código QR");
    }
  }

  Future<void> _registerInQueue() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://parkware-ten.vercel.app/api/queue/join');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': UserController.getCurrentUserUid(),
        'qrCodes': jsonEncode(registrations),
      }),
    );
    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VirtualQueueStatusPage(uid: UserController.getCurrentUserUid())),
        );
      } else {
        _showErrorDialog("Error registrando en la fila virtual");
      }
    } else {
      _showErrorDialog("Error en el servidor");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
