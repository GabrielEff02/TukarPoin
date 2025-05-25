import 'package:e_commerce/screen/auth/splash_screen.dart';
import '../../core/app_export.dart';

class CheckoutsSplashScreen extends StatelessWidget {
  const CheckoutsSplashScreen({Key? key}) : super(key: key);

  static void getData(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.showItemsScreen);
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.notFoundScreen,
          arguments:
              AppRoutes.checkoutsSplashScreen, // Pass the route as an argument
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getData(context);

    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  NetworkImage("${API.BASE_URL}/images/${SplashScreen.path1}"),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
