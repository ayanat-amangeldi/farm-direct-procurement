import 'package:farm_direct/auth/account.dart';
import 'package:farm_direct/orders/order_store.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> demoLogin(
  OrderStore store, [
  String email = 'buyer@farm.demo',
]) async {
  if (store.currentUser?.email == email) return;
  Future<void> action() => store.signIn(email, demoPassword);
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  if (binding.inTest) {
    await binding.runAsync(action);
  } else {
    await action();
  }
}

Future<OrderStore> buyerStore(OrderStore store) async {
  await demoLogin(store);
  return store;
}

Future<OrderStore> farmerStore(OrderStore store) async {
  await demoLogin(store, 'bereke@farm.demo');
  return store;
}
