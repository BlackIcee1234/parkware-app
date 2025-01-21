import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parkware/config/constants/environment.dart';

class ApiService {
  static Future<Map<String, dynamic>> getAllProducts() async {
    final String sanityProjectId = Environment.sanityApiProjectId;
    final String token = Environment.sanityApiToken;
    final String apiUrl = 'https://${sanityProjectId}.api.sanity.io/v1/data/query/production?query=*[_type == "product"]';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al obtener el producto');
    }
  }

  static Future<Map<String, dynamic>> getAllAttractions() async {
    final String sanityProjectId = Environment.sanityApiProjectId;
    final String token = Environment.sanityApiToken;
    final String apiUrl = 'https://${sanityProjectId}.api.sanity.io/v1/data/query/production?query=*[_type == "attraction"]';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al obtener las atracciones');
    }
  }

  static Future<Map<String, dynamic>> getAllStores() async {
    final String sanityProjectId = Environment.sanityApiProjectId;
    final String dataset = Environment.sanityApiDataset;
    final String token = Environment.sanityApiToken;
    final String apiUrl = 'https://${sanityProjectId}.api.sanity.io/v1/data/query/${dataset}?query=*[_type == "store"]';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al obtener las tiendas');
    }
  }

  static Future<Map<String, dynamic>> getAllNews() async {
      final String sanityProjectId = Environment.sanityApiProjectId;
      final String dataset = Environment.sanityApiDataset;
      final String token = Environment.sanityApiToken;
      final String apiUrl = 'https://${sanityProjectId}.api.sanity.io/v1/data/query/${dataset}?query=*[_type == "news"]';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Error al obtener las noticias');
      }
    }

  static Future<Map<String, dynamic>> getDocumentById(String id) async {
    final String sanityProjectId = Environment.sanityApiProjectId;
    final String dataset = Environment.sanityApiDataset;
    final String token = Environment.sanityApiToken;
    final String apiUrl = 'https://${sanityProjectId}.api.sanity.io/v1/data/query/${dataset}?query=*[ _id == "${id}" ]';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al obtener el documento');
    }
  }

static String getImageUrl(String ref) {
    String baseUrl = "https://cdn.sanity.io/images/dnyl6kr0/production/";

    // Determinar la extensión de la imagen
    String extension = "";
    if (ref.contains("-jpg")) {
        extension = ".jpg";
    } else if (ref.contains("-webp")) {
        extension = ".webp";
    } else if (ref.contains("-png")) {
        extension = ".png";
    } // Agrega más extensiones según sea necesario

    // Reemplazar el texto según la extensión encontrada
    String imageUrl = ref.replaceAll("-jpg", extension)
                          .replaceAll("-webp", extension)
                          .replaceAll("-png", extension)
                          .replaceAll("image-", baseUrl);
    return imageUrl;
}
}
