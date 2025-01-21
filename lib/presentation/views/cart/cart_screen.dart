import 'package:flutter/material.dart';
import 'package:parkware/presentation/views/payment/payment_order_screen.dart';
import 'package:parkware/domain/models/cart_item.dart';
import './widgets/cart_item_widget.dart';
import './widgets/total_amount_widget.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(List<CartItem>) onCartUpdated;

  const CartScreen({Key? key, required this.cartItems, required this.onCartUpdated})
      : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito de Compras'),
      ),
      body: ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          return CartItemWidget(
            item: item,
            onQuantityUpdated: (newQuantity) {
              updateQuantity(index, newQuantity);
            },
            onRemove: () {
              removeFromCart(index);
            },
          );
        },
      ),
      floatingActionButton: totalAmount == 0
          ? null // Si el total es 0, el botón desaparece
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPageCart(
                      cartItems: widget.cartItems,
                      totalPrice: totalAmount.toInt() * 100,
                    ),
                  ),
                );
              },
              label: Text('Pagar'),
              icon: Icon(Icons.payment),
            ),
      bottomNavigationBar: TotalAmountWidget(totalAmount: totalAmount),
    );
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(index);
    } else {
      setState(() {
        widget.cartItems[index].quantity = newQuantity;
        widget.onCartUpdated(widget.cartItems);
      });
    }
  }

  void removeFromCart(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
      widget.onCartUpdated(widget.cartItems);
    });
  }

  double get totalAmount {
    return widget.cartItems.fold(0, (total, item) => total + (item.price * item.quantity));
  }
}
