import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:productcatalog/presentation/viewmodels/product_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductViewModel()..fetchProducts(),
      child: MaterialApp(
        title: 'Product Catalog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(title: const Text('Product Catalog')),
          body: Consumer<ProductViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (vm.errorMessage != null) {
                return Center(child: Text(vm.errorMessage!));
              }
              return Center(
                child: Text('Loaded ${vm.products.length} products'),
              );
            },
          ),
        ),
      ),
    );
  }
}
