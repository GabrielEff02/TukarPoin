import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:barcode/barcode.dart';
import 'package:e_commerce/constant/text_constant.dart';
import 'package:e_commerce/screen/gabriel/notifications/item_screen.dart';
import 'package:e_commerce/screen/gabriel/request_item/request_item_screen/request_item_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controller/landing_controller.dart';
import '../../../screen/gabriel/core/app_export.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final LandingScreenController controller = Get.put(LandingScreenController());

  int vipTarget = 1500;
  Map<String, dynamic> categoryData = {};
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: [
                  Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 12.v, horizontal: 20.h),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Uint8List>(
                              future: LocalData.getProfilePicture(
                                  "profile_picture"),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return const Icon(Icons.error);
                                } else if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return const Icon(
                                      Icons.error); // If no image data
                                }

                                return ClipOval(
                                  child: Image.memory(
                                    snapshot.data!,
                                    width: 80.0,
                                    height: 80.0,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder(
                                      future: LocalData.getData('full_name'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data.toString(),
                                          style: TextConstant.medium.copyWith(
                                            color: Colors.black87,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 5),
                                    FutureBuilder(
                                      future: LocalData.getData('email'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data.toString(),
                                          style: TextConstant.medium.copyWith(
                                            color: Colors.black87,
                                            fontSize: 13,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 2),
                                    FutureBuilder(
                                      future: LocalData.getData('phone'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data.toString(),
                                          style: TextConstant.medium.copyWith(
                                            color: Colors.black87,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 2),
                                    FutureBuilder(
                                      future: LocalData.getData('phone'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          "{Nomor Member}",
                                          style: TextConstant.medium.copyWith(
                                            color: Colors.black87,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
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
                            FutureBuilder(
                              future: Future.wait([
                                LocalData.getData('point'),
                                LocalData.getData('max_point'),
                              ]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(); // Loading indicator
                                } else if (snapshot.hasError) {
                                  return Text(
                                      "Error: ${snapshot.error}"); // Tangani error dengan aman
                                } else if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return Text("No data available");
                                }

                                var point = snapshot.data![0];
                                var balance = snapshot.data![1];
                                return Expanded(
                                    child: itemMenu(
                                        point: true, value: [point, balance]));
                              },
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
                  // categoryData.isNotEmpty
                  //     ? categoryColumn(categoryData)
                  //     : Container(),

                  SizedBox(height: 80.v)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getCompan() async {
    try {
      final response =
          await http.get(Uri.parse('${API.BASE_URL}/get_compan.php'));

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
    return Container(
      margin: EdgeInsets.all(8.adaptSize),
      child: point
          ? Banner(
              message: (int.parse(value![1]) < vipTarget) ? 'Basic' : 'VIP',
              textDirection: TextDirection.ltr,
              location: BannerLocation.topStart,
              color: (int.parse(value[1]) < vipTarget)
                  ? Colors.blue
                  : const Color.fromARGB(255, 255, 166, 0),
              child: Container(
                decoration: decoration,
                margin: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5.v),
                child: Row(
                  mainAxisAlignment: (int.parse(value[1]) < vipTarget)
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Points",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: (int.parse(value[1]) < vipTarget)
                                ? 12.adaptSize
                                : 14.adaptSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          value != null &&
                                  value.isNotEmpty &&
                                  value[0].isNotEmpty
                              ? value[0]
                              : '0',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: (int.parse(value[1]) < vipTarget)
                                ? 24.adaptSize
                                : 28.adaptSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (int.parse(value[1]) < vipTarget)
                          Column(
                            children: [
                              SizedBox(
                                width: 100.h,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Basic',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 10.adaptSize),
                                    ),
                                    Text(
                                      'VIP',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 10.adaptSize),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5.h), // Tambahkan sedikit spasi
                              SizedBox(
                                width: 100.h,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: LinearProgressIndicator(
                                    value: (value != null && value.isNotEmpty)
                                        ? (double.tryParse(value[1]) ?? 0) /
                                            vipTarget
                                        : 0,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ), // Jika sudah VIP, tidak ditampilkan
                      ],
                    ),
                    if (int.parse(value[1]) < vipTarget)
                      Container(width: 2, height: 75, color: Colors.grey),
                    if (int.parse(value[1]) < vipTarget)
                      Column(
                        mainAxisSize: MainAxisSize.min, // Tambahkan ini
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(children: [
                            Text(
                              "Road To VIP",
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${vipTarget - int.parse(value[1])}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.green,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' Point To Go',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ])
                        ],
                      ),
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
          future: LocalData.getData('kodec'),
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
                            if (isQRCode) // Display text only for QR Code
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
