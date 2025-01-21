import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:parkware/presentation/views/home/home_screen.dart';

class VirtualQueueStatusPage extends StatefulWidget {
  final String uid;

  const VirtualQueueStatusPage({Key? key, required this.uid}) : super(key: key);

  @override
  _VirtualQueueStatusPageState createState() => _VirtualQueueStatusPageState();
}

class _VirtualQueueStatusPageState extends State<VirtualQueueStatusPage> {
  List<Map<String, dynamic>> users = [];
  Timer? _timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQueueStatus();
    _startPeriodicUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchQueueStatus() async {
    final url = Uri.parse('https://parkware-ten.vercel.app/api/queue/status');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': widget.uid}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true) {
        setState(() {
          users = List<Map<String, dynamic>>.from(responseBody['queueState']['users']);
          isLoading = false;
        });
        _startTimers();
      } else {
        _showErrorDialog("Error obteniendo el estado de la fila virtual");
      }
    } else {
      _showErrorDialog("Error en el servidor");
    }
  }

  void _startPeriodicUpdate() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _updateTimers();
      });
    });
  }

  void _startTimers() {
    for (var user in users) {
      final timeParts = user['timeUntilNextRemoval'].split(' ');
      final minutes = int.parse(timeParts[0]);
      final seconds = int.parse(timeParts[3]);
      user['timeRemaining'] = Duration(minutes: minutes, seconds: seconds);

      final rideTimeParts = user['timeToNextRide'].split(' ');
      final rideMinutes = int.parse(rideTimeParts[0]);
      final rideSeconds = int.parse(rideTimeParts[3]);
      user['rideTimeRemaining'] = Duration(minutes: rideMinutes, seconds: rideSeconds);
    }
  }

  void _updateTimers() {
    for (var user in users) {
      if (user['timeRemaining'].inSeconds > 0) {
        user['timeRemaining'] = user['timeRemaining'] - Duration(seconds: 1);
      } else {
        user['timeRemaining'] = Duration(seconds: 0);
      }

      if (user['rideTimeRemaining'].inSeconds > 0) {
        user['rideTimeRemaining'] = user['rideTimeRemaining'] - Duration(seconds: 1);
      } else {
        user['rideTimeRemaining'] = Duration(seconds: 0);
      }
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

  void _showFiveMinuteWarning(String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aviso'),
          content: Text('$userName debe estar listo en 5 minutos.'),
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

Future<void> _leaveQueue(String text) async {
  bool confirmExit = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar salida'),
        content: Text('¿Estás seguro de salir de la fila virtual? Perderás tu lugar pero puedes volver a intentarlo después.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // No confirmar salida
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirmar salida
            },
            child: Text('Salir'),
          ),
        ],
      );
    },
  );

  if (confirmExit == true) {
    final url = Uri.parse('https://parkware-ten.vercel.app/api/queue/leave');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': widget.uid,
        'qrCodes': jsonEncode([text]),
        'leave': true
      })
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print(responseBody);
      if (responseBody['success'] == true) {
        setState(() {
          _fetchQueueStatus();
        });
      } else {
        _showErrorDialog("Error al salir de la fila virtual");
      }
    } else {
      _showErrorDialog("Error en el servidor");
    }
  }
}

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  bool _isRideTimePassed(String rideTime) {
    final rideTimeOfDay = _parseTimeOfDay(rideTime);
    final now = TimeOfDay.now();

    if (rideTimeOfDay.hour < now.hour) {
      return true;
    } else if (rideTimeOfDay.hour == now.hour && rideTimeOfDay.minute < now.minute) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Estado de la Fila Virtual'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Usuarios en la fila:',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final remainingTime = user['timeRemaining'];
                          final rideTimeRemaining = user['rideTimeRemaining'];
                          final rideTime = user['rideTime'];

                          final minutesLeft = remainingTime.inMinutes;
                          final secondsLeft = remainingTime.inSeconds % 60;

                          final rideMinutesLeft = rideTimeRemaining.inMinutes;
                          final rideSecondsLeft = rideTimeRemaining.inSeconds % 60;

                          if (minutesLeft == 5) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _showFiveMinuteWarning(user['name']);
                            });
                          }

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  user['position'].toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                'Posición: ${user['position']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text(
                                    'Tiempo hasta el próximo paseo:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.timer, size: 18, color: Colors.grey),
                                      SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$rideMinutesLeft minutos',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            '$rideSecondsLeft segundos',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Tiempo hasta tu turno:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.hourglass_bottom, size: 18, color: Colors.grey),
                                      SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$minutesLeft minutos',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            '$secondsLeft segundos',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  if (_isRideTimePassed(rideTime))
                                    Text(
                                      'Tu tiempo ya pasó',
                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.exit_to_app, color: Colors.red),
                                onPressed: () {
                                  print(user['text']);
                                  _leaveQueue(user['text']);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Text('Volver al Menú'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
