import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductApiService {
  static const String _host = 'dummyjson.com';

  final http.Client _client;

  ProductApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchProducts(int limit, int skip) async {
    return _getJson(
      Uri.https(_host, '/products', {
        'limit': '$limit',
        'skip': '$skip',
      }),
      'Failed to load products',
    );
  }

  Future<Map<String, dynamic>> fetchProductById(int id) async {
    return _getJson(
      Uri.https(_host, '/products/$id'),
      'Failed to load product details',
    );
  }

  Future<Map<String, dynamic>> searchProducts(String query) async {
    return _getJson(
      Uri.https(_host, '/products/search', {'q': query}),
      'Failed to search products',
    );
  }

  Future<List<dynamic>> fetchCategories() async {
    final response = await _client.get(Uri.https(_host, '/products/categories'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load categories');
    }
    return json.decode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> fetchProductsByCategory(String categorySlug) async {
    return _getJson(
      Uri.https(_host, '/products/category/$categorySlug'),
      'Failed to load products by category',
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri, String errorMessage) async {
    final response = await _client.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception(errorMessage);
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }
}
