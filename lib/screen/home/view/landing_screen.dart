import 'dart:async';
import 'dart:convert';
import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/gabriel/request_item/request_history_screen/request_history_screen.dart';
import 'package:e_commerce/screen/navbar_menu/about_us_screen.dart';
import 'package:e_commerce/screen/navbar_menu/contact_screen.dart';
import 'package:e_commerce/screen/navbar_menu/history_screen.dart';
import 'package:e_commerce/screen/navbar_menu/others_screen.dart';
import 'package:e_commerce/screen/navbar_menu/outlet_screen.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../controller/landing_controller.dart';
import '../../../screen/gabriel/core/app_export.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  LandingScreenController controller = LandingScreenController();
  String profilePicture = '';
  String fullName = '';
  String noMember = '{Nomor Member}';
  String point = '0';
  String vip = '0';
  String prevPoint = '0';
  Map<String, dynamic> periodData = {};
  bool first = true;
  Map<String, dynamic> categoryData = {};
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() async {
    final profile = await LocalData.getData("profile_picture");
    final name = await LocalData.getData("full_name");
    final myPoint = await LocalData.getData('point');
    final myPrevPoint = await LocalData.getData('prev_point');
    final myVIP = await LocalData.getData('vip');
    final myBarcode = await LocalData.getData('barcode');
    final myPeriodData = await LocalData.getData('current_period');

    setState(() {
      periodData = json.decode(myPeriodData);
      controller = Get.put(LandingScreenController());
      profilePicture = profile;
      fullName = name;
      point = myPoint;
      prevPoint = myPrevPoint;
      noMember = myBarcode;
      vip = myVIP;
      if (vip == '0' && int.parse(myPoint) >= 1500) {
        LocalData.saveData('vip', '1');
        vip = '1';
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _loadUserData();

    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildModernAppBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            backgroundColor: Colors.white,
            color: Colors.blue,
            strokeWidth: 2.0,
            displacement: 40.0,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: [
                    CarouselWidget(),
                    SizedBox(height: 20.v),
                    _buildQuickActions(),
                    SizedBox(height: 10.v),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 12.v, horizontal: 20.h),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: itemMenu(value: [point, vip, prevPoint]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ...existing code...

  Widget itemMenu({List<String>? value}) {
    bool isVip = value != null && int.parse(value[1]) == 1;
    final decoration = isVip
        ? BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFD700), // Gold
                Color(0xFFFFA500), // Orange gold
                Color(0xFFFFD700), // Gold
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(0, 6),
              ),
            ],
          )
        : BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_point_basic.png'),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          );
    // BoxDecoration(
    //   gradient: isVip
    //       ? LinearGradient(
    //           colors: [
    //             Color(0xFFFFD700), // Gold
    //             Color(0xFFFFA500), // Orange gold
    //             Color(0xFFFFD700), // Gold
    //           ],
    //           begin: Alignment.topLeft,
    //           end: Alignment.bottomRight,
    //         )
    //       : LinearGradient(
    //           colors: [
    //             Color(0xFF6DB9EF), // Light blue
    //             Color(0xFF87CEEB), // Sky blue
    //             Color(0xFF6DB9EF), // Light blue
    //           ],
    //           begin: Alignment.topLeft,
    //           end: Alignment.bottomRight,
    //         ),
    //   borderRadius: BorderRadius.circular(20),
    //   boxShadow: [
    //     BoxShadow(
    //       color: isVip
    //           ? Color(0xFFFFD700).withOpacity(0.3)
    //           : Color(0xFF6DB9EF).withOpacity(0.3),
    //       blurRadius: 15,
    //       spreadRadius: 2,
    //       offset: Offset(0, 6),
    //     ),
    //   ],
    // );
    return Container(
      child: GestureDetector(
        onTap: () {
          if (int.parse(value[2]) > 0)
            DialogConstant.showPeriodComparisonDialog(
                context, int.parse(value[0]), int.parse(value[2]));
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 9,
          padding: EdgeInsets.all(15.adaptSize),
          decoration: decoration,
          child: isVip
              ? Column(
                  children: [
                    // Member Status Header
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.crown,
                            color: Color(0xFFB8860B),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "VIP MEMBER",
                            style: TextStyle(
                              color:
                                  isVip ? Color(0xFFB8860B) : Color(0xFF4682B4),
                              fontSize: 12.adaptSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),

                    // Points Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Your Points",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.adaptSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                value != null &&
                                        value.isNotEmpty &&
                                        value[0].isNotEmpty
                                    ? value[0]
                                    : '0',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.adaptSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.workspace_premium,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "VIP",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: 7.adaptSize,
                      child: Container(
                        width: 120.adaptSize,
                        height: 30.adaptSize,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF7E2D),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.adaptSize),
                            bottomRight: Radius.circular(16.adaptSize),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Basic',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.adaptSize,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 20.adaptSize,
                          right: 20.adaptSize,
                          bottom: 20.adaptSize,
                          top: 10.adaptSize),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Text(
                                        'Tiara  Points',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          foreground: Paint()
                                            ..style = PaintingStyle.stroke
                                            ..strokeWidth = 8.5
                                            ..shader = LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFFFD9B5E),
                                                Color(0xFFEE696B),
                                              ],
                                            ).createShader(
                                              Rect.fromLTWH(0, 0, 300, 80),
                                            ),
                                        ),
                                      ),
                                      Text(
                                        'Tiara  Points',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.adaptSize),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${value![0]}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 32.adaptSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Periode: ${periodData['periode_no']}',
                                            style: TextStyle(
                                              color: const Color(0xFF878889),
                                              fontSize: 12.adaptSize,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Column(
                                      //   crossAxisAlignment:
                                      //       CrossAxisAlignment.start,
                                      //   children: [
                                      //     Text(
                                      //       '${value![0]}',
                                      //       style: TextStyle(
                                      //         color: Colors.black,
                                      //         fontSize: 32.adaptSize,
                                      //         fontWeight: FontWeight.bold,
                                      //       ),
                                      //     ),
                                      //     Text(
                                      //       'Periode: ${periodData['periode_no']}',
                                      //       style: TextStyle(
                                      //         color: Colors.grey[700],
                                      //         fontSize: 12.adaptSize,
                                      //         fontWeight: FontWeight.w500,
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                  SizedBox(height: 10.adaptSize),
                                  Text(
                                    'Get more ${1500 - (int.tryParse(value![0]) ?? 0)} points to VIP',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10.adaptSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .25,
                                height: MediaQuery.of(context).size.width * .25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/logo_basic.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: MediaQuery.of(context).size.width * .4,
                              height: 8,
                              child: LinearProgressIndicator(
                                value: (value != null && value.isNotEmpty)
                                    ? (double.tryParse(value[0]) ?? 0) / 1500
                                    : 0,
                                backgroundColor: Color(0xFFFFCB5B),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF919191),
                                ),
                              ),
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
  }

  Widget _buildModernAppBar() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/bg_all.png'), fit: BoxFit.fill),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF7E2D).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAnimatedIconButton(
            icon: Icons.headphones_outlined,
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.to(() => ContactScreen());
              // showGeneralDialog(
              //   context: context,
              //   barrierDismissible: true,
              //   barrierLabel: "Drawer",
              //   barrierColor: Colors.black54,
              //   transitionDuration: Duration(milliseconds: 300),
              //   pageBuilder: (context, anim1, anim2) {
              //     return Align(
              //       alignment: Alignment.centerLeft,
              //       child: Material(
              //         elevation: 16,
              //         child: Container(
              //           width: MediaQuery.of(context).size.width * 0.75,
              //           height: MediaQuery.of(context).size.height,
              //           child: NavBar(),
              //         ),
              //       ),
              //     );
              //   },
              //   transitionBuilder: (context, anim1, anim2, child) {
              //     return SlideTransition(
              //       position: Tween(
              //         begin: Offset(-1, 0),
              //         end: Offset(0, 0),
              //       ).animate(anim1),
              //       child: child,
              //     );
              //   },
              // );
            },
          ),
          Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Welcome Back! 👋",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    fullName.split(' ')[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildAnimatedIconButton(
            icon: Icons.shopping_bag_rounded,
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.toNamed(AppRoutes.showItemsScreen);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              icon,
              size: 26.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.request_page_rounded,
        'label': 'Permintaan',
        'color': Colors.blueGrey,
        'onTap': () => Get.to(() => RequestHistoryScreen()),
      },
      {
        'icon': Icons.history_edu_rounded,
        'label': 'Riwayat',
        'color': Colors.indigo,
        'onTap': () => Get.to(() => HistoryScreen()),
      },
      {
        'icon': Icons.store_rounded,
        'label': 'Outlet',
        'color': Colors.brown,
        'onTap': () => Get.to(() => OutletScreen()),
      },
      {
        'icon': Icons.description_rounded,
        'label': 'Syarat & Ketentuan',
        'color': Colors.blueGrey,
        'onTap': () => Get.to(() => OthersScreen()),
      },
      {
        'icon': Icons.info_outline_rounded,
        'label': 'Tentang',
        'color': Colors.blue,
        'onTap': () => Get.to(() => AboutUsScreen()),
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 100.adaptSize,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 100)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 65.adaptSize,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        (action['onTap'] as VoidCallback)();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    action['color'] as Color,
                                    (action['color'] as Color).withOpacity(0.7),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                action['icon'] as IconData,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            SizedBox(height: 4.adaptSize),
                            Text(
                              action['label'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
