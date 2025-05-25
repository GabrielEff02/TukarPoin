import 'package:e_commerce/screen/gabriel/checkouts/splash_screen/checkouts_splash_screen.dart';
import 'package:get/get.dart';

import '../core/app_export.dart';

void mainCheckouts({String filterCategory = 'all'}) {
  MainCheckoutsApp.filterCategory = filterCategory;
  Get.to(() => MainCheckoutsApp());
}

class MainCheckoutsApp extends StatelessWidget {
  MainCheckoutsApp({
    super.key,
  });
  static String filterCategory = '';
  @override
  Widget build(BuildContext context) {
    return CheckoutsSplashScreen();
  }
}
