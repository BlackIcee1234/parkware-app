import 'package:flutter/material.dart';
import 'package:parkware/presentation/views/payment/payment_attraction_screen.dart';
import 'package:parkware/data/api_service.dart';

class TicketsDetailsPage extends StatefulWidget {
  final Map<String, dynamic> attraction;

  const TicketsDetailsPage({Key? key, required this.attraction}) : super(key: key);

  @override
  _TicketsDetailsPageState createState() => _TicketsDetailsPageState();
}

class _TicketsDetailsPageState extends State<TicketsDetailsPage> {
  int ticketsCount = 1;
  int totalPrice = 0;

  @override
  Widget build(BuildContext context) {
    int widgetTotal = widget.attraction['price'];
    totalPrice = ticketsCount * (widgetTotal * 100).toInt();
    final imageRef = widget.attraction['images'][0]['asset']['_ref'];
    String imageUrl = ApiService.getImageUrl(imageRef);

    bool isFree = widgetTotal <= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.attraction['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.attraction['description'],
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                isFree ? 'GRATIS' : '\$${widget.attraction['price'].toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isFree ? Colors.green : Colors.black,
                ),
              ),
            ),
            if (!isFree)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cantidad:',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (ticketsCount > 1) {
                              int widgetTotal = widget.attraction['price'];
                              setState(() {
                                ticketsCount--;
                                totalPrice = ticketsCount * (widgetTotal * 100).toInt();
                              });
                            }
                          },
                          icon: Icon(Icons.remove),
                        ),
                        Text(
                          ticketsCount.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            int widgetTotal = widget.attraction['price'];
                            setState(() {
                              ticketsCount++;
                              totalPrice = ticketsCount * (widgetTotal * 100).toInt();
                            });
                          },
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20),
            if (!isFree)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Total a pagar: \$${(totalPrice / 100).toStringAsFixed(2)} MXN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Aquí puedes implementar la lógica para pagar
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentPage(
                              totalPrice: totalPrice,
                              ticketCount: ticketsCount,
                              attraction: widget.attraction,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Pagar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
