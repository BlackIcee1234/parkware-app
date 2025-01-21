import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('¿Necesitas ayuda?'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '¡Bienvenido a nuestra sección de ayuda!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Estamos aquí para ayudarte. Si tienes alguna pregunta o problema, no dudes en contactarnos por teléfono o correo electrónico.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                ),
              ),
            ),
            SizedBox(height: 40),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('+52 3329860651'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('+52 3314405830'),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('andreereyes0@gmail.com'),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('mich.reyesh@gmail.com'),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
