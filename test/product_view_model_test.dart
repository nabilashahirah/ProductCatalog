import 'package:flutter_test/flutter_test.dart';
import 'package:productcatalog/presentation/viewmodels/product_view_model.dart';

void main() {
  late ProductViewModel viewModel;

  setUp(() {
    viewModel = ProductViewModel();
  });

  group('ProductViewModel', () {
    test('initial state should be correct', () {
      expect(viewModel.products, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.hasMore, true);
      expect(viewModel.searchQuery, '');
      expect(viewModel.selectedCategory, isNull);
      expect(viewModel.isEmpty, true);
    });

    test('fetchProducts loads 20 products from the live API', () async {
      await viewModel.fetchProducts();

      expect(viewModel.products.length, 20);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.hasMore, true);
    });

    test('loadMoreProducts appends the next page', () async {
      await viewModel.fetchProducts();
      final initial = viewModel.products.length;

      await viewModel.loadMoreProducts();

      expect(viewModel.products.length, greaterThan(initial));
      expect(viewModel.isLoadingMore, false);
    });

    test('onSearchChanged updates the query', () {
      viewModel.onSearchChanged('phone');
      expect(viewModel.searchQuery, 'phone');
    });

    test('fetchCategories loads categories', () async {
      await viewModel.fetchCategories();
      expect(viewModel.categories, isNotEmpty);
    });
  });
}
