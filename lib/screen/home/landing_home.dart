import 'package:e_commerce/NavBar.dart';
import 'package:e_commerce/api/notification_api.dart';
import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/auth/splash_screen.dart';
import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:e_commerce/screen/gabriel/notifications/notification_screen.dart';
import 'package:get/get.dart';
import 'package:e_commerce/screen/home/view/landing_screen.dart';
import 'package:e_commerce/screen/home/view/profile_screen.dart';
import 'package:e_commerce/screen/home/view/wheel_fortune.dart';
import 'package:e_commerce/widget/material/button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class LandingHome extends StatefulWidget {
  LandingHome({Key? key}) : super(key: key);
  @override
  State<LandingHome> createState() => _LandingHomeState();
}

class _LandingHomeState extends State<LandingHome>
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
    // if (NotificationApi.notificationId != 0) {
    //   Get.to(NotificationScreen());
    // }
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
    if (pageIndex != 0) DialogConstant.loading(context, "Loading...");

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
                    "Tiara Member",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
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
                // IconButton(
                //   onPressed: () {
                //     Get.to(NotificationScreen());
                //   },
                //   icon: SplashScreen.notificationData['count'] != null &&
                //           SplashScreen.notificationData['count'] > 0
                //       ? Stack(
                //           clipBehavior: Clip.none,
                //           children: [
                //             AnimatedBuilder(
                //               animation: _controller,
                //               builder: (context, child) {
                //                 return Transform.rotate(
                //                   angle: _swingAnimation.value,
                //                   child: child,
                //                 );
                //               },
                //               child: Icon(
                //                 Icons.notifications,
                //                 color: const Color(0xFF0095FF),
                //                 size: 35.0,
                //               ),
                //             ),
                //             Positioned(
                //               right: 0,
                //               top: 0,
                //               child: Container(
                //                 padding: EdgeInsets.all(4.0),
                //                 decoration: BoxDecoration(
                //                   color: Colors.red,
                //                   shape: BoxShape.circle,
                //                 ),
                //                 constraints: BoxConstraints(
                //                   minWidth: 20.0,
                //                   minHeight: 20.0,
                //                 ),
                //                 child: Center(
                //                   child: Text(
                //                     SplashScreen.notificationData['count']
                //                         .toString(),
                //                     style: TextStyle(
                //                       color: Colors.white,
                //                       fontSize: 12.0,
                //                       fontWeight: FontWeight.bold,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         )
                //       : Icon(
                //           Icons.notifications,
                //           color: const Color.fromARGB(255, 78, 175, 245),
                //           size: 35.0,
                //         ),
                // ),
              ],
            )
          : null,
      drawer: buttonPressed1 ? NavBar() : null,
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
                if (val != 0) DialogConstant.loading(context, "Loading...");

                setState(() {
                  buttonPressed1 = val == 0;
                  buttonPressed2 = val == 1;
                  buttonPressed3 = val == 2;
                });
              }
            },
          ),
          Positioned(
            bottom: 20,
            left: 50,
            right: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (buttonPressed1) return;

                      _navigateToPage(0);
                    },
                    child: buttonPressed1
                        ? ButtonTapped(
                            icon: Icons.home,
                            color: Colors.amber,
                          )
                        : MyButton(
                            icon: Icons.home,
                            color: Colors.amber,
                          ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (buttonPressed2) return;
                      _navigateToPage(1);
                    },
                    child: buttonPressed2
                        ? ButtonTapped(
                            icon: FontAwesomeIcons.bullseye, color: Colors.blue)
                        : MyButton(
                            icon: FontAwesomeIcons.bullseye,
                            color: Colors.blue),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (buttonPressed3) return;
                      _navigateToPage(2);
                    },
                    child: buttonPressed3
                        ? ButtonTapped(
                            icon: Icons.account_circle, color: Colors.red)
                        : MyButton(
                            icon: Icons.account_circle, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
