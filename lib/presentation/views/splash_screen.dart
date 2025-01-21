import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _appName = '';
  int _index = 0;
  List<String> _appNameLetters = ['P', 'a', 'r', 'k', 'w', 'a', 'r', 'e'];

  @override
  void initState() {
    super.initState();
    _showAppName();
  }

  // Método para mostrar el nombre de la aplicación letra por letra con un retraso
  void _showAppName() {
    Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (_index < _appNameLetters.length) {
        setState(() {
          _appName += _appNameLetters[_index];
          _index++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _appName, // Nombre de la aplicación dinámico
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green, // Color del texto
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator( // Indicador de carga
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green), // Color del indicador de carga
            ),
          ],
        ),
      ),
    );
  }
}
