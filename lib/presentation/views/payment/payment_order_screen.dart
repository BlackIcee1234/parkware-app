import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:parkware/domain/models/cart_item.dart';
import 'package:parkware/config/constants/environment.dart';
import 'package:parkware/presentation/views/order/order_details_screen.dart';
import 'package:parkware/controllers/user_controller.dart';

class PaymentPageCart extends StatefulWidget {
  final int totalPrice;
  final List<CartItem> cartItems;

  const PaymentPageCart({
    Key? key,
    required this.totalPrice,
    required this.cartItems,
  }) : super(key: key);

  @override
  _PaymentPageCartState createState() => _PaymentPageCartState();
}

class _PaymentPageCartState extends State<PaymentPageCart> {
  late GlobalKey<FormState> paymentForm;
  Map<String, dynamic>? paymentIntentData;
  final secretKey = Environment.stripeSecretKey;

  @override
  void initState() {
    super.initState();
    paymentForm = GlobalKey<FormState>();
    makePayment(
      totalPrice: widget.totalPrice,
      cartItems: widget.cartItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('\$${item.price.toStringAsFixed(2)} x ${item.quantity}'),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Resumen del Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Fecha: ${DateTime.now().toString()}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Productos:',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.cartItems.map((item) {
                return Text(
                  '${item.name} - \$${(item.price * item.quantity).toStringAsFixed(2)} x ${item.quantity}',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text(
              'Total: \$${(widget.totalPrice / 100).toStringAsFixed(2)} MXN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: displayPaymentSheet,
              child: Text('Pagar \$${(widget.totalPrice / 100).toStringAsFixed(2)} MXN'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment({
    required int totalPrice,
    required List<CartItem> cartItems,
  }) async {
    try {
      paymentIntentData = await createPaymentIntent(totalPrice);
      const gpay = PaymentSheetGooglePay(
        merchantCountryCode: "MX",
        testEnv: true,
      );
      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            googlePay: gpay,
            merchantDisplayName: 'Adiwele',
            paymentIntentClientSecret: paymentIntentData!['client_secret'],
            customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
          ),
        );
      }
    } catch (e, s) {
      debugPrint('exception:$e$s');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(int amount) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount.toString(),
        'currency': 'MXN',
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      );

      return jsonDecode(response.body.toString());
    } catch (e) {
      debugPrint(e.toString());
      throw e;
    }
  }

displayPaymentSheet() async {
  try {
    // Presentar el formulario de pago de Stripe
    await Stripe.instance.presentPaymentSheet().then(
      (value) {},
    );

    DateTime now = DateTime.now();
    final String uid = UserController.getCurrentUserUid();
    Map<String, dynamic> orderData = {
      'uid': uid,
      'date': now.toString(),
      'products': widget.cartItems.map((item) => item.toJson()).toList(), // Convertir los productos a JSON
      'total': widget.totalPrice,
    };

    // Hacer la solicitud POST a la API
    var response = await http.post(
      Uri.parse('https://parkware-ten.vercel.app/api/purchases/create'), // Reemplaza 'URL_DE_TU_API' con la URL de tu API
      body: jsonEncode(orderData),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      DateTime dateTime = DateTime.parse(jsonDecode(response.body)['date']);
      String formattedDateTime = '${dateTime.year}-${_addLeadingZero(dateTime.month)}-${_addLeadingZero(dateTime.day)} ${_addLeadingZero(dateTime.hour)}:${_addLeadingZero(dateTime.minute)}:${_addLeadingZero(dateTime.second)}';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderView(
            orderId: jsonDecode(response.body)['orderNumber'].toString(),
            status: 'Orden Realizada',
            date: formattedDateTime,
            totalAmount: widget.totalPrice,
          ),
        ),
      );
    } else {
      debugPrint('Error al crear la orden: ${response.body}');
    }
  } on StripeException catch (e) {
    debugPrint('Error de pago: ${e.error.localizedMessage}');
  } catch (e) {
    debugPrint('Se produjo un error inesperado: $e');
  }
}

  String _addLeadingZero(int value) {
    return value < 10 ? '0$value' : '$value';
  }

  String _addMicroseconds(int value) {
    String micros = value.toString();
    if (micros.length < 6) {
      // Añadir ceros a la izquierda si es necesario
      micros = '0' * (6 - micros.length) + micros;
    }
    return micros;
  }

  String _getMonthName(int month) {
  switch (month) {
    case 1:
      return 'Enero';
    case 2:
      return 'Febrero';
    case 3:
      return 'Marzo';
    case 4:
      return 'Abril';
    case 5:
      return 'Mayo';
    case 6:
      return 'Junio';
    case 7:
      return 'Julio';
    case 8:
      return 'Agosto';
    case 9:
      return 'Septiembre';
    case 10:
      return 'Octubre';
    case 11:
      return 'Noviembre';
    case 12:
      return 'Diciembre';
    default:
      return '';
  }
}
}
