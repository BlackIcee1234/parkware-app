import 'package:flutter/material.dart';
import 'package:parkware/presentation/views/order/order_screen.dart';
import 'package:parkware/domain/models/attraction.dart';
import 'package:parkware/presentation/views/virtual/virtual_queue_screen.dart';
import 'package:parkware/presentation/views/tickets/tickets_screen.dart';
import 'package:parkware/presentation/views/main/main_screen.dart';
import 'package:parkware/presentation/views/profile/profile_screen.dart';
import 'package:parkware/presentation/views/virtual/widgets/floating_widget.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Attraction> attractions = [
    Attraction(
      name: 'Safari',
      description: '¡La montaña rusa más emocionante del parque!',
      price: 85.0,
      imageUrls: [
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT1Nac1qpiTKtycdCWnT5lXbnb4jWTF8-6dxMrd-4X5og&s',
        'https://cloudfront-us-east-1.images.arcpublishing.com/infobae/XDEH2GVAB5B4XNFTEH7SRSV754.jpg',
        'https://chulavista.mx/wp-content/uploads/2013/08/feria-de-chapultepec.jpg',
      ],
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      MainPage(),
      OrderPage(),
      VirtualQueuePage(attractions: attractions),
      TicketsPage(),
      ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        //title: const Text('Parkware'),
      ),
      body: Stack(
        children: [
          Center(
            child: IndexedStack(
              index: _selectedIndex,
              children: _widgetOptions,
            ),
          ), FloatingWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 30),
            label: 'Virtual Queue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
