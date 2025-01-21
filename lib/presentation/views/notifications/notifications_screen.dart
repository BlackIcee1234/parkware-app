import 'package:flutter/material.dart';

class Notification {
  final String title;
  final String body;

  Notification({required this.title, required this.body});

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      title: json['title'],
      body: json['body'],
    );
  }
}

class NotificationListPage extends StatelessWidget {
  final List<Notification> notifications = [
    Notification(
      title: '¡Oferta especial!',
      body: '¡Hoy tenemos descuentos del 50% en todos los productos! No te lo pierdas.',
    ),
    Notification(
      title: 'Recordatorio de evento',
      body: 'No olvides asistir a la reunión de equipo mañana a las 10:00 am.',
    ),
    Notification(
      title: 'Actualización de la aplicación',
      body: '¡Nueva versión disponible! Actualiza la aplicación para disfrutar de las últimas funciones.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.notifications),
            title: Text(notifications[index].title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationDetailsPage(notification: notifications[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationDetailsPage extends StatelessWidget {
  final Notification notification;

  NotificationDetailsPage({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Notificación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              notification.body,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
