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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ProductViewModel>().fetchProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
      ),
      body: _buildContent(viewModel),
    );
  }

  Widget _buildContent(ProductViewModel viewModel) {
    if (viewModel.isLoading) {
      return const LoadingView();
    }

    if (viewModel.errorMessage != null) {
      return ErrorView(
        message: viewModel.errorMessage!,
        onRetry: viewModel.retry,
      );
    }

    if (viewModel.isEmpty) {
      return const EmptyView();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: viewModel.products.length,
      itemBuilder: (context, index) {
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
