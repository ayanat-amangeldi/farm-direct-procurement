import 'package:flutter/material.dart';

import '../catalog/demo_catalog.dart';
import '../catalog/models.dart';
import 'offers_screen.dart';
import 'product_photo.dart';
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
            constraints: const BoxConstraints(maxWidth: 1160),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
                final columns = constraints.maxWidth < 360 || scale > 1.3
                    ? 1
                    : constraints.maxWidth >= 800
                    ? 3
                    : 2;
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: ink,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.spa_outlined,
                                    color: Colors.white,
                                    size: 23,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'farmdirect',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: muted,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Kazakhstan',
                                  style: TextStyle(fontSize: 11, color: muted),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 22),
                              child: Divider(height: 1, color: lineColor),
                            ),
                            const Text(
                              'PRODUCT CATALOG',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.8,
                                color: forest,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Agricultural\nmarketplace',
                              style: TextStyle(
                                fontSize: 34,
                                height: 1.08,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Compare produce, growers and delivery terms\nin one place.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: muted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const DemoLabel(),
                            const SizedBox(height: 22),
                            TextField(
                              key: const Key('catalog-search'),
                              controller: _search,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search agricultural products',
                                hintStyle: const TextStyle(
                                  fontSize: 13,
                                  color: muted,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: muted,
                                  size: 21,
                                ),
                                suffixIcon: _search.text.isEmpty
                                    ? null
                                    : IconButton(
                                        tooltip: 'Clear search',
                                        onPressed: () =>
                                            setState(_search.clear),
                                        icon: const Icon(Icons.close, size: 18),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
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
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Available products',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
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
                            const SizedBox(height: 14),
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
                                mainAxisSpacing: 16,
                                mainAxisExtent: 328 + (scale - 1) * 150,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = products[index];
                            return _ProductCard(
                              product: product,
                              offers: _catalog.offersFor(product.id),
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
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Prices are per kilogram. Delivery is calculated for the selected farmer offer.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: muted,
                            height: 1.5,
                          ),
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
      selectedColor: ink,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: _category == category ? Colors.white : muted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      side: BorderSide(color: _category == category ? ink : lineColor),
      onSelected: (_) => setState(() => _category = category),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.offers,
    required this.fromPrice,
    required this.onTap,
  });
  final Product product;
  final List<FarmerOffer> offers;
  final int fromPrice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: lineColor),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: Key('product-${product.id}'),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 148,
            width: double.infinity,
            child: ProductPhoto(product.id),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 14, 13, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${offers.length} ${offers.length == 1 ? 'farmer' : 'farmers'}',
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'From',
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        money(fromPrice),
                        style: const TextStyle(
                          fontSize: 21,
                          color: ink,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const Text(
                        '/ kg',
                        style: TextStyle(fontSize: 11, color: muted),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Divider(height: 1, color: lineColor),
                  const SizedBox(height: 11),
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Compare',
                          style: TextStyle(
                            fontSize: 12,
                            color: forest,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward, size: 16, color: forest),
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
