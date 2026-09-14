import 'package:flutter/material.dart';
import 'package:productcatalog/data/models/product.dart';
import 'package:productcatalog/data/repositories/product_repository.dart';

class ProductViewModel extends ChangeNotifier {
  ProductViewModel({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  Future<void> Function()? _lastFailedAction;

  static const int _limit = 20;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isEmpty => !_isLoading && _errorMessage == null && _products.isEmpty;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getProducts(_limit, 0);
      _products = response.products;
      _lastFailedAction = null;
    } catch (_) {
      _errorMessage = 'Failed to load products. Please try again.';
      _lastFailedAction = fetchProducts;
    }

    _isLoading = false;
    notifyListeners();
  }

  void retry() {
    final action = _lastFailedAction;
    if (action == null) return;
    _lastFailedAction = null;
    action();
  }
}
