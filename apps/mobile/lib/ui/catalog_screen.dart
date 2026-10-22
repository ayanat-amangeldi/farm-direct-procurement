import 'package:flutter/material.dart';

import '../catalog/demo_catalog.dart';
import '../catalog/models.dart';
import 'offers_screen.dart';
import 'produce_art.dart';
import 'shared.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _search = TextEditingController();
  final _catalog = const DemoCatalog();
  ProductCategory? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
    _search.clear();
    _category = null;
  });

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final products = DemoCatalog.products
        .where(
          (product) =>
              (_category == null || product.category == _category) &&
              product.name.toLowerCase().contains(query),
        )
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textScale =
                    MediaQuery.textScalerOf(context).scale(14) / 14;
                final columns = constraints.maxWidth < 360 || textScale > 1.3
                    ? 1
                    : constraints.maxWidth >= 900
                    ? 4
                    : constraints.maxWidth >= 600
                    ? 3
                    : 2;
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: forest,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: const Icon(
                                    Icons.eco_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'FarmDirect',
                                    style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: muted,
                                  size: 17,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'KZ',
                                  style: TextStyle(
                                    color: muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'GROWN WITH CARE. BOUGHT DIRECT.',
                              style: TextStyle(
                                color: forest,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.7,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Good food.\nCloser to the farm.',
                              style: TextStyle(
                                fontSize: 36,
                                height: 1.1,
                                letterSpacing: -1.4,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Find your produce. Meet the growers.\nSee exactly what you pay.',
                              style: TextStyle(
                                fontSize: 15,
                                color: muted,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const DemoLabel(),
                            const SizedBox(height: 24),
                            TextField(
                              key: const Key('catalog-search'),
                              controller: _search,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search potatoes, apples, and more',
                                hintStyle: const TextStyle(
                                  fontSize: 13,
                                  color: muted,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: muted,
                                ),
                                suffixIcon: _search.text.isEmpty
                                    ? null
                                    : IconButton(
                                        tooltip: 'Clear search',
                                        onPressed: () =>
                                            setState(_search.clear),
                                        icon: const Icon(Icons.close, size: 20),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _categoryChip('All produce', null),
                                  _categoryChip(
                                    'Vegetables',
                                    ProductCategory.vegetables,
                                  ),
                                  _categoryChip(
                                    'Fruits',
                                    ProductCategory.fruits,
                                  ),
                                  _categoryChip(
                                    'Grains',
                                    ProductCategory.grains,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Explore the harvest',
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${products.length} products',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: muted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    if (products.isEmpty)
                      SliverToBoxAdapter(
                        child: EmptyResults(
                          title: 'No products found',
                          message: 'Try another product name or category.',
                          onReset: _reset,
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                mainAxisExtent: 286 + (textScale - 1) * 130,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = products[index];
                            return _ProductCard(
                              product: product,
                              offerCount: _catalog.offersFor(product.id).length,
                              fromPrice: _catalog.startingPrice(product.id),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      OffersScreen(product: product),
                                ),
                              ),
                            );
                          }, childCount: products.length),
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 28, 20, 28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.eco_outlined, size: 16, color: muted),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Small farms. Clear choices.',
                                style: TextStyle(color: muted, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String title, ProductCategory? category) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(title),
      selected: _category == category,
      showCheckmark: false,
      selectedColor: forest,
      backgroundColor: Colors.transparent,
      labelStyle: TextStyle(
        color: _category == category ? Colors.white : muted,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      side: BorderSide(color: _category == category ? forest : lineColor),
      onSelected: (_) => setState(() => _category = category),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.offerCount,
    required this.fromPrice,
    required this.onTap,
  });
  final Product product;
  final int offerCount;
  final int fromPrice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: lineColor),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: Key('product-${product.id}'),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 118,
            color: ProduceArt.background(product.id),
            child: ProduceArt(product.id),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$offerCount ${offerCount == 1 ? 'offer' : 'offers'}',
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                  const Spacer(),
                  const Text(
                    'From',
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              money(fromPrice),
                              style: const TextStyle(
                                color: forest,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Text(
                              '/ kg',
                              style: TextStyle(color: muted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: forest,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
