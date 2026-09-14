import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:productcatalog/presentation/viewmodels/product_view_model.dart';
import 'package:productcatalog/presentation/views/product_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductViewModel(),
      child: MaterialApp(
        title: 'Product Catalog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        home: const ProductListScreen(),
      ),
    );
  }
}
