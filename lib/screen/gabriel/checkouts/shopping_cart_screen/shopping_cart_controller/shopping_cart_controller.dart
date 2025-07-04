import 'dart:convert';

import 'package:e_commerce/screen/auth/second_splash.dart';
import 'package:e_commerce/screen/gabriel/core/app_export.dart';
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
        'compan_code': companCode
      };
    }).toList();

    // Gabungkan semua data ke postTransaction
    postTransaction!['username'] = username;
    postTransaction['items'] = items;

    API.basePost('/update_transaction.php', postTransaction, header, true,
        (result, error) async {
      if (error != null) {
        callback?.call(null, error);
      } else {
        // Update local point
        int currentPoint = int.parse(await LocalData.getData('point'));
        int totalHarga =
            items.fold(0, (sum, item) => sum + item['total_price'] as int);
        LocalData.saveData('point', (currentPoint - totalHarga).toString());

        // Hapus cart berdasarkan compan_code
        final cart = jsonDecode(await LocalData.getData('cart'));
        cart.remove(companCode);
        LocalData.saveData('cart', jsonEncode(cart));

        // Navigasi dan callback
        Get.back();
        Get.to(SecondSplash());
        callback?.call(result, null);
      }
    });
  }
}
