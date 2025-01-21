import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parkware/data/api_service.dart';
import 'package:parkware/domain/models/cart_item.dart';
import 'package:parkware/presentation/views/cart/cart_screen.dart';

class LimitedText extends StatelessWidget {
  final String description;
  final int wordLimit;

  LimitedText(this.description, {required this.wordLimit});

  @override
  Widget build(BuildContext context) {
    List<String> words = description.split(' ');
    String truncatedText = words.take(wordLimit).join(' ');

    return Text(truncatedText);
  }
}

class CatalogInfo {
  final String catalogName;
  final List<String> productRefs;

  CatalogInfo(this.catalogName, this.productRefs);
}

class StorePage extends StatefulWidget {
  final String storeName;
  final String id;
  final List<String> catalogsId;

  const StorePage({Key? key, required this.storeName, required this.catalogsId, required this.id }) : super(key: key);

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  List<CartItem> cartItems = [];
  List<dynamic> products = [];
  List<CatalogInfo> catalogInfoList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final productos = await ApiService.getAllProducts();
      setState(() {
        products = productos['result'];
      });
      await _fetchCatalogs();
    } catch (e) {
      print('Error al obtener datos: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCatalogs() async {
    catalogInfoList.clear();
    for (String catalogId in widget.catalogsId) {
      final Map<String, dynamic> catalog = await ApiService.getDocumentById(catalogId);
      String catalogName = catalog['result'][0]['name']['es_es'];
      List<dynamic> products = catalog['result'][0]['products'];
      List<String> productRefs = [];
      for (dynamic product in products) {
        productRefs.add(product['_ref']);
      }
      catalogInfoList.add(CatalogInfo(catalogName, productRefs));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calcular la cantidad total de elementos en el carrito
    int cartTotalItems = cartItems.fold(0, (total, item) => total + item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeName),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen(cartItems: cartItems, onCartUpdated: _updateCart)),
                  );
                },
                icon: Icon(Icons.shopping_cart),
              ),
              if (cartTotalItems > 0) // Mostrar el número de elementos en un círculo
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartTotalItems > 99 ? '99+' : cartTotalItems.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _buildCatalogSection(),
    );
  }

  Widget _buildCatalogSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView.builder(
          itemCount: catalogInfoList.length,
          itemBuilder: (context, index) {
            final catalogInfo = catalogInfoList[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    catalogInfo.catalogName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: products.map<Widget>((product) {
                      bool belongsToCatalog = catalogInfo.productRefs.contains(product['_id']);
                      if (belongsToCatalog) {
                        double price = double.parse(product['price']);
                        String imageRef = product['image']['asset']['_ref'];
                        String imageUrl = ApiService.getImageUrl(imageRef);
                        return _buildProductItem(
                          product['name']['es_es'],
                          price,
                          imageUrl,
                          product['description']['es_es'],
                        );
                      } else {
                        return SizedBox();
                      }
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductItem(String name, double price, String imageUrl, String description) {
    return GestureDetector(
      onTap: () {
        _showProductDetails(name, price, imageUrl, description);
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('\$${price.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(String name, double price, String imageUrl, String description) {
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 10),
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  LimitedText(
                    description,
                    wordLimit: 20,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) {
                              quantity--;
                            }
                          });
                        },
                      ),
                      Text(quantity.toString()),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addToCart(name, price, quantity, imageUrl);
                      Navigator.pop(context);
                      showToast(name, price, quantity);
                    },
                    child: Text('Agregar al carrito'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showToast(String itemName, double itemPrice, int quantity) {
    String message = 'Se agregaron $quantity de $itemName';
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void addToCart(String itemName, double itemPrice, int quantity, String imageUrl) {
    setState(() {
      cartItems.add(CartItem(name: itemName, price: itemPrice, quantity: quantity, imageUrl: imageUrl));
    });
  }

  void _updateCart(List<CartItem> updatedCart) {
    setState(() {
      cartItems = updatedCart;
    });
  }
}
