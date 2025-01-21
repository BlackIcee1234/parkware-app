import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiBackend {
  static Future<List<dynamic>> getMyPurchases(String uid) async {
    const String apiUrl = 'https://parkware-ten.vercel.app/api/purchases/my-purchases';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'uid': uid}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al obtener las compras');
    }
  }
}
