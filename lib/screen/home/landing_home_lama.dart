import 'package:e_commerce/NavBar.dart';
import 'package:e_commerce/api/notification_api.dart';
import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/auth/splash_screen.dart';
import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:e_commerce/screen/gabriel/notifications/notification_screen.dart';
import 'package:e_commerce/screen/navbar_menu/about_us_screen.dart';
import 'package:e_commerce/screen/navbar_menu/contact_screen.dart';
import 'package:get/get.dart';
import 'package:e_commerce/screen/home/view/landing_screen.dart';
import 'package:e_commerce/screen/home/view/profile_screen.dart';
import 'package:e_commerce/screen/home/view/wheel_fortune.dart';
import 'package:e_commerce/widget/material/button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class LandingHomeLama extends StatefulWidget {
  LandingHomeLama({Key? key}) : super(key: key);
  @override
  State<LandingHomeLama> createState() => _LandingHomeState();
}

class _LandingHomeState extends State<LandingHomeLama>
    with TickerProviderStateMixin {
  // Add state variables here if needed
  PageController controllers = PageController();
  late AnimationController _controller;
  late Animation<double> _swingAnimation;
  // Button state
  bool buttonPressed1 = true;
  bool buttonPressed2 = false;
  bool buttonPressed3 = false;
  int _currentIndex = 0;
  // Track loading state
  bool _isPageLoading = false;

  String nama = '';

  @override
  void dispose() {
    controllers.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _swingAnimation = Tween<double>(begin: -0.3, end: 0.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );

    if (SplashScreen.notificationData['count'] != null &&
        SplashScreen.notificationData['count'] > 0) {
      _controller.repeat(reverse: true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      passwordCheck();
    });
    // if (NotificationApi.notificationId != 0) {
    //   Get.to(NotificationScreen());
    // }
  }

  void passwordCheck() async {
    final name = await LocalData.getData('full_name');
    final phone = await LocalData.getData('phone');
    final password = await LocalData.getData('password');
    if (phone == password) {
      DialogConstant.showDefaultPasswordModal(context);
    }
    setState(() {
      nama = name.split(' ')[0];
    });
  }

  void _navigateToPage(int pageIndex) {
    if (_isPageLoading) return;

    setState(() {
      buttonPressed1 = pageIndex == 0;
      buttonPressed2 = pageIndex == 1;
      buttonPressed3 = pageIndex == 2;
      _isPageLoading = true;
      _currentIndex = pageIndex;
    });
    if (pageIndex != 0) {
      DialogConstant.loading(context, "Loading...");
      LocalData.saveDataBool('isLoading', true);
    }
    controllers
        .animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    )
        .then((_) {
      if (mounted) {
        setState(() {
          _isPageLoading = false;
        });
      } else {
        setState(() {
          _isPageLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buttonPressed1
          ? AppBar(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Text(
                    "Hi, $nama",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.showItemsScreen);
                  },
                  icon: Icon(
                    Icons.shopping_cart,
                    color: const Color.fromARGB(255, 245, 198, 78),
                    size: 35.0,
                  ),
                ),
              ],
              leading: IconButton(
                onPressed: () => Get.to(ContactScreen()),
                icon: Icon(Icons.headphones),
                color: const Color(0xffff7e2d),
              ),
            )
          : null,

      // drawer: buttonPressed1 ? NavBar() : null,
      body: Stack(
        children: [
          // PageView
          PageView(
            controller: controllers,
            children: const <Widget>[
              LandingScreen(),
              WheelFortune(),
              ProfileScreen(),
            ],
            onPageChanged: (val) {
              if (mounted && !_isPageLoading) {
                if (val != 0) {
                  DialogConstant.loading(context, "Loading...");
                  LocalData.saveDataBool('isLoading', true);
                }
                setState(() {
                  buttonPressed1 = val == 0;
                  buttonPressed2 = val == 1;
                  buttonPressed3 = val == 2;
                });
              }
            },
          ),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (buttonPressed1) return;

                _navigateToPage(0);
              },
              child: buttonPressed1
                  ? ButtonTapped(
                      icon: Icons.home,
                    )
                  : MyButton(
                      icon: Icons.home,
                    ),
            ),
            GestureDetector(
              onTap: () {
                if (buttonPressed2) return;
                _navigateToPage(1);
              },
              child: buttonPressed2
                  ? ButtonTapped(
                      icon: FontAwesomeIcons.bullseye,
                    )
                  : MyButton(
                      icon: FontAwesomeIcons.bullseye,
                    ),
            ),
            GestureDetector(
              onTap: () {
                if (buttonPressed3) return;
                _navigateToPage(2);
              },
              child: buttonPressed3
                  ? ButtonTapped(icon: Icons.account_circle)
                  : MyButton(
                      icon: Icons.account_circle,
                    ),
            ),
            GestureDetector(
              onTap: () {
                if (buttonPressed3) return;
                _navigateToPage(2);
              },
              child: buttonPressed3
                  ? ButtonTapped(icon: Icons.account_circle)
                  : MyButton(
                      icon: Icons.account_circle,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
