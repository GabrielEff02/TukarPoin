import 'dart:convert';
import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../core/app_export.dart';

class ItemScreenBackup extends StatefulWidget {
  final Map<String, dynamic> data;

  ItemScreenBackup({Key? key, required this.data}) : super(key: key);

  @override
  State<ItemScreenBackup> createState() => _ItemScreenBackupState();
}

class _ItemScreenBackupState extends State<ItemScreenBackup> {
  bool checkCompan = false;
  String selectedCompanyCode = 'all';
  List<Map<String, dynamic>> companyCode = [];

  Future<void> checkingCompan() async {
    final company = await LocalData.getData('compan_code');
    setState(() {
      if (company.isNotEmpty) selectedCompanyCode = company;
      if (selectedCompanyCode != 'all' && selectedCompanyCode.isNotEmpty) {
        checkCompan = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
  }

  Future<void> loadInitialData() async {
    DialogConstant.loading(context, 'Loading...');
    await checkingCompan();
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
          print(companyCode);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
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
                if (!checkCompan)
                  Column(
                    children: [
                      Text(
                        'Harap memilih Cabang terlebih Dahulu agar dapat melakukan transaksi!!!',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w900),
                      ),
                      Padding(padding: EdgeInsets.all(10..adaptSize)),
                    ],
                  ),
                DropdownButton<String>(
                  hint: Text("Pilih Perusahaan"),
                  value: selectedCompanyCode,
                  items: companyCode.map((company) {
                    return DropdownMenuItem<String>(
                      value: company["compan_code"], // Menyimpan company_code
                      child: Text(company["name"]!), // Menampilkan name
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCompanyCode = newValue!;
                    });
                    LocalData.saveData('compan_code', selectedCompanyCode);
                    loadInitialData();
                  },
                ),
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
                      // Price
                      Row(
                        children: [
                          Text(
                            'Point: ${widget.data['price'] is int ? currencyFormatter.format(widget.data['price'] ?? 0) : currencyFormatter.format(int.tryParse(widget.data['price']) ?? 0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Quantity
                      Row(
                        children: [
                          Icon(Icons.inventory, color: Colors.black54),
                          const SizedBox(width: 5),
                          Text(
                            'Quantity: ${(widget.data['quantity'] == 0) ? 'Habis' : widget.data['quantity'] ?? 0}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
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
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: getStockDetail(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Terjadi kesalahan saat mengambil data'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                                child: Text('Tidak ada outlet tersedia'));
                          } else {
                            final stockData = snapshot.data!;
                            return FutureBuilder(
                              future: LocalData.getData(
                                  'compan_code'), // Mengambil data 'compan_code'
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty ||
                                    snapshot.data! == 'all') {
                                  // Jika tidak ada data atau data kosong
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Stock:',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      ...stockData.map((item) {
                                        return Text(
                                          '${item['name']}: ${item['quantity']}',
                                          style: TextStyle(fontSize: 14),
                                        );
                                      }).toList(),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Stock:',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      ...stockData.map((item) {
                                        if (item['compan_code'] ==
                                            snapshot.data!) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16.0),
                                            child: Text(
                                              '${item['name']}: ${item['quantity']}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          );
                                        }
                                        return Container();
                                      }).toList(),
                                    ],
                                  );
                                }
                              },
                            );
                          }
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating Action Button with Animation using floatingActionButtonAnimator
      floatingActionButton: checkCompan
          ? FloatingActionButton(
              onPressed: () async {
                _bukaModalStok(widget.data['quantity'], widget.data['nama'],
                    widget.data['price']);
              },
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.shopping_cart, color: Colors.white),
            )
          : null,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
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
                    Center(
                      child: Text(
                        'Pilih Jumlah Stok',
                        style: TextStyle(
                            fontSize: 20.adaptSize,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20.adaptSize),
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 18.adaptSize, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.adaptSize),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Stok: $maxValue",
                              style: TextStyle(
                                fontSize: 16.adaptSize,
                              ),
                            ),
                            Text(
                              "Point: ${currencyFormatter.format(price * jumlah)}",
                              style: TextStyle(
                                  fontSize: 16.adaptSize, color: Colors.blue),
                            ),
                          ],
                        ),
                        Row(
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
                                backgroundColor: Colors.grey[300],
                              ),
                              child: Icon(Icons.remove, color: Colors.black),
                            ),
                            SizedBox(width: 5.adaptSize),
                            SizedBox(
                              width: 40,
                              child: TextField(
                                controller: jumlahController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
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
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5.adaptSize),
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
                                backgroundColor: Colors.grey[300],
                              ),
                              child: Icon(Icons.add, color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Map<String, dynamic> cardData = {};
                          if (await LocalData.containsKey('cart')) {
                            cardData =
                                jsonDecode(await LocalData.getData('cart'));
                          }
                          final compan = await LocalData.getData('compan_code');
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
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child:
                            Text('Konfirmasi', style: TextStyle(fontSize: 18)),
                      ),
                    )
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
