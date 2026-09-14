import 'dart:async';
import 'package:flutter/material.dart';
import 'package:productcatalog/data/app_exception.dart';
import 'package:productcatalog/data/models/product.dart';
import 'package:productcatalog/data/repositories/product_repository.dart';

class ProductViewModel extends ChangeNotifier {
  ProductViewModel({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;

  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  AppErrorKind? _errorKind;
  String? _paginationErrorMessage;
  bool _hasMore = true;
  int _skip = 0;
  int _total = 0;
  String _searchQuery = '';
  String? _selectedCategory;
  double _minRating = 0;
  RangeValues? _priceRange;
  Timer? _debounceTimer;
  Future<void> Function()? _lastFailedAction;

  static const int _limit = 20;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  AppErrorKind? get errorKind => _errorKind;
  String? get paginationErrorMessage => _paginationErrorMessage;
  bool get hasMore => _hasMore;
  int get total => _total;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  double get minRating => _minRating;
  RangeValues? get priceRange => _priceRange;

  List<Product> get filteredProducts {
    if (_minRating == 0 && _priceRange == null) return _products;
    return _products.where((p) {
      if (p.rating < _minRating) return false;
      if (_priceRange != null) {
        if (p.price < _priceRange!.start) return false;
        if (p.price > _priceRange!.end) return false;
      }
      return true;
    }).toList();
  }

  double get maxLoadedPrice {
    if (_products.isEmpty) return 100;
    return _products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
  }

  int get activeFilterCount {
    var n = 0;
    if (_selectedCategory != null) n++;
    if (_minRating > 0) n++;
    if (_priceRange != null) n++;
    return n;
  }

  bool get isEmpty => !_isLoading && _errorMessage == null && _products.isEmpty;

  bool get isFilteredEmpty =>
      !_isLoading &&
      _errorMessage == null &&
      _products.isNotEmpty &&
      filteredProducts.isEmpty;

  void setMinRating(double rating) {
    if (_minRating == rating) return;
    _minRating = rating;
    notifyListeners();
  }

  void setPriceRange(RangeValues? range) {
    _priceRange = range;
    notifyListeners();
  }

  void _setError(Object e) {
    if (e is AppException) {
      _errorMessage = e.message;
      _errorKind = e.kind;
    } else {
      _errorMessage = 'Something went wrong. Please try again.';
      _errorKind = AppErrorKind.unknown;
    }
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    _errorKind = null;
    _paginationErrorMessage = null;
    notifyListeners();

    try {
      _skip = 0;
      final response = await _repository.getProducts(_limit, _skip);
      _products = response.products;
      _total = response.total;
      _hasMore = _products.length < _total;
      _lastFailedAction = null;
    } catch (e) {
      _setError(e);
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
    } catch (e) {
      _skip -= _limit;
      _paginationErrorMessage = e is AppException && e.kind == AppErrorKind.network
          ? 'No internet — couldn\'t load more.'
          : 'Failed to load more.';
      _lastFailedAction = loadMoreProducts;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (_) {
      // Non-critical
    }
  }

  Future<void> selectCategory(String? categorySlug) async {
    if (_selectedCategory == categorySlug) return;
    _selectedCategory = categorySlug;
    _searchQuery = '';

    if (categorySlug == null) {
      await fetchProducts();
    } else {
      await _fetchProductsByCategory(categorySlug);
    }
  }

  Future<void> _fetchProductsByCategory(String categorySlug) async {
    _isLoading = true;
    _errorMessage = null;
    _errorKind = null;
    _paginationErrorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getProductsByCategory(categorySlug);
      _products = response.products;
      _total = response.total;
      _hasMore = false;
      _lastFailedAction = null;
    } catch (e) {
      _setError(e);
      _lastFailedAction = () => _fetchProductsByCategory(categorySlug);
    }

    _isLoading = false;
    notifyListeners();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _selectedCategory = null;
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
    _errorKind = null;
    _paginationErrorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.searchProducts(query);
      _products = response.products;
      _total = response.total;
      _hasMore = false;
      _lastFailedAction = null;
    } catch (e) {
      _setError(e);
      _lastFailedAction = () => _searchProducts(query);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    if (_selectedCategory != null) {
      await _fetchProductsByCategory(_selectedCategory!);
    } else if (_searchQuery.isNotEmpty) {
      await _searchProducts(_searchQuery);
    } else {
      await fetchProducts();
    }
  }

  Future<AppErrorKind?> tryRefresh() async {
    await refreshProducts();
    final kind = _errorKind;
    if (kind != null && _products.isNotEmpty) {
      _errorMessage = null;
      _errorKind = null;
      notifyListeners();
      return kind;
    }
    return null;
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
