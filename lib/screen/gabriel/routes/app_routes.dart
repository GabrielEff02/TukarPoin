import 'package:e_commerce/screen/gabriel/request_item/request_item_screen/request_item_screen.dart';

import '../not_found_screen/not_found_screen.dart';
import '../core/app_export.dart';
import '../../auth/splash_screen.dart';

import '../checkouts/shopping_cart_screen/shopping_cart_screen.dart';
import '../checkouts/show_items_screen/show_items_screen.dart';
import '../checkouts/splash_screen/checkouts_splash_screen.dart';

class AppRoutes {
  static const String notFoundScreen = '/not_found_screen';

  static const String initialRoute = '/initial_route';

  // Shopping Cart
  static const String shoppingCartScreen = '/shopping_cart_screen';
  static const String showItemsScreen = '/show_items_screen';
  static const String checkoutsSplashScreen = '/checkouts_splash_screen';
  static const String requestItemScreen = '/request_item_screen';

  static Map<String, WidgetBuilder> allRoutes = {
    initialRoute: (context) => const SplashScreen(),
    notFoundScreen: (context) => const NotFoundScreen(),
    shoppingCartScreen: (context) {
      final items = ModalRoute.of(context)?.settings.arguments as List<dynamic>;
      return ShoppingCartScreen(items: items); // Pass items to CartPage
    },
    showItemsScreen: (context) => ShowItemsScreen(),
    checkoutsSplashScreen: (context) => const CheckoutsSplashScreen(),
    requestItemScreen: (context) => RequestedItemScreen(),
  };
}
