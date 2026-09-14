import 'dart:async';
import 'package:flutter/material.dart';
import 'package:productcatalog/data/models/product.dart';
import 'package:productcatalog/data/repositories/product_repository.dart';

class ProductViewModel extends ChangeNotifier {
  ProductViewModel({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;

  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _paginationErrorMessage;
  bool _hasMore = true;
  int _skip = 0;
  int _total = 0;
  String _searchQuery = '';
  Timer? _debounceTimer;
  Future<void> Function()? _lastFailedAction;

  static const int _limit = 20;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String? get paginationErrorMessage => _paginationErrorMessage;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  bool get isEmpty => !_isLoading && _errorMessage == null && _products.isEmpty;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    _paginationErrorMessage = null;
    notifyListeners();

    try {
      _skip = 0;
      final response = await _repository.getProducts(_limit, _skip);
      _products = response.products;
      _total = response.total;
      _hasMore = _products.length < _total;
      _lastFailedAction = null;
    } catch (_) {
      _errorMessage = 'Failed to load products. Please try again.';
      _lastFailedAction = fetchProducts;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    _paginationErrorMessage = null;
    notifyListeners();

    try {
      _skip += _limit;
      final response = await _repository.getProducts(_limit, _skip);
      _products.addAll(response.products);
      _hasMore = _products.length < _total;
      _lastFailedAction = null;
    } catch (_) {
      _skip -= _limit;
      _paginationErrorMessage = 'Failed to load more.';
      _lastFailedAction = loadMoreProducts;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      fetchProducts();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchProducts(query);
    });
  }

  Future<void> _searchProducts(String query) async {
    _isLoading = true;
    _errorMessage = null;
    _paginationErrorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.searchProducts(query);
      _products = response.products;
      _total = response.total;
      _hasMore = false;
      _lastFailedAction = null;
    } catch (_) {
      _errorMessage = 'Failed to search products. Please try again.';
      _lastFailedAction = () => _searchProducts(query);
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
