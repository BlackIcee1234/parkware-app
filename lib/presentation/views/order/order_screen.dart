import 'package:flutter/material.dart';
import 'package:parkware/presentation/views/store/store_screen.dart';
import 'package:parkware/data/api_service.dart';
import 'package:parkware/domain/models/store.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late List<Store> stores;
  Store? selectedStore;
  bool isLoading = false; // Variable para controlar el estado de carga

  @override
  void initState() {
    super.initState();
    stores = [];
    selectedStore = null;
    _fetchStores();
  }

  Future<void> _fetchStores() async {
    setState(() {
      isLoading = true; // Inicia la carga
    });
    try {
      Map<String, dynamic> fetchedStores = await ApiService.getAllStores();
      setState(() {
        stores = (fetchedStores['result'] as List<dynamic>)
            .map((storeData) => Store.fromJson(storeData))
            .toList();
        isLoading = false; // Finaliza la carga cuando se obtienen los datos
      });
    } catch (e) {
      print('Error en el fetch: $e');
      setState(() {
        isLoading = false; // Finaliza la carga en caso de error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ordena'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStores,
        child: isLoading
            ? _buildLoadingIndicator() // Si está cargando, muestra el indicador de carga
            : ListView.builder( // Si no está cargando, muestra la lista de tiendas
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  return _buildStoreItem(stores[index]);
                },
              ),
      ),
      floatingActionButton: selectedStore != null && selectedStore!.available
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StorePage(storeName: selectedStore!.name,catalogsId: selectedStore!.catalogs, id: selectedStore!.id, )),
                );
              },
              child: Icon(Icons.shopping_cart),
            )
          : null,
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(), // Muestra un indicador de carga centrado
    );
  }

  Widget _buildStoreItem(Store store) {
    return ListTile(
      onTap: () {
        setState(() {
          selectedStore = selectedStore == store ? null : store;
        });
      },
      title: Text(store.name),
      subtitle: Text(store.available ? 'Abierta' : 'Cerrada'),
      leading: Icon(
        store.available ? Icons.store : Icons.store_outlined,
        color: store.available ? Colors.green : Colors.red,
      ),
      selected: selectedStore == store,
      selectedTileColor: Colors.blue[100],
    );
  }
}
