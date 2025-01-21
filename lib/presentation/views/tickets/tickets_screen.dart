import 'package:flutter/material.dart';
import 'package:parkware/presentation/views/tickets/tickets_details_screen.dart'; 
import 'package:parkware/data/api_service.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({Key? key}) : super(key: key);

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  List<dynamic> attractions = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAttractions();
  }

  Future<void> _fetchAttractions() async {
    setState(() {
      isLoading = true;
    });
    try {
      final Map<String, dynamic> productos = await ApiService.getAllAttractions();
      setState(() {
        attractions = productos['result'];
      });
    } catch (e) {
      print('Error al obtener productos: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAttractions, // Agrega la función de actualizar
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Muestra el indicador de carga
            : ListView.builder(
                itemCount: attractions.length,
                itemBuilder: (context, index) {
                  final attraction = attractions[index];
                  final imageRef = attraction['images'][0]['asset']['_ref']; // Obtener la URL de la imagen
                  String imageUrl = ApiService.getImageUrl(imageRef);
                  final price = attraction['price']; // Obtener el precio

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TicketsDetailsPage(attraction: attractions[index])),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TicketsDetailsPage(attraction: attraction)),
                              );
                            },
                            child: Text('Ver Detalles del: ${attraction['name']}'), // Mostrar el nombre de la atracción
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            color: Colors.black54,
                            child: Text(
                              price <= 0 ? 'Gratis' : '\$$price', // Mostrar el precio
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
