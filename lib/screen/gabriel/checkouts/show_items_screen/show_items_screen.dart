import 'dart:convert';

import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/gabriel/checkouts/show_items_screen/widgets/list1_item_widget.dart';
import 'package:e_commerce/screen/home/landing_home.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../core/app_export.dart';
import 'package:http/http.dart' as http;

class ShowItemsScreen extends StatefulWidget {
  static int countWidget = 0;

  @override
  _ShowItemsScreenState createState() => _ShowItemsScreenState();
}

class _ShowItemsScreenState extends State<ShowItemsScreen> {
  List<dynamic> displayedItems = [];
  List<dynamic> selectedItems = [];
  late var productData;
  int totalPrice = 0;
  bool isLoading = false;
  String name = '';
  int point = 0;
  bool checkProduct = false;
  String truncateText(String text, {int maxLength = 15}) {
    return text.length > maxLength
        ? "${text.substring(0, maxLength)}..."
        : text;
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
    await getFullName();
    Get.back();
  }

  Future<void> getFullName() async {
    final points = await LocalData.getData('point');
    final pointLama = await LocalData.getData('prev_point');

    setState(() {
      name = int.parse(pointLama) >= int.parse(points)
          ? 'Anda menggunakan Poin Periode Sebelumnya'
          : 'Anda menggunakan poin periode saat ini';
      point = int.parse(pointLama) >= int.parse(points)
          ? int.parse(pointLama)
          : int.parse(points);
    });
    await _sortInitialData();
  }

  Future<void> _sortInitialData() async {
    selectedItems = [];
    if (await LocalData.containsKey('cart')) {
      final datas = jsonDecode(await LocalData.getData('cart'));
      final compan = await LocalData.getData('compan_code');
      final listData = await CheckoutsData.getInitData(compan);
      print(datas);
      productData = listData['productData'];
      if (datas.keys.contains(compan)) {
        List<int> uniquePriorityOrder = [];
        for (String data in datas[compan]) {
          if (!uniquePriorityOrder.contains(int.parse(data))) {
            uniquePriorityOrder.add(int.parse(data));
          }
        }
        uniquePriorityOrder.sort();
        setState(() {
          checkProduct = true;
          selectedItems = [];

          productData.sort((a, b) {
            int productIdA =
                a["kode"] is String ? int.parse(a["kode"]) : a["kode"];
            int productIdB =
                b["kode"] is String ? int.parse(b["kode"]) : b["kode"];

            int indexA = uniquePriorityOrder.indexOf(productIdA);
            int indexB = uniquePriorityOrder.indexOf(productIdB);

            if (indexA == -1) indexA = 9999;
            if (indexB == -1) indexB = 9999;

            return indexA.compareTo(indexB);
          });

          displayedItems = productData.toList();
        });
      } else {
        setState(() {
          checkProduct = false;
          displayedItems = productData.toList();
        });
      }
    }
  }

  void _onQuantityChanged(dynamic updatedData) async {
    final points = await LocalData.getData('point');
    final pointLama = await LocalData.getData('prev_point');

    setState(() {
      int index = displayedItems
          .indexWhere((item) => (item['kode']) == updatedData['kode']);
      if (index != -1) {
        displayedItems[index] = updatedData;
      }
      if (!(updatedData['quantity'] is int))
        updatedData['quantity'] = int.parse(updatedData['quantity']);

      if (updatedData['quantity'] > 0) {
        selectedItems
            .removeWhere((item) => item['kode'] == updatedData['kode']);
        selectedItems.add(updatedData);
      } else {
        selectedItems
            .removeWhere((item) => item['kode'] == updatedData['kode']);
      }
      totalPrice = selectedItems.fold(
          0,
          (sum, item) =>
              sum +
              (int.tryParse(item['price'].toString()) ?? 0) *
                  (int.tryParse(item['quantity_selected'].toString()) ?? 0));
      name = int.parse(pointLama) >= totalPrice
          ? 'Anda menggunakan poin periode sebelumnya'
          : 'Anda menggunakan poin periode saat ini';
      point = int.parse(pointLama) >= totalPrice
          ? int.parse(pointLama)
          : int.parse(points);
    });
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    bool color = true;
    return Scaffold(
      backgroundColor: appTheme.whiteA700,
      appBar: WidgetHelper.appbarWidget(
        function: () => Get.back(),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: CustomTextStyle.titleSmallWhiteA700),
          Text(
            'Point: ${currencyFormatter.format(point)}',
            style: CustomTextStyle.titleSmallWhiteA700,
          )
        ]),
      ),
      body: checkProduct
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedItems.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayedItems.length) {
                        return Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      var widgetData = displayedItems[index];

                      return List1ItemWidget(
                        key: ValueKey(widgetData['kode']),
                        data: widgetData,
                        color: color = !color,
                        onQuantityChanged: _onQuantityChanged,
                      );
                    },
                  ),
                ),
                if (totalPrice > 0)
                  Container(color: Colors.transparent, height: 75.adaptSize),
              ],
            )
          : Center(
              child: Text('Tidak ada produk yang dipilih',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w900)),
            ),
      bottomSheet: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        height: totalPrice > 0 ? 75.adaptSize : 0,
        child: totalPrice > 0
            ? Padding(
                padding: EdgeInsets.all(10.adaptSize),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.h),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "Total Price: ",
                                style: CustomTextStyle.bodyMediumBlueGray600),
                            TextSpan(
                              text: currencyFormatter.format(totalPrice),
                              style: point < totalPrice
                                  ? CustomTextStyle.bodyLargeRed700
                                  : CustomTextStyle.bodyLargeGreen700,
                            ),
                          ],
                        ),
                      ),
                    ),
                    (point >= totalPrice)
                        ? Padding(
                            padding: EdgeInsets.only(right: 15.h),
                            child: IconButton(
                              icon: Icon(Icons.shopping_cart,
                                  color: appTheme.black900),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.shoppingCartScreen,
                                  arguments: selectedItems,
                                );
                              },
                            ),
                          )
                        : Text('Point tidak mencukupi',
                            style: CustomTextStyle.bodyLargeRed700),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
