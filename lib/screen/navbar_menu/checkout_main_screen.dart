import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/gabriel/checkouts/show_items_screen/show_items_screen.dart';
import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:e_commerce/screen/gabriel/notifications/item_screen.dart';
import 'package:e_commerce/screen/navbar_menu/request_item/request_item_screen/request_item_screen.dart';
import 'package:e_commerce/widget/material/button.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';

import 'dart:async';

class CheckoutMainScreen extends StatefulWidget {
  const CheckoutMainScreen({super.key});

  @override
  State<CheckoutMainScreen> createState() => _CheckoutMainScreenState();
}

class _CheckoutMainScreenState extends State<CheckoutMainScreen> {
  List<dynamic> productData = [];
  TextEditingController searchController = TextEditingController();
  String selectedSortOption = 'name_asc';
  final List<Map<String, String>> sortOptions = [
    {'value': 'name_asc', 'label': 'Nama A-Z'},
    {'value': 'name_desc', 'label': 'Nama Z-A'},
    {'value': 'price_asc', 'label': 'Point Terendah'},
    {'value': 'price_desc', 'label': 'Point Tertinggi'},
    {'value': 'quantity_asc', 'label': 'Stok Terendah'},
    {'value': 'quantity_desc', 'label': 'Stok Tertinggi'},
  ];

  // Pagination variables
  int currentPage = 1;
  int lastPage = 1;
  int totalItems = 0;
  bool isLoadingMore = false;
  bool hasMoreData = true;

  ScrollController scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) loadInitialData();
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMoreData) {
        loadMoreData();
      }
    }
  }

  Future<void> loadInitialData() async {
    await Future.delayed(Duration(milliseconds: 500));

    if (await LocalData.getDataBool('isLoading') == true && mounted) {
      DialogConstant.loading(context, 'Loading...');
    }
    currentPage = 1;
    productData.clear();
    await getProductData(page: 1);

    if (mounted) {
      Navigator.of(context).pop();
      LocalData.saveDataBool('isLoading', false);
    }
  }

  Future<void> loadMoreData() async {
    if (currentPage < lastPage) {
      setState(() {
        isLoadingMore = true;
      });
      await getProductData(page: currentPage + 1);
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<void> getProductData({int page = 1}) async {
    String compan_code = 'all';
    Map<String, dynamic> fetchData = {};

    if (await LocalData.containsKey('compan_code')) {
      compan_code = await LocalData.getData('compan_code');
      String username = await LocalData.getData('user');
      String companCode = await LocalData.getData('compan_code');

      if (companCode.isNotEmpty) {
        compan_code = companCode;
      }

      try {
        final uri = Uri.parse("$db/api/poin/checkouts-data").replace(
          queryParameters: {
            'username': username,
            'compan_code': compan_code,
            'search': searchController.text,
            'sort': selectedSortOption,
            'per_page': '10',
            'page': page.toString(),
          },
        );
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final transactions = data['initData'] as Map<String, dynamic>;
          fetchData = transactions;
        } else {
          throw Exception('Failed to load transaction data');
        }
      } catch (e) {
        fetchData = {};
      }
    } else {
      fetchData = {};
    }

    if (mounted) {
      setState(() {
        if (fetchData['productData'] != null) {
          final paginatedData = fetchData['productData'];

          if (paginatedData is Map) {
            // Handle paginated response
            currentPage = paginatedData['current_page'] ?? 1;
            lastPage = paginatedData['last_page'] ?? 1;
            totalItems = paginatedData['total'] ?? 0;
            hasMoreData = currentPage < lastPage;

            List<dynamic> newProducts = (paginatedData['data'] ?? []).toList();

            if (page == 1) {
              productData = newProducts;
            } else {
              productData.addAll(newProducts);
            }
          } else {
            // Handle non-paginated response (fallback)
            productData = (fetchData['productData'] ?? []).toList();
            hasMoreData = false;
          }
        }
      });
    }
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      loadInitialData();
    });
  }

  void onSortChanged(String value) {
    setState(() {
      selectedSortOption = value;
    });
    loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WidgetHelper.appbarWidget(
        Text(
          'List Hadiah',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(16),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search product...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon:
                                    Icon(Icons.close, color: Colors.grey[700]),
                                onPressed: () {
                                  setState(() {
                                    searchController.clear();
                                  });
                                  loadInitialData();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                      style: TextStyle(fontSize: 16),
                      onChanged: onSearchChanged,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4),
              IconButton(
                onPressed: () => Get.to(ShowItemsScreen()),
                style: IconButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(12),
                  minimumSize: Size(24, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.center,
                  backgroundColor: const Color(0xFFF0830F),
                  foregroundColor: const Color(0xFFFFFFFF),
                ),
                icon: Icon(Icons.shopping_cart_checkout_outlined),
              ),
              SizedBox(width: 4),
              IconButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: sortOptions.map((option) {
                            return RadioListTile<String>(
                              title: Text(option['label']!),
                              value: option['value']!,
                              groupValue: selectedSortOption,
                              onChanged: (value) {
                                Navigator.pop(context);
                                onSortChanged(value!);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                style: IconButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(12),
                  minimumSize: Size(24, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.center,
                  backgroundColor: const Color(0xFFF0830F),
                  foregroundColor: const Color(0xFFFFFFFF),
                ),
                icon: Icon(Icons.filter_alt_outlined),
              ),
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadInitialData,
              child: ListView(
                controller: scrollController,
                children: [
                  ...productRow(productData),
                  if (isLoadingMore)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (!hasMoreData && productData.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Semua produk telah ditampilkan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  if (productData.isEmpty && !isLoadingMore)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Tidak ada produk ditemukan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
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
              SizedBox(width: 16),
              if (i + 1 < productData.length)
                Expanded(
                  child: _buildProductCard(context, productData[i + 1]),
                )
              else
                Expanded(child: Container()),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    return Container(
      height: 300,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: product['quantity'] < 1 ? Colors.grey.shade200 : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFF0830F),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          product['quantity'] < 1
              ? Get.to(RequestItemScreen(data: product.map((key, value) {
                  return MapEntry(key, value.toString());
                })))
              : Get.to(ItemScreen(data: product.map((key, value) {
                  return MapEntry(key, value.toString());
                })));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImageView(
              imagePath:
                  "${API.BASE_URL}/images/hadiah_stiker/${product['image_url']}",
              height: 150,
              width: double.infinity,
              alignment: Alignment.center,
            ),
            SizedBox(height: 12),
            Text(
              product['nama'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.amber),
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  '${product['price']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
