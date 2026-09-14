import 'package:flutter_test/flutter_test.dart';
import 'package:productcatalog/data/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('parses a full product from JSON', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'description': 'A test product description',
        'price': 29.99,
        'rating': 4.5,
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': [
          'https://example.com/img1.jpg',
          'https://example.com/img2.jpg',
        ],
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'Test Product');
      expect(product.description, 'A test product description');
      expect(product.price, 29.99);
      expect(product.rating, 4.5);
      expect(product.thumbnail, 'https://example.com/thumb.jpg');
      expect(product.images.length, 2);
    });

    test('handles integer price and rating as double', () {
      final json = {
        'id': 2,
        'title': 'Integer Price Product',
        'description': 'Description',
        'price': 10,
        'rating': 4,
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': ['https://example.com/img1.jpg'],
      };

      final product = Product.fromJson(json);

      expect(product.price, 10.0);
      expect(product.rating, 4.0);
    });
  });

  group('ProductResponse.fromJson', () {
    test('parses response with pagination fields', () {
      final json = {
        'products': [
          {
            'id': 1,
            'title': 'Product 1',
            'description': 'Description 1',
            'price': 9.99,
            'rating': 4.5,
            'thumbnail': 'https://example.com/thumb1.jpg',
            'images': ['https://example.com/img1.jpg'],
          },
        ],
        'total': 194,
        'skip': 0,
        'limit': 20,
      };

      final response = ProductResponse.fromJson(json);

      expect(response.products.length, 1);
      expect(response.total, 194);
      expect(response.skip, 0);
      expect(response.limit, 20);
    });

    test('handles empty product list', () {
      final json = {
        'products': [],
        'total': 0,
        'skip': 0,
        'limit': 20,
      };

      final response = ProductResponse.fromJson(json);

      expect(response.products, isEmpty);
      expect(response.total, 0);
    });
  });
}
