import 'dart:convert';
import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../core/app_export.dart';

class ItemScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  ItemScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  String selectedCompanyCode = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
  }

  Future<void> loadInitialData() async {
    DialogConstant.loading(context, 'Loading...');
    await Future.delayed(Duration(seconds: 1));
    Get.back();
  }

  NumberFormat currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Product Detail',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade200,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Main Content
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.all(10..adaptSize)),
                  Center(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.shade100,
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 10,
                            offset: Offset(-10, -10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CustomImageView(
                          imagePath:
                              '${API.BASE_URL}/images/hadiah_stiker/${widget.data['image_url']}',
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.7),
                          Colors.grey.shade200.withOpacity(0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.data['nama'] ?? 'Unknown Product',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.amber),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${widget.data['price'] is int ? currencyFormatter.format(widget.data['price'] ?? 0) : currencyFormatter.format(int.tryParse(widget.data['price']) ?? 0)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                            // Quantity
                            Row(
                              children: [
                                Icon(FontAwesomeIcons.boxesStacked,
                                    color: Colors.black54),
                                const SizedBox(width: 10),
                                Text(
                                  '${(widget.data['quantity'] == 0) ? 'Habis' : widget.data['quantity'] ?? 0}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            // Row(
                            //   children: (int.tryParse(widget.data['quantity']
                            //                   .toString()) ??
                            //               0) ==
                            //           0
                            //       ? [
                            //           Text(
                            //             'Mohon Maaf Stok Habis',
                            //             style: TextStyle(
                            //               fontSize: 16,
                            //               color: Colors.black87,
                            //             ),
                            //           ),
                            //         ]
                            //       : [
                            //           Text(
                            //             'Tersisa',
                            //             style: TextStyle(
                            //               fontSize: 16,
                            //               color: Colors.black87,
                            //             ),
                            //           ),
                            //           const SizedBox(width: 5),
                            //           Text(
                            //             widget.data['quantity'].toString(),
                            //             style: TextStyle(
                            //               fontSize: 16,
                            //               fontWeight: FontWeight.bold,
                            //               color: Colors.black87,
                            //             ),
                            //           ),
                            //           const SizedBox(width: 5),
                            //           Text(
                            //             'lagi',
                            //             style: TextStyle(
                            //               fontSize: 16,
                            //               color: Colors.black87,
                            //             ),
                            //           ),
                            //         ],
                            // )
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Description
                        Text(
                          widget.data['deskripsi'] ?? 'Tidak Ada Deskripsi.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Floating Action Button with Animation using floatingActionButtonAnimator
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _bukaModalStok(widget.data['quantity'], widget.data['nama'],
                widget.data['price']);
          },
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.shopping_cart, color: Colors.white),
        ));
  }

  Future<List<Map<String, dynamic>>> getStockDetail() async {
    try {
      final response = await http.get(Uri.parse(
          '${API.BASE_URL}/api/poin/stock-detail?kode=${widget.data['kode']}'));

      if (response.statusCode == 200) {
        // Mengonversi JSON response menjadi List<Map<String, dynamic>>
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((outlet) {
          return {
            'compan_code': outlet['compan_code'],
            'name': outlet['name'],
            'quantity': outlet['quantity'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  void _bukaModalStok(maxValue, String name, price) {
    maxValue = maxValue is String ? int.parse(maxValue) : maxValue;
    price = price is String ? int.parse(price) : price;
    int jumlah = 1;
    TextEditingController jumlahController =
        TextEditingController(text: jumlah.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Pastikan ini true
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void updateJumlah(int newJumlah) {
              setModalState(() {
                jumlah = newJumlah < 1 ? 1 : newJumlah;
                jumlahController.text = jumlah.toString();
              });
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(106, 239, 138, 30),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (jumlah >= 1) {
                                    updateJumlah(jumlah - 1);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(8.adaptSize),
                                  backgroundColor: const Color(0xFFF0830F),
                                ),
                                child: Icon(Icons.remove, color: Colors.white),
                              ),
                              Container(
                                width: 40,
                                child: TextField(
                                  controller: jumlahController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: 16.adaptSize,
                                      fontWeight: FontWeight.bold),
                                  onChanged: (value) {
                                    int? val = int.tryParse(value);
                                    if (val != null && val > 0) {
                                      if (val > maxValue) {
                                        updateJumlah(maxValue);
                                      } else {
                                        updateJumlah(val);
                                      }
                                    }
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 8.adaptSize),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (jumlah >= maxValue) {
                                    updateJumlah(maxValue);
                                  } else {
                                    updateJumlah(jumlah + 1);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(8.adaptSize),
                                  backgroundColor: const Color(0xFFF0830F),
                                ),
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Map<String, dynamic> cardData = {};
                            if (await LocalData.containsKey('cart')) {
                              cardData =
                                  jsonDecode(await LocalData.getData('cart'));
                            }
                            final compan =
                                await LocalData.getData('compan_code');
                            for (int i = 0; i < jumlah; i++) {
                              cardData
                                  .putIfAbsent(compan, () => [])
                                  .add(widget.data['kode']);
                            }
                            LocalData.saveData('cart', jsonEncode(cardData));
                            Get.back();
                            Get.toNamed(AppRoutes.showItemsScreen);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF0830F),
                            padding: EdgeInsets.symmetric(
                                vertical: 8.adaptSize,
                                horizontal: 12.adaptSize),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                          child: Text('Add to cart',
                              style: TextStyle(
                                  fontSize: 16.adaptSize, color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
