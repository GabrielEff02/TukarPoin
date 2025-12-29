import 'package:barcode/barcode.dart';
import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/auth/splash_screen.dart';
import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:e_commerce/screen/navbar_menu/checkout_main_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  bool buttonPressed4 = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      passwordCheck();
    });
    // if (NotificationApi.notificationId != 0) {
    //   Get.to(NotificationScreen());
    // }
  }

  void passwordCheck() async {
    final phone = await LocalData.getData('phone');
    final password = await LocalData.getData('password');
    if (phone == password) {
      DialogConstant.showDefaultPasswordModal(context);
    }
  }

  void _navigateToPage(int pageIndex) {
    if (_isPageLoading) return;

    setState(() {
      buttonPressed1 = pageIndex == 0;
      buttonPressed2 = pageIndex == 1;
      buttonPressed3 = pageIndex == 2;
      buttonPressed4 = pageIndex == 3;
      _isPageLoading = true;
    });
    if (pageIndex != 0 && pageIndex != 1) {
      DialogConstant.loading(context, "Loading...");
    }
    LocalData.saveDataBool('isLoading', true);
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
      appBar: null,
      body: Stack(
        children: [
          // PageView
          PageView(
            controller: controllers,
            children: const <Widget>[
              LandingScreen(),
              CheckoutMainScreen(),
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
                  buttonPressed4 = val == 3;
                });
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Custom shaped bottom bar
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 80),
              painter: BottomBarPainter(),
            ),
            // Navigation items
            Container(
              height: 80,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (buttonPressed1) return;
                      _navigateToPage(0);
                    },
                    child: buttonPressed1
                        ? ButtonTapped(icon: Icons.home)
                        : MyButton(icon: Icons.home),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (buttonPressed2) return;
                      _navigateToPage(1);
                    },
                    child: buttonPressed2
                        ? ButtonTapped(icon: FontAwesomeIcons.bagShopping)
                        : MyButton(icon: FontAwesomeIcons.bagShopping),
                  ),
                  // Space for center button
                  SizedBox(width: 60),
                  GestureDetector(
                    onTap: () {
                      if (buttonPressed3) return;
                      _navigateToPage(2);
                    },
                    child: buttonPressed3
                        ? ButtonTapped(icon: Icons.redeem)
                        : MyButton(icon: Icons.redeem),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (buttonPressed4) return;
                      _navigateToPage(3);
                    },
                    child: buttonPressed4
                        ? ButtonTapped(icon: Icons.account_circle)
                        : MyButton(icon: Icons.account_circle),
                  ),
                ],
              ),
            ),
            // Elevated barcode button
            Positioned(
              top: -10,
              child: GestureDetector(
                onTap: () {
                  _showBarcodePopup(context);
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF0830F),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[600]!,
                        offset: Offset(4.0, 4.0),
                        blurRadius: 15.0,
                        spreadRadius: 1.0,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4.0, -4.0),
                        blurRadius: 15.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orangeAccent,
                        Colors.deepOrange,
                      ],
                      stops: [0.1, 1],
                    ),
                  ),
                  child: Icon(
                    FontAwesomeIcons.barcode,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBarcodePopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return FutureBuilder(
          future: LocalData.getData('barcode'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Terjadi kesalahan'),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, size: 48, color: Colors.orange),
                      SizedBox(height: 16),
                      Text('Data tidak ditemukan'),
                    ],
                  ),
                ),
              );
            }

            return _BarcodeDialogContent(barcodeData: snapshot.data.toString());
          },
        );
      },
    );
  }
}

class _BarcodeDialogContent extends StatefulWidget {
  final String barcodeData;

  const _BarcodeDialogContent({required this.barcodeData});

  @override
  State<_BarcodeDialogContent> createState() => _BarcodeDialogContentState();
}

class _BarcodeDialogContentState extends State<_BarcodeDialogContent>
    with SingleTickerProviderStateMixin {
  bool showBarcode = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCodeType() {
    _animationController.reverse().then((_) {
      setState(() {
        showBarcode = !showBarcode;
      });
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final code39 = Barcode.code39().toSvg(widget.barcodeData);
    final qrCode = Barcode.qrCode().toSvg(widget.barcodeData);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade600,
                    Colors.orange.shade500,
                    Colors.deepOrange.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            showBarcode
                                ? Icons.barcode_reader
                                : Icons.qr_code_2_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Text(
                          showBarcode ? 'Barcode Anda' : 'QR Code Anda',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // White Card Container
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        // Code Display with Fade Animation
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade50,
                                  Colors.white,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.orange.shade200,
                                width: 2,
                              ),
                            ),
                            child: SvgPicture.string(
                              showBarcode ? code39 : qrCode,
                              height: showBarcode ? 140 : 160,
                              width: showBarcode ? 250 : 160,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Barcode Number
                        if (!showBarcode)
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.barcodeData,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Toggle Button
                        GestureDetector(
                          onTap: _toggleCodeType,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade400,
                                  Colors.orange.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.shade300,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  showBarcode
                                      ? Icons.qr_code_2_rounded
                                      : Icons.barcode_reader,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  showBarcode
                                      ? 'Tampilkan QR Code'
                                      : 'Tampilkan Barcode',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Info Text
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tunjukkan kode ini ke kasir untuk mendapatkan Tiara Poin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BottomBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from left
    path.moveTo(0, 20);
    path.lineTo(size.width * 0.35, 20);

    // Curve up for the center button
    path.quadraticBezierTo(
      size.width * 0.40,
      20,
      size.width * 0.43,
      10,
    );
    path.quadraticBezierTo(
      size.width * 0.46,
      0,
      size.width * 0.50,
      0,
    );
    path.quadraticBezierTo(
      size.width * 0.54,
      0,
      size.width * 0.57,
      10,
    );
    path.quadraticBezierTo(
      size.width * 0.60,
      20,
      size.width * 0.65,
      20,
    );

    // Continue to right
    path.lineTo(size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow
    canvas.drawShadow(path, Colors.black26, 8, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
