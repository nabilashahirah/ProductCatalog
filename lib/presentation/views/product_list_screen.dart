import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:productcatalog/presentation/viewmodels/product_view_model.dart';
import 'package:productcatalog/presentation/widgets/product_card.dart';
import 'package:productcatalog/presentation/widgets/loading_view.dart';
import 'package:productcatalog/presentation/widgets/error_view.dart';
import 'package:productcatalog/presentation/widgets/empty_view.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        context.read<ProductViewModel>().fetchProducts();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ProductViewModel>().loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _searchController,
              onChanged: viewModel.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: viewModel.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(child: _buildContent(viewModel)),
        ],
      ),
    );
  }

  Widget _buildContent(ProductViewModel viewModel) {
    if (viewModel.isLoading) {
      return const LoadingView();
    }

    if (viewModel.errorMessage != null && viewModel.products.isEmpty) {
      return ErrorView(
        message: viewModel.errorMessage!,
        onRetry: viewModel.retry,
      );
    }

    if (viewModel.isEmpty) {
      return const EmptyView();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: viewModel.products.length + (viewModel.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.products.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final product = viewModel.products[index];
        return ProductCard(
          product: product,
          onTap: () {
            // detail screen next stage
          },
        );
      },
    );
  }
}
