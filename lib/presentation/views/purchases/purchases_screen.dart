import 'package:flutter/material.dart';
import 'package:parkware/controllers/user_controller.dart';
import 'package:parkware/data/api_backend.dart';
import 'package:parkware/presentation/views/purchases/purchase_detail_screen.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  late Future<List<dynamic>> myOrdersFuture;

  @override
  void initState() {
    super.initState();
    myOrdersFuture = _fetchMyOrders();
  }

  Future<List<dynamic>> _fetchMyOrders() async {
    try {
      final String uid = UserController.getCurrentUserUid();
      final response = await ApiBackend.getMyPurchases(uid);
      return response;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<void> _refreshMyOrders() async {
    setState(() {
      myOrdersFuture = _fetchMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Compras'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: myOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay pedidos disponibles'));
          } else {
            return RefreshIndicator(
              onRefresh: _refreshMyOrders,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final order = snapshot.data![index];
                  final orderId = order['orderNumber'];
                  final timestamp = order['date'];
                  DateTime dateTime = DateTime.parse(timestamp);
                  String formattedDateTime = '${dateTime.year}-${_addLeadingZero(dateTime.month)}-${_addLeadingZero(dateTime.day)} ${_addLeadingZero(dateTime.hour)}:${_addLeadingZero(dateTime.minute)}:${_addLeadingZero(dateTime.second)}';
                  return ListTile(
                    leading: Icon(Icons.shopping_bag),
                    title: Text('Order $orderId'),
                    subtitle: Text('Fecha: $formattedDateTime'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderDetailPage(order: order)),
                      );
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  String _addLeadingZero(int value) {
    return value < 10 ? '0$value' : '$value';
  }
}

