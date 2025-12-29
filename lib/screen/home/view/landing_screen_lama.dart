import 'dart:async';
import 'dart:convert';
import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:barcode/barcode.dart';
import 'package:e_commerce/constant/text_constant.dart';
import 'package:e_commerce/screen/gabriel/notifications/item_screen.dart';
import 'package:e_commerce/screen/gabriel/request_item/request_item_screen/request_item_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../controller/landing_controller.dart';
import '../../../screen/gabriel/core/app_export.dart';

class LandingScreenLama extends StatefulWidget {
  const LandingScreenLama({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreenLama> {
  LandingScreenController controller = LandingScreenController();
  String profilePicture = '';
  String fullName = '';
  String noMember = '{Nomor Member}';
  String point = '0';
  String vip = '0';
  String prevPoint = '0';
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

    setState(() {
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        backgroundColor: Colors.white,
        color: Colors.blue,
        strokeWidth: 2.0,
        displacement: 40.0,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 12.v, horizontal: 20.h),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipOval(
                                child: CustomImageView(
                                  imagePath:
                                      "${API.BASE_URL}/images/${profilePicture}",
                                  width: 80.0,
                                  height: 80.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fullName,
                                        style: TextConstant.medium.copyWith(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        noMember,
                                        style: TextConstant.medium.copyWith(
                                          color: Colors.black87,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: itemMenu(
                                    point: true,
                                    value: [point, vip, prevPoint]),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.v),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => _showBarcodePopup(context, false),
                                child: itemMenu(
                                  title: "Barcode",
                                  icon: FontAwesomeIcons.barcode,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showBarcodePopup(context, true),
                                child: itemMenu(
                                    title: "QR Code", icon: Icons.qr_code_2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.v),
                    CarouselWidget(),
                    SizedBox(height: 20.v),
                    SizedBox(height: 80.v)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getCompan() async {
    try {
      final response =
          await http.get(Uri.parse('${API.BASE_URL}/api/poin/company'));

      if (response.statusCode == 200) {
        // Mengonversi JSON response menjadi List<Map<String, dynamic>>
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((outlet) {
          return {'compan_code': outlet['compan_code'], 'name': outlet['name']};
        }).toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Widget categoryColumn(Map<String, dynamic> categoryData) {
    List<Widget> rows = [];

    List<String> categories = categoryData.keys.toList();

    for (int i = 0; i < categories.length; i += 4) {
      List<String> rowCategories = categories.sublist(
        i,
        (i + 4 > categories.length) ? categories.length : i + 4,
      );
      rows.add(categoryRow(rowCategories, categoryData,
          lastItem: i + 4 > categories.length));
      // rows.add()
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: rows,
      ),
    );
  }

  // ...existing code...

  Widget itemMenu(
      {String? title,
      IconData? icon,
      bool point = false,
      List<String>? value}) {
    final decoration = point
        ? BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFF8E2C8).withValues(alpha: 100),
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFF6F61), Color(0xFFFFB74D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          );

    bool isVip = point && value != null && int.parse(value[1]) == 1;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.adaptSize),
      child: point
          ? GestureDetector(
              onTap: () {
                print('value: $value');

                if (int.parse(value[2]) > 0)
                  DialogConstant.showPeriodComparisonDialog(
                      context, int.parse(value[0]), int.parse(value[2]));
              },
              child: Container(
                width: 285.h,
                padding: EdgeInsets.all(15.adaptSize),
                decoration: BoxDecoration(
                  gradient: isVip
                      ? LinearGradient(
                          colors: [
                            Color(0xFFFFD700), // Gold
                            Color(0xFFFFA500), // Orange gold
                            Color(0xFFFFD700), // Gold
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            Color(0xFF6DB9EF), // Light blue
                            Color(0xFF87CEEB), // Sky blue
                            Color(0xFF6DB9EF), // Light blue
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isVip
                          ? Color(0xFFFFD700).withOpacity(0.3)
                          : Color(0xFF6DB9EF).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5.v),
                child: Column(
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
                          isVip
                              ? Icon(
                                  FontAwesomeIcons.crown,
                                  color: Color(0xFFB8860B),
                                  size: 20,
                                )
                              : Icon(
                                  Icons.stars,
                                  color: Color(0xFF4682B4),
                                  size: 20,
                                ),
                          SizedBox(width: 8),
                          Text(
                            isVip ? "VIP MEMBER" : "BASIC MEMBER",
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

                        // Progress or VIP Crown
                        if (!isVip) ...[
                          Container(
                            width: 2,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.7),
                                  Colors.white.withOpacity(0.3),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "To VIP",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${1500 - int.parse(value![0])}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                "points left",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
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
                      ],
                    ),

                    if (!isVip) ...[
                      SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Silver',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 10.adaptSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'VIP',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 10.adaptSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 8,
                                child: LinearProgressIndicator(
                                  value: (value != null && value.isNotEmpty)
                                      ? (double.tryParse(value[0]) ?? 0) / 1500
                                      : 0,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : Container(
              decoration: decoration,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(icon, color: Colors.black87),
                  SizedBox(width: 15),
                  Text(
                    title!,
                    style: TextConstant.medium.copyWith(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showBarcodePopup(BuildContext context, bool isQRCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: LocalData.getData('barcode'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Icon(Icons.error));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Icon(Icons.error)); // If no data
            }

            final code = isQRCode
                ? Barcode.qrCode().toSvg(snapshot.data.toString())
                : Barcode.code39().toSvg(snapshot.data.toString());

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1.0, end: 1.1),
              duration: const Duration(milliseconds: 500),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Dialog(
                    child: Container(
                      height: 400,
                      decoration: const BoxDecoration(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: SvgPicture.string(code,
                                  height: isQRCode ? 200 : 250,
                                  width: isQRCode ? 200 : 200,
                                  fit:
                                      isQRCode ? BoxFit.cover : BoxFit.contain),
                            ),
                            const SizedBox(height: 10),
                            if (isQRCode)
                              Text(
                                snapshot.data.toString(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<Widget> productRow(List productData) {
    List<Widget> rows = [];

    for (int i = 0; i < productData.length; i += 2) {
      rows.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildProductCard(context, productData[i]),
              ),
              if (i + 1 < productData.length) SizedBox(width: 16),
              if (i + 1 < productData.length)
                Expanded(
                  child: _buildProductCard(context, productData[i + 1]),
                )
              else
                SizedBox(width: 16),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(ItemScreen(data: product.map((key, value) {
                return MapEntry(key, value.toString());
              })));
            },
            child: CustomImageView(
              imagePath: "${API.BASE_URL}/images/${product['image_url']}",
              height: 150, // Adjust image height as needed
              width: double.infinity,
              alignment: Alignment.center,
            ),
          ),
          SizedBox(height: 12), // Space between image and text
          Text(
            maxLines: 2,
            product['product_name'], // Product name
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18, // Increase font size
              color: Colors.black87, // Darker text color
            ),
          ),
          SizedBox(height: 4), // Space between name and price
          Text(
            'Point: ${product['price']}', // Product price
            style: TextStyle(
              fontSize: 16, // Font size for price
              color: Colors.green, // Green color for price
            ),
          ),
          SizedBox(height: 4), // Space between price and quantity
          Text(
            'Quantity: ${product['quantity']}', // Product quantity
            style: TextStyle(
              fontSize: 14, // Font size for quantity
              color: Colors.grey[600], // Grey color for quantity
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryRow(List<String> categories, Map<String, dynamic> categoryData,
      {Icon? icon, bool? lastItem}) {
    // Your existing categoryRow code
    List<Widget> categoryWidgets = categories.map((category) {
      return categoryImage(categoryData[category], category);
    }).toList();
    if (lastItem == true) {
      categoryWidgets.add(
        InkWell(
          onTap: () => Get.to(() => RequestedItemScreen()),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appTheme.gray200,
                ),
                child: Icon(Icons.request_page),
              ),
              Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Text("Request"))
            ],
          ),
        ),
      );
    }
    while (categoryWidgets.length < 4) {
      categoryWidgets
          .add(Container(width: 50)); // Empty container for alignment
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categoryWidgets,
    );
  }

  Widget categoryImage(String base64Image, String category) {
    String name = '';
    if (category.split(' ').length > 2) {
      final categorySplited = category.split(' ');
      for (String categoryName in categorySplited) {
        if (categoryName.contains(RegExp(r'[a-zA-Z]')))
          name += categoryName.substring(0, 1);
      }
    } else {
      name = category.split(' ').first;
    }
    name = name.toUpperCase();
    return InkWell(
      onTap: () {
        Navigator.pushReplacementNamed(context, AppRoutes.showItemsScreen);
      },
      child: Column(
        children: [
          (category != 'All')
              ? Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          MemoryImage(base64Decode(base64Image.split(',')[1])),
                    ),
                    shape: BoxShape.circle,
                    color: appTheme.gray200,
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appTheme.gray200,
                  ),
                  child: Icon(
                    Icons.format_list_bulleted,
                  ),
                ),
          Container(
              margin: const EdgeInsets.only(bottom: 20), child: Text(name))
        ],
      ),
    );
  }
}
