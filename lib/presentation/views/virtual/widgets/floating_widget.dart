import 'package:flutter/material.dart';
import 'dart:async';
import 'package:parkware/controllers/user_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parkware/presentation/views/virtual/virtual_queue_status_page.dart';

class FloatingWidget extends StatefulWidget {
  @override
  _FloatingWidgetState createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget> {
  bool _showWidget = false;
  List<Map<String, dynamic>> _users = [];
  Timer? _timer;
  int _timeToNextRide = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
    Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchData();
    });
  }

void _fetchData() async {
  final response = await fetchQueueState();
  if (this.mounted) {
    if (response['success']) {
      setState(() {
        _users = List<Map<String, dynamic>>.from(response['queueState']['users']);
        if (_users.isNotEmpty) {
          _timeToNextRide = _parseTimeToSeconds(_users.first['timeUntilNextRemoval']);
          _startCountdown();
          _showWidget = true;
        } else {
          _showWidget = false;
        }
      });
    } else {
      setState(() {
        _showWidget = false;
      });
    }
  }
}


  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeToNextRide > 0) {
        setState(() {
          _timeToNextRide--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  int _parseTimeToSeconds(String time) {
    final parts = time.split(' ');
    final minutes = int.parse(parts[0]);
    final seconds = int.parse(parts[3]);
    return minutes * 60 + seconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showWidget
        ? Positioned(
            right: 16.0,
            top: 36.0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VirtualQueueStatusPage(uid: UserController.getCurrentUserUid())),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _users.map((user) {
                    final remainingTime = Duration(seconds: _timeToNextRide);
                    final minutes = remainingTime.inMinutes;
                    final seconds = remainingTime.inSeconds % 60;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Pos: ${user['position']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.timer, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${minutes}m ${seconds}s',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          )
        : Container();
  }
}

Future<Map<String, dynamic>> fetchQueueState() async {
  final response = await http.post(
    Uri.parse('https://parkware-ten.vercel.app/api/queue/status'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'uid': UserController.getCurrentUserUid(),
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al cargar el estado de la cola');
  }
}
