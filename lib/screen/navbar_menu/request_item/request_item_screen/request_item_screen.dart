import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/gabriel/request_item/request_history_screen/request_history_screen.dart';
import 'package:e_commerce/utils/local_data.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:e_commerce/api/api.dart';

class RequestItemScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  RequestItemScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<RequestItemScreen> createState() => _RequestItemScreenState();
}

class _RequestItemScreenState extends State<RequestItemScreen> {
  final TextEditingController _quantityController = TextEditingController();

  int requestedQuantity = 1;
  int userPoints = 0;
  int maxQuantity = 0;

  // Company/Branch related variables
  List<Map<String, dynamic>> companyCode = [];
  String selectedCompanyCode = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _quantityController.text = '1';
    });
  }

  Future<void> _initializeData() async {
    DialogConstant.loading(context, "Memuat data...");
    await _loadUserPoints();
    await _getCompanies();
    Get.back();
  }

  Future<void> _getCompanies() async {
    try {
      await LocalData.getData('compan_code').then((value) {
        if (value.isNotEmpty) {
          selectedCompanyCode = value;
        }
      });
      final response =
          await http.get(Uri.parse('${API.BASE_URL}/api/poin/company'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          companyCode = [
            {'compan_code': 'all', 'name': 'Pilih Cabang Pengambilan'}
          ];
          companyCode.addAll(jsonData.map((outlet) {
            return {
              'compan_code': outlet['compan_code'],
              'name': outlet['name']
            };
          }).toList());
        });
      } else {
        throw Exception('Failed to load companies');
      }
    } catch (e) {
      print('Error loading companies: $e');
    }
  }

  Future<void> _loadUserPoints() async {
    try {
      final points = await LocalData.getData('point');
      print("User points loaded: $points");
      if (widget.data['price'] is int) {
        widget.data['price'] = widget.data['price'];
      } else if (widget.data['price'] is String) {
        widget.data['price'] = int.tryParse(widget.data['price']) ?? 0;
      } else if (widget.data['price'] is double) {
        widget.data['price'] = (widget.data['price'] as double).toInt();
      }
      int itemPrice = widget.data['price'];
      setState(() {
        userPoints = int.tryParse(points) ?? 0;
        maxQuantity = itemPrice > 0 ? (userPoints ~/ itemPrice) : 0;

        // Set initial quantity to 1 if possible, 0 if not enough points
        if (maxQuantity > 0) {
          requestedQuantity = 1;
          _quantityController.text = '1';
        } else {
          requestedQuantity = 0;
          _quantityController.text = '0';
        }
      });
    } catch (e) {
      print(e);
      setState(() {
        userPoints = 0;
        maxQuantity = 0;
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    if (requestedQuantity < maxQuantity) {
      setState(() {
        requestedQuantity++;
        _quantityController.text = requestedQuantity.toString();
      });
    }
  }

  void _decrementQuantity() {
    if (requestedQuantity > 0) {
      setState(() {
        requestedQuantity--;
        _quantityController.text = requestedQuantity.toString();
      });
    }
  }

  void _showDialog() {
    if (requestedQuantity <= 0) {
      DialogConstant.alert("Pilih jumlah item yang ingin di-request");
      return;
    }

    if (selectedCompanyCode.isEmpty) {
      DialogConstant.alert("Pilih cabang pengambilan terlebih dahulu");
      return;
    }

    final totalCost = requestedQuantity * (widget.data['price'] ?? 0);
    final selectedBranch = companyCode.firstWhere(
      (company) => company['compan_code'] == selectedCompanyCode,
      orElse: () => {'name': 'Unknown'},
    );

    DialogConstant.showConfirmationDialog(
      title: "Konfirmasi Request",
      message: "Request ${requestedQuantity}x ${widget.data['nama']}\n"
          "Total: ${totalCost} Points\n"
          "Cabang: ${selectedBranch['name']}\n\n"
          "Lanjutkan request?",
      confirmText: "Ya, Kirim",
      cancelText: "Batal",
      icon: Icons.send,
      confirmColor: Colors.blue[600],
      onConfirm: () {
        DialogConstant.loading(context, "Mengirim request...");
        _submitRequest();
      },
      onCancel: () {
        print("Request dibatalkan");
      },
    );
  }

  void _submitRequest() async {
    final totalCost = requestedQuantity * (widget.data['price'] ?? 0);
    final selectedBranch = companyCode.firstWhere(
      (company) => company['compan_code'] == selectedCompanyCode,
      orElse: () => {'name': 'Unknown'},
    );

    print("Item: ${widget.data['nama']}");
    print("Quantity: $requestedQuantity");
    print("Total Cost: $totalCost points");
    print("Branch: ${selectedBranch['name']} (${selectedCompanyCode})");
    final name = await LocalData.getData('user');
    final data = {
      'product_name': widget.data['nama'] is String ? widget.data['nama'] : '',
      'quantity': requestedQuantity,
      'username': name,
      'compan_code': selectedCompanyCode,
      'kode': widget.data['kode'],
      'price': totalCost,
    };
    var header = <String, String>{'Content-Type': 'application/json'};
    API.basePost('/api/poin/request-item', data, header, true,
        (result, error) async {
      if (error != null) {
        DialogConstant.alertError(
            'Request Item tidak berhasil', error['message']);
      }
      if (result != null) {
        if (result['error'] == true) {
          DialogConstant.alertError(
              'Request Item tidak berhasil', result['message']);
          return;
        }
        Get.back();
        DialogConstant.showSuccessAlert(
            title: 'Permintaan Berhasil',
            message:
                'Item berhasil diminta! Silahkan menunggu barang untuk dikonfirmasi',
            onComplete: () {
              Get.to(RequestHistoryScreen());
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemData = widget.data;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Request Item",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[700]!,
                    Colors.blue[500]!,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Request Item Baru",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Point Anda: $userPoints",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Item Information Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Informasi Item",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item Image
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: itemData['image_url'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/${itemData['image_url']}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[400],
                                        size: 40,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.image,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                        ),

                        SizedBox(width: 16),

                        // Item Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemData['nama'] ?? 'Nama Item',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.green[200]!,
                                  ),
                                ),
                                child: Text(
                                  "${itemData['price']?.toString() ?? '0'} Points",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Branch Selection Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Cabang Pengambilan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCompanyCode.isEmpty
                              ? null
                              : selectedCompanyCode,
                          hint: Text(
                            "Pilih Cabang Pengambilan",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          isExpanded: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[600],
                          ),
                          items: companyCode.map((company) {
                            return DropdownMenuItem<String>(
                              value: company["compan_code"],
                              child: Text(
                                company["name"]!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: company["compan_code"] == ''
                                      ? Colors.grey[600]
                                      : Colors.grey[800],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null && newValue.isNotEmpty) {
                              setState(() {
                                selectedCompanyCode = newValue;
                                LocalData.saveData(
                                    'compan_code', selectedCompanyCode);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Quantity Selector Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Jumlah Request",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (maxQuantity <= 0)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[600],
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Point Tidak Mencukupi",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Anda memerlukan minimal ${itemData['price']} points",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Text(
                        "Maksimal yang dapat di-request: $maxQuantity item",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _decrementQuantity,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: requestedQuantity > 0
                                    ? Colors.red[50]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: requestedQuantity > 0
                                      ? Colors.red[200]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Icon(
                                Icons.remove,
                                color: requestedQuantity > 0
                                    ? Colors.red[600]
                                    : Colors.grey[400],
                                size: 24,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _quantityController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onChanged: (value) {
                                    final qty = int.tryParse(value) ?? 0;
                                    if (qty >= 0 && qty <= maxQuantity) {
                                      setState(() {
                                        requestedQuantity = qty;
                                      });
                                    } else {
                                      _quantityController.text =
                                          requestedQuantity.toString();
                                    }
                                  },
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Total: ${requestedQuantity * (itemData['price'] ?? 0)} Points",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          GestureDetector(
                            onTap: _incrementQuantity,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: requestedQuantity < maxQuantity
                                    ? Colors.green[50]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: requestedQuantity < maxQuantity
                                      ? Colors.green[200]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Icon(
                                Icons.add,
                                color: requestedQuantity < maxQuantity
                                    ? Colors.green[600]
                                    : Colors.grey[400],
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),

      // Submit Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: (maxQuantity > 0 &&
                        requestedQuantity > 0 &&
                        selectedCompanyCode.isNotEmpty &&
                        selectedCompanyCode != 'all')
                    ? Colors.blue[600]
                    : Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: (maxQuantity > 0 &&
                      requestedQuantity > 0 &&
                      selectedCompanyCode.isNotEmpty &&
                      selectedCompanyCode != 'all')
                  ? _showDialog
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    maxQuantity <= 0
                        ? "Point Tidak Mencukupi"
                        : requestedQuantity <= 0
                            ? "Pilih Jumlah"
                            : selectedCompanyCode.isEmpty ||
                                    selectedCompanyCode == 'all'
                                ? "Pilih Cabang"
                                : "Kirim Request",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
