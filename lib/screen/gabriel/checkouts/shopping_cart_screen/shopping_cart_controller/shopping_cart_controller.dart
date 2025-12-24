import 'dart:convert';

import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:e_commerce/screen/home/landing_home.dart';
import 'package:get/get.dart';

class ShoppingCartController {
  Future<void> postTransactions({
    BuildContext? context,
    void Function(dynamic result, dynamic exception)? callback,
    Map<String, dynamic>? postTransaction,
    List<dynamic>? postTransactionDetail,
  }) async {
    final header = <String, String>{
      'Content-Type': 'application/json',
    };

    final username = await LocalData.getData("user");
    final companCode = await LocalData.getData('compan_code');

    // Siapkan items dari postTransactionDetail
    final items = postTransactionDetail!.map((transaction) {
      final price = transaction['price'];
      final quantity = transaction['quantity_selected'];
      return {
        'kode': transaction['kode'],
        'quantity': quantity,
        'total_price': price * quantity,
        'price': price,
      };
    }).toList();
    // Gabungkan semua data ke postTransaction
    postTransaction!['username'] = username;
    postTransaction['items'] = items;
    postTransaction['compan_code'] = companCode;

    postTransaction['datetime'] = DateTime.now().toIso8601String();
    API.basePost('/api/poin/update-transactions', postTransaction, header, true,
        (result, error) async {
      if (error != null) {
        callback?.call(null, error);
      } else {
        if (result['error'] != '') {
          final cart = jsonDecode(await LocalData.getData('cart'));
          cart.remove(companCode);
          LocalData.saveData('cart', jsonEncode(cart));
          int currentPoint = int.parse(await LocalData.getData('point'));
          int currentPointLama =
              int.parse(await LocalData.getData('prev_point'));
          int totalHarga =
              items.fold(0, (sum, item) => sum + item['total_price'] as int);
          LocalData.saveData(
              postTransaction['per_sekarang'] ? 'point' : 'prev_point',
              ((postTransaction['per_sekarang']
                          ? currentPoint
                          : currentPointLama) -
                      totalHarga)
                  .toString());
        }

        Get.offAll(LandingHome());
        callback?.call(result, null);
      }
    });
  }
}
