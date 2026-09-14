import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:productcatalog/data/app_exception.dart';

class ProductApiService {
  static const String _host = 'dummyjson.com';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  ProductApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchProducts(int limit, int skip) {
    return _getJson(Uri.https(_host, '/products', {
      'limit': '$limit',
      'skip': '$skip',
    }));
  }

  Future<Map<String, dynamic>> fetchProductById(int id) {
    return _getJson(Uri.https(_host, '/products/$id'));
  }

  Future<Map<String, dynamic>> searchProducts(String query) {
    return _getJson(Uri.https(_host, '/products/search', {'q': query}));
  }

  Future<List<dynamic>> fetchCategories() async {
    return _get(Uri.https(_host, '/products/categories'), (body) {
      final decoded = json.decode(body);
      if (decoded is! List) {
        throw const AppException('Unexpected response format', AppErrorKind.server);
      }
      return decoded;
    });
  }

  Future<Map<String, dynamic>> fetchProductsByCategory(String slug) {
    return _getJson(Uri.https(_host, '/products/category/$slug'));
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) {
    return _get(uri, (body) {
      final decoded = json.decode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const AppException('Unexpected response format', AppErrorKind.server);
      }
      return decoded;
    });
  }

  Future<T> _get<T>(Uri uri, T Function(String body) parse) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw AppException(
          'Server returned ${response.statusCode}',
          AppErrorKind.server,
        );
      }
      return parse(response.body);
    } on SocketException {
      throw const AppException(
        'No internet connection. Check your network and try again.',
        AppErrorKind.network,
      );
    } on http.ClientException catch (e) {
      final msg = e.message.toLowerCase();
      final isNetwork = msg.contains('failed host lookup') ||
          msg.contains('network is unreachable') ||
          msg.contains('connection refused') ||
          msg.contains('connection closed');
      throw AppException(
        isNetwork
            ? 'No internet connection. Check your network and try again.'
            : 'Something went wrong. Please try again.',
        isNetwork ? AppErrorKind.network : AppErrorKind.unknown,
      );
    } on TimeoutException {
      throw const AppException(
        'The request timed out. Please try again.',
        AppErrorKind.timeout,
      );
    } on FormatException {
      throw const AppException(
        'Unexpected response format.',
        AppErrorKind.server,
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        'Something went wrong. Please try again.',
        AppErrorKind.unknown,
      );
    }
  }
}
