import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:productcatalog/data/app_exception.dart';
import 'package:productcatalog/presentation/viewmodels/product_view_model.dart';
import 'package:productcatalog/presentation/views/product_detail_screen.dart';
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
        final viewModel = context.read<ProductViewModel>();
        viewModel.fetchProducts();
        viewModel.fetchCategories();
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

  Future<void> _onRefresh(ProductViewModel viewModel) async {
    await viewModel.tryRefresh();
  }

  void _openFilterSheet(ProductViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterSheet(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductViewModel>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Catalog')),
      body: Column(
        children: [
          if (viewModel.bannerKind != null)
            _OfflineBanner(
              kind: viewModel.bannerKind!,
              onRetry: () => _onRefresh(viewModel),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
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
              ),
            ),
          ),
          if (viewModel.products.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
              child: Row(
                children: [
                  Text(
                    'Showing ${viewModel.filteredProducts.length} of ${viewModel.total}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  _FilterButton(
                    badgeCount: viewModel.activeFilterCount,
                    onTap: () => _openFilterSheet(viewModel),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildContent(viewModel)),
        ],
      ),
    );
  }

  Widget _buildContent(ProductViewModel viewModel) {
    if (viewModel.isLoading) return const LoadingView();

    if (viewModel.errorMessage != null && viewModel.products.isEmpty) {
      return ErrorView(
        message: viewModel.errorMessage!,
        kind: viewModel.errorKind,
        onRetry: viewModel.retry,
      );
    }

    if (viewModel.isEmpty) return const EmptyView();
    if (viewModel.isFilteredEmpty) return const EmptyView();

    final visible = viewModel.filteredProducts;

    return RefreshIndicator(
      onRefresh: () => _onRefresh(viewModel),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = visible[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                },
                childCount: visible.length,
              ),
            ),
          ),
          if (viewModel.hasMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final AppErrorKind kind;
  final VoidCallback onRetry;
  const _OfflineBanner({required this.kind, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final message = switch (kind) {
      AppErrorKind.network => 'No internet connection',
      AppErrorKind.timeout => 'Request timed out',
      AppErrorKind.server => 'Server unreachable',
      AppErrorKind.unknown => 'Connection issue',
    };
    return Material(
      color: const Color(0xFFB8342A),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int badgeCount;
  final VoidCallback onTap;
  const _FilterButton({required this.badgeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = badgeCount > 0;

    return Material(
      color: active ? scheme.primary : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: active ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded,
                  size: 18, color: active ? Colors.white : scheme.onSurface),
              const SizedBox(width: 6),
              Text(
                'Filter',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : scheme.onSurface,
                ),
              ),
              if (active) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final ProductViewModel viewModel;
  const _FilterSheet({required this.viewModel});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _draftCategory;
  late double _draftRating;
  late RangeValues _draftPrice;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    _draftCategory = widget.viewModel.selectedCategory;
    _draftRating = widget.viewModel.minRating;
    _maxPrice = widget.viewModel.maxLoadedPrice.ceilToDouble().clamp(50, 100000);
    _draftPrice = widget.viewModel.priceRange ?? RangeValues(0, _maxPrice);
  }

  void _apply() {
    final vm = widget.viewModel;
    if (vm.selectedCategory != _draftCategory) {
      vm.selectCategory(_draftCategory);
    }
    vm.setMinRating(_draftRating);
    final isDefaultPrice =
        _draftPrice.start == 0 && _draftPrice.end == _maxPrice;
    vm.setPriceRange(isDefaultPrice ? null : _draftPrice);
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _draftCategory = null;
      _draftRating = 0;
      _draftPrice = RangeValues(0, _maxPrice);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, color: scheme.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Filters',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    TextButton(onPressed: _reset, child: const Text('Reset')),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    const Text('Category',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _draftCategory == null,
                          onSelected: (_) => setState(() => _draftCategory = null),
                        ),
                        ...widget.viewModel.categories.map(
                          (c) => ChoiceChip(
                            label: Text(c.name),
                            selected: _draftCategory == c.slug,
                            onSelected: (_) =>
                                setState(() => _draftCategory = c.slug),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Minimum rating',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          _draftRating == 0
                              ? 'Any'
                              : '${_draftRating.toStringAsFixed(1)} & up',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Slider(
                      value: _draftRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      onChanged: (v) => setState(() => _draftRating = v),
                    ),
                    const SizedBox(height: 12),
                    const Text('Price range',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${_draftPrice.start.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('\$${_draftPrice.end.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    RangeSlider(
                      values: _draftPrice,
                      min: 0,
                      max: _maxPrice,
                      divisions: 20,
                      onChanged: (values) =>
                          setState(() => _draftPrice = values),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16, 8, 16, 16 + MediaQuery.paddingOf(context).bottom,
                ),
                child: FilledButton(
                  onPressed: _apply,
                  child: const Text('Show results'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
