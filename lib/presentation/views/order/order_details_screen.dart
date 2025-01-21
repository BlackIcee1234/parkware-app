import 'package:flutter/material.dart';
import 'package:parkware/presentation/views/home/home_screen.dart';

class OrderView extends StatelessWidget {
  final String orderId;
  final String status;
  final String date;
  final int totalAmount;

  OrderView({required this.orderId, required this.status, required this.date, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    // Formatear el total manualmente como 356.00 MXN
    final formattedTotal = '${(totalAmount / 100).toStringAsFixed(2)} MXN';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Pedido'),
        automaticallyImplyLeading: false,  // Esta línea oculta la flecha de regreso
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100.0,
              ),
              SizedBox(height: 20.0),
              Text(
                'Pedido #$orderId',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Text(
                'Estado: $status',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Fecha: $date',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              Text(
                'Total: $formattedTotal',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text('Volver al Menú'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
