import 'package:e_commerce/api/notification_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'screen/auth/login_screen.dart';
import 'screen/gabriel/core/app_export.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
final navigatorKey = GlobalKey<NavigatorState>();
void getToken() async {
  String? token = await _firebaseMessaging.getToken();
  print("FCM Token: $token");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await NotificationApi().initNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
          title: 'Foxie',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(secondary: Colors.grey.shade400),
            textTheme: TextTheme(),
          ),
          home: LoginScreen(),
          routes: AppRoutes.allRoutes);
    });
  }
}
