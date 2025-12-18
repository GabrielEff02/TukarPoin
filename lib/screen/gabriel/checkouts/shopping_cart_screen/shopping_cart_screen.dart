import 'dart:convert';

// import 'package:e_commerce/screen/ocr_ktp/view/home.dart';
import 'package:get/get.dart';

import '../../checkouts/shopping_cart_screen/shopping_cart_controller/shopping_cart_controller.dart';
import '../../../../constant/dialog_constant.dart';
import '../../core/app_export.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key, required this.items}) : super(key: key);

  final List<dynamic> items;

  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  late num totalQuantityFinal = 0;
  late num totalPriceFinal = 0;
  late int point;
  List<Map<String, dynamic>> companyCode = [];
  String selectedCompany = 'all';
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
  }

  Future<void> loadInitialData() async {
    DialogConstant.loading(context, 'Loading...');
    await getPoint();
    await getCompan();
    Get.back();
  }

  Future<void> getCompan() async {
    try {
      final response =
          await http.get(Uri.parse('${API.BASE_URL}/api/poin/company'));

      if (response.statusCode == 200) {
        // Mengonversi JSON response menjadi List<Map<String, dynamic>>
        List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          companyCode = [
            {'compan_code': 'all', 'name': 'Pilih Cabang'}
          ];
          companyCode.addAll(jsonData.map((outlet) {
            return {
              'compan_code': outlet['compan_code'],
              'name': outlet['name']
            };
          }).toList());
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<void> getPoint() async {
    final points = await LocalData.getData('point');
    setState(() {
      point = int.parse(points);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Keranjang Belanja",
          style: CustomTextStyle.titleLargeBlack900,
        ),
        actions: [
          IconButton(
              onPressed: () {
                showAreYouSureDialog(
                    context,
                    () => (selectedCompany != 'all')
                        ? submitItems(widget.items, totalPriceFinal, isChecked)
                        : DialogConstant.alertError('Transaksi Gagal',
                            'Harap pilih cabang pengambilan'));
              },
              icon: Icon(
                Icons.check,
                weight: 20.adaptSize,
                color: appTheme.green700,
              ))
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.v, vertical: 10.v),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: appTheme.gray30099,
                  borderRadius: BorderRadius.all(Radius.circular(10.h)),
                ),
                child: _showProductCards(context, widget.items),
              ),
            ),
            _buildStickyBottomSection(context),
          ],
        ),
      ),
    );
  }

  void submitItems(items, totalPriceFinal, isCheked) async {
    if (items.toString().isNotEmpty) {
      DialogConstant.loading(context, 'Transaction on Process...');

      Map<String, dynamic> postTransaction = {
        'total_amount': totalPriceFinal,
        'is_delivery': 0,
        'cabang_ambil': selectedCompany,
      };
      // if (await LocalData.containsKey('detailKTP')) {
      ShoppingCartController().postTransactions(
        context: context,
        callback: (result, error) {
          if (result != null && !result.containsKey('error')) {
            DialogConstant.showSuccessAlert(
                title: 'Transaksi Berhasil',
                message: 'Selamat anda berhasil menukarkan poin');
          } else {
            final msg = result?['error'] ?? error.toString();
            DialogConstant.alertError('Transaksi Gagal', msg);
          }
        },
        postTransaction: postTransaction,
        postTransactionDetail: items,
      );
      // } else {
      //   Get.to(KtpOCR(postTransaction: postTransaction, postDetail: items));
      // }
    }
  }

  Widget _buildStickyBottomSection(BuildContext context) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return Column(
      children: [
        // Card(
        //   margin: const EdgeInsets.symmetric(vertical: 8.0),
        //   child: Padding(
        //     padding: const EdgeInsets.all(16.0),
        //     child:
        //   ),
        // ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Price:',
                    style: CustomTextStyle.titleMediumBlack900),
                Text(currencyFormatter.format(totalPriceFinal),
                    style: CustomTextStyle.titleMediumRed700)
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance:', style: CustomTextStyle.titleMediumBlack900),
                Text(
                  currencyFormatter.format(point),
                  style: CustomTextStyle.titleMediumBlack900,
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Cabang Pengambilan:',
                        style: CustomTextStyle.titleMediumBlack900),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DropdownButton<String>(
                      hint: Text("Pilih Perusahaan"),
                      value: selectedCompany,
                      items: companyCode.map((company) {
                        return DropdownMenuItem<String>(
                          value:
                              company["compan_code"], // Menyimpan company_code
                          child: Text(company["name"]!), // Menampilkan name
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCompany = newValue!;
                        });
                        LocalData.saveData('compan_code', selectedCompany);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Row(
                //   children: [
                //     Checkbox(
                //       value: isChecked,
                //       onChanged: (bool? newValue) {
                //         setState(() {
                //           isChecked = newValue ?? false;
                //         });
                //       },
                //       activeColor: Colors.blue, // Warna saat checkbox dipilih
                //     ),
                //     Text(
                //       "Apakah pesanan anda ingin dikirim?",
                //       style: TextStyle(
                //           fontSize: 12,
                //           color: Colors.black87,
                //           fontWeight: FontWeight.w900),
                //     ),
                //   ],
                // ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Remain Balance:',
                        style: CustomTextStyle.titleMediumBlack900),
                    Text(
                      currencyFormatter.format(point - totalPriceFinal),
                      style: CustomTextStyle.titleMediumGreen700,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _showProductCards(BuildContext context, List<dynamic> items) {
    totalQuantityFinal = 0;
    totalPriceFinal = 0;
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    items.sort((a, b) => a['kode'].compareTo(b['kode']));
    List<Map<String, dynamic>> filteredItems = items
        .where((item) =>
            item['quantity_selected'] > 0) // Filter where quantity > 0
        .map((item) {
      return {
        'image': "${API.BASE_URL}/images/hadiah_stiker/${item['image_url']}",
        'product': item['nama'],
        'product description': item['deskripsi'],
        'quantity': item['quantity_selected'],
        'price': item['price'],
        'total price': item['price'] * item['quantity_selected']
      };
    }).toList();

    if (filteredItems.isNotEmpty) {
      List<Widget> cards = filteredItems.map((product) {
        setState(() {
          // Update total quantities and prices in setState
          totalQuantityFinal += product['quantity'];
          totalPriceFinal += product['total price'];
        });

        // Return product card widget
        return _cardProductWidget(product, currencyFormatter);
      }).toList();

      // Return ListView with the cards as children
      return ListView(children: cards);
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.notFoundScreen,
        arguments: AppRoutes.shoppingCartScreen,
      );
      return Container();
    }
  }

  Widget _cardProductWidget(
      Map<String, dynamic> product, NumberFormat currencyFormatter) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomImageView(
              imagePath: product['image'],
              width: 50,
              height: 50,
            ),
            SizedBox(width: 5.adaptSize),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      product['product'],
                      style: CustomTextStyle.titleSmallBlack900,
                    ),
                  ),
                  SizedBox(height: 3.adaptSize),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "\tprice: ${product['price']}",
                      style: CustomTextStyle.bodySmallBlack900,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "\tqty: ${product['quantity'].toString()}",
                      style: CustomTextStyle.bodySmallBlack900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5.adaptSize),
            Text(
              currencyFormatter.format(product['total price']),
              style: CustomTextStyle.titleMediumBlack900,
            ),
          ],
        ),
      ),
    );
  }

  void showAreYouSureDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text("Are you sure?"),
            ],
          ),
          content: Text("Are you sure you want to proceed with this action?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Call the confirmation action
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 70, 242, 216)),
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
