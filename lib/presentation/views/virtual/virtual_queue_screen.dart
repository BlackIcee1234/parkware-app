import 'package:flutter/material.dart';
import 'package:parkware/presentation/views/virtual/virtual_queue_registration_screen.dart';
import 'package:parkware/domain/models/attraction.dart';

class VirtualQueuePage extends StatefulWidget {
  final List<Attraction> attractions; // Lista de atracciones disponibles

  const VirtualQueuePage({Key? key, required this.attractions}) : super(key: key);

  @override
  _VirtualQueuePageState createState() => _VirtualQueuePageState();
}

class _VirtualQueuePageState extends State<VirtualQueuePage> {
  Attraction? selectedAttraction; // Atracción seleccionada
  int selectedPersonsCount = 1; // Número de personas seleccionado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car),
            SizedBox(width: 10),
            Text('Filas Virtuales en el Safari', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    '¡Bienvenido al Safari Virtual!',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Selecciona una atracción:',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.attractions.length,
                    itemBuilder: (context, index) {
                      final attraction = widget.attractions[index];
                      return Card(
                        elevation: 3,
                        child: ListTile(
                          leading: Icon(Icons.directions_car),
                          title: Text(attraction.name),
                          subtitle: Text('Precio: \$${attraction.price.toStringAsFixed(2)}'),
                          onTap: () {
                            setState(() {
                              selectedAttraction = attraction;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (selectedAttraction != null) ...[
              SizedBox(height: 20),
              Text(
                'Selecciona la cantidad de personas:',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (selectedPersonsCount > 1) {
                          selectedPersonsCount--;
                        }
                      });
                    },
                    icon: Icon(Icons.remove_circle, size: 36),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '$selectedPersonsCount',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (selectedPersonsCount < 5) {
                          selectedPersonsCount++;
                        }
                      });
                    },
                    icon: Icon(Icons.add_circle, size: 36),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Navegar a la página de registro de fila virtual
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VirtualQueueRegistrationPage(
                      attraction: selectedAttraction!,
                      personsCount: selectedPersonsCount,
                    )),
                  );
                },
                icon: Icon(Icons.directions_walk, size: 30),
                label: Text(
                  '¡Vamos al Safari!',
                  style: TextStyle(fontSize: 24),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
