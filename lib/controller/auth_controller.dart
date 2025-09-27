import 'dart:convert';

import 'package:e_commerce/api/notification_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../api/api.dart';
import '../constant/dialog_constant.dart';
import '../utils/local_data.dart';
import 'dart:async';

class AuthController extends GetxController {
  RxBool openPassLogin = true.obs;
  RxBool openPassOTP1 = true.obs;
  RxBool openPassOTP2 = true.obs;

  // RxString userName = "".obs;
  TextEditingController edtNama = TextEditingController();
  TextEditingController edtEmail = TextEditingController();
  TextEditingController edtUsername = TextEditingController();
  TextEditingController edtPass = TextEditingController();
  TextEditingController edtPhone = TextEditingController();
  TextEditingController edtConfirmPass = TextEditingController();
  TextEditingController changePass = TextEditingController();
  TextEditingController verifyCode = TextEditingController();
  TextEditingController otpCode = TextEditingController();

  List maskEmail = [];

  changeOpenPassLogin(bool val) {
    openPassLogin.value = val;
  }

  viewPassOTP(int tipe, bool val) {
    tipe == 1 ? openPassOTP1.value = val : openPassOTP2.value = val;
  }

  validation({BuildContext? context, void callback(result, exception)?}) {
    if (edtPhone.text == '') {
      DialogConstant.alertError('Nomor Telephone tidak boleh kosong!');
    } else if (edtPass.text == '') {
      DialogConstant.alertError('Password tidak boleh kosong!');
    } else {
      postLogin(
          context: context,
          callback: (result, error) => callback!(result, error));
    }
  }

  postLogin({BuildContext? context, void callback(result, exception)?}) {
    DialogConstant.loading(context!, 'Loading...');

    var post = Map<String, dynamic>();
    var header = Map<String, String>();

    header['Content-Type'] = 'application/json';
    post['phone'] = edtPhone.text;
    post['password'] = edtPass.text;
    post['fcmToken'] = NotificationApi.fCMToken == ''
        ? 'dawbhdbawjbdawjbdhwbawjbawjbdja'
        : NotificationApi.fCMToken;

    bool isCompleted = false;

    // Timeout timer - akan dipanggil setelah 20 detik
    Timer timeoutTimer = Timer(Duration(seconds: 20), () {
      if (!isCompleted) {
        isCompleted = true;
        Get.back(); // Close loading dialog
        callback!(
            null, 'Request timed out. Please check your internet connection.');
      }
    });

    API.basePost('/api/poin/login', post, header, true, (result, error) {
      if (!isCompleted) {
        isCompleted = true;
        timeoutTimer
            .cancel(); // Cancel timeout timer karena response sudah diterima

        // Close loading dialog immediately
        Get.back();
        if (result != null) {
          if (result['error'] == true) {
            callback!(null, result['message']);

            return;
          }

          // Proses data tanpa delay
          try {
            List dataUser = result['data'];
            if (dataUser.length > 1) {
              LocalData.saveData('detailKTP', jsonEncode(dataUser[1]));
            }
            LocalData.saveData('full_name', dataUser[0]['name']);
            LocalData.saveData('user', dataUser[0]['username'] ?? "");
            LocalData.saveData('kodec', dataUser[0]['kodec'] ?? "");
            LocalData.saveData(
                'max_point', dataUser[0]['max_point'].toString());
            LocalData.saveData('loginDate', DateTime.now().toString());
            LocalData.saveData('password', post['password'] ?? "");
            LocalData.saveData('email', dataUser[0]['email'] ?? "");
            LocalData.saveData('address', dataUser[0]['default_address'] ?? "");
            LocalData.saveData('phone', dataUser[0]['phone'] ?? "");
            LocalData.saveData('point', dataUser[0]['point'].toString());
            LocalData.saveData(
                'chance', dataUser[0]['spin_chance'].toString() ?? "");
            LocalData.saveData(
                'profile_picture', dataUser[0]['profile_path'] ?? "");
            LocalData.removeData('compan_code');

            callback!(result, null);
          } catch (e) {
            print('Error processing login data: $e');
            callback!(null, 'Gagal untuk Memproses Data');
          }
        } else if (error != null) {
          print('Login error: $error');
          callback!(null, 'Mohon Maaf Ada Kesalahan');
        } else {
          callback!(null, 'Unknown error occurred');
        }
      }
    });
  }

  validationRegister(
      {BuildContext? context, void callback(result, exception)?}) {
    if (edtNama.text.isEmpty) {
      DialogConstant.alertError('Nama tidak boleh kosong!');
    } else if (edtPhone.text.isEmpty) {
      DialogConstant.alertError('Nomor Telephone tidak boleh kosong!');
    } else if (edtEmail.text.isEmpty) {
      DialogConstant.alertError('Email tidak boleh kosong!');
    } else if (edtPass.text.isEmpty) {
      DialogConstant.alertError('Password tidak boleh kosong!');
    } else if (!RegExp(
            r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(edtPass.text)) {
      DialogConstant.alertError(
          'Password harus minimal 8 karakter dan mengandung huruf, angka, serta simbol!');
    } else if (edtConfirmPass.text.isEmpty) {
      DialogConstant.alertError('Konfirmasi Password tidak boleh kosong!');
    } else if (edtPass.text != edtConfirmPass.text) {
      DialogConstant.alertError('Password dan Konfirmasi Password tidak sama!');
    } else {
      postRegister(
          context: context,
          callback: (result, error) {
            if (callback != null) {
              callback(result, error);
            }
          });
    }
  }

  postRegister({BuildContext? context, void callback(result, exception)?}) {
    var post = new Map<String, dynamic>();
    var header = new Map<String, String>();

    header['Content-Type'] = 'application/json';
    post['nama'] = edtNama.text;
    post['email'] = edtEmail.text;
    post['password'] = edtPass.text;
    post['phone'] = edtPhone.text;

    DialogConstant.loading(context!, 'Loading...');

    API.basePost('/api/poin/register', post, header, true, (result, error) {
      Get.back();
      if (error != null) {
        callback!(null, error);
      }
      if (result != null) {
        callback!(result, null);
      }
    });
  }

  validationVerify({BuildContext? context, void callback(result, exception)?}) {
    if (verifyCode.text == '') {
      Get.back();
      DialogConstant.alertError('Kode verifikasi kosong!');
    } else {
      postVerifyWhatsapp(
          context: context,
          callback: (result, error) => callback!(result, error));
    }
  }

  sendVerifyCode(
      {BuildContext? context,
      void callback(result, exception)?,
      Map<String, dynamic>? post}) async {
    var header = new Map<String, String>();
    var post = Map<String, dynamic>();
    header['Content-Type'] = 'application/json';
    post['userx'] = await LocalData.getData('user');

    DialogConstant.loading(context!, 'Mengirim kode Verifikasi...');

    API.basePost('/api/poin/send-auth', post, header, true, (result, error) {
      print(result);
      print(error);
      Get.back();
      if (error != null) {
        callback!(null, error);
      }
      if (result != null) {
        callback!(result, null);
      }
    });
  }

  postVerifyWhatsapp(
      {BuildContext? context, void callback(result, exception)?}) async {
    var post = new Map<String, dynamic>();
    var header = new Map<String, String>();

    header['Content-Type'] = 'application/json';
    post['userx'] = await LocalData.getData('user');
    post['codex'] = verifyCode.text;

    DialogConstant.loading(context!, 'Check Verification...');

    API.basePost('/api/poin/get-verify', post, header, true, (result, error) {
      Get.back();
      if (error != null) {
        callback!(null, error);
      }
      if (result != null) {
        callback!(result, null);
      }
    });
  }

  checkEmail({BuildContext? context, void callback(result, exception)?}) async {
    var post = new Map<String, dynamic>();
    var header = new Map<String, String>();

    header['Content-Type'] = 'application/json';
    post['emailx'] = await LocalData.getData('email');
    DialogConstant.loading(context!, 'Sending OTP...');
    API.basePost('/api/poin/check-email', post, header, true, (result, error) {
      Get.back();
      if (error != null) {
        callback!(null, error);
      }
      if (result != null) {
        callback!(result, null);
      }
    });
  }

  sendOtpSMS({BuildContext? context, void callback(result, exception)?}) async {
    var post = new Map<String, dynamic>();
    var header = new Map<String, String>();

    header['Content-Type'] = 'application/json';
    post['emailx'] = await LocalData.getData('email');

    DialogConstant.loading(context!, 'Sending OTP...');

    API.basePost('/api/poin/send-auth', post, header, true, (result, error) {
      Get.back();
      if (error != null) {
        callback!(null, error);
      }
      if (result != null) {
        callback!(result, null);
      }
    });
  }

  validationOtp({BuildContext? context, void callback(result, exception)?}) {
    if (otpCode.text == '') {
      DialogConstant.alertError('Kode OTP kosong!');
    } else if (changePass.text == '') {
      DialogConstant.alertError('Password baru tidak boleh kosong!');
    } else {
      postOtpCode(
          context: context,
          callback: (result, error) => callback!(result, error));
    }
  }

  postOtpCode(
      {BuildContext? context, void callback(result, exception)?}) async {
    var post = new Map<String, dynamic>();
    var header = new Map<String, String>();

    header['Content-Type'] = 'application/json';
    if (await LocalData.containsKey('user')) {
      post['userx'] = await LocalData.getData('user');
    } else {
      post['emailx'] = await LocalData.getData('email');
    }
    post['newpass'] = changePass.text;
    post['codex'] = otpCode.text;
    print(post);
    DialogConstant.loading(context!, 'Verifying OTP..');

    API.basePost('/api/poin/get-verify', post, header, true, (result, error) {
      Get.back();
      if (error != null) {
        callback!(null, error);
      }
      if (result != null) {
        callback!(result, null);
      }
    });
  }
}
