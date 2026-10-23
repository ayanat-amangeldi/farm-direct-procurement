import 'package:flutter/material.dart';

import 'orders/order_store.dart';
import 'orders/preferences_persistence.dart';
import 'ui/catalog_screen.dart';
import 'ui/shared.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OrderStore store;
  try {
    store = await OrderStore.restore(PreferencesOrderPersistence());
  } catch (_) {
    // Do not overwrite unreadable history or log contact details.
    store = OrderStore(loadFailed: true);
  }
  runApp(FarmDirectApp(orderStore: store));
}

class FarmDirectApp extends StatefulWidget {
  const FarmDirectApp({this.orderStore, super.key});
  final OrderStore? orderStore;
  @override
  State<FarmDirectApp> createState() => _FarmDirectAppState();
}

class _FarmDirectAppState extends State<FarmDirectApp> {
  late final OrderStore _store = widget.orderStore ?? OrderStore();

  @override
  void dispose() {
    if (widget.orderStore == null) _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OrderScope(
    store: _store,
    child: MaterialApp(
      title: 'Farm Direct',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvasColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: forest,
          surface: Colors.white,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: ink,
          displayColor: ink,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: canvasColor,
          foregroundColor: ink,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lineColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lineColor),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: forest,
            foregroundColor: Colors.white,
            minimumSize: const Size(44, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const CatalogScreen(),
    ),
  );
}
