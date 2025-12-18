import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/controller/auth_controller.dart';
import 'package:e_commerce/screen/srg/security_screen.dart';
import 'package:e_commerce/utils/local_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/decoration_constant.dart';
import '../../constant/image_constant.dart';
import '../../constant/text_constant.dart';
import '../../widget/material/button_green_widget.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({Key? key, required this.metode}) : super(key: key);
  final String metode;
  AuthController logincontroller = new AuthController();

  @override
  Widget build(BuildContext context) {
    final metode = this.metode;
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () => Get.back(),
            child: Icon(CupertinoIcons.back, color: Colors.black87)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Image.asset(ImageConstant.ilus_forgot_pass,
                      height: size.height * 0.20)),
              SizedBox(height: 45),
              Text(
                'Lupa\nKata Sandi?',
                style: TextConstant.regular.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(height: 30),
              Text(
                'Jangan khawatir, Silahkan masukkan $metode yang terhubung dengan akun anda',
                style: TextConstant.regular
                    .copyWith(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 45),
              Container(
                child: Row(
                  children: [
                    Icon(metode == 'Email' ? Icons.person : Icons.phone,
                        size: 24, color: Colors.grey.shade400),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        height: 40,
                        child: TextField(
                          controller: metode == 'Email'
                              ? logincontroller.edtEmail
                              : logincontroller.edtPhone,
                          maxLength: metode == 'Email' ? 40 : 13,
                          keyboardType: metode == 'Email'
                              ? TextInputType.emailAddress
                              : TextInputType.number,
                          decoration: DecorationConstant.inputDecor().copyWith(
                              hintText: metode == 'Email'
                                  ? "Masukkan Email anda"
                                  : "Masukkan Nomor Telepon anda",
                              counterText: '',
                              contentPadding: EdgeInsets.only(top: 0)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30),
              ButtonGreenWidget(
                text: 'Submit',
                onClick: () {
                  if (metode == 'Email') {
                    LocalData.saveData('email', logincontroller.edtEmail.text);
                    logincontroller.sendOtpEmail(
                      context: context,
                      callback: (result, error) {
                        if (result != null) {
                          if (result['error'] != true) {
                            Get.to(SecurityScreen(
                              forget: true,
                            ));
                          } else {
                            LocalData.removeAllPreference();
                            DialogConstant.alertError(
                                'Rubah Kata Sandi Gagal', result['message']);
                          }
                        } else {
                          LocalData.removeAllPreference();
                          DialogConstant.alertError(
                              'Rubah Kata Sandi Gagal', error['message']);
                        }
                      },
                    );
                  } else {
                    LocalData.saveData('phone', logincontroller.edtPhone.text);
                    logincontroller.sendOtpPhone(
                      context: context,
                      callback: (result, error) {
                        if (result != null) {
                          if (result['error'] != true) {
                            Get.to(SecurityScreen(
                              forget: true,
                            ));
                          } else {
                            LocalData.removeAllPreference();
                            DialogConstant.alertError(
                                'Rubah Kata Sandi Gagal', result['message']);
                          }
                        } else {
                          LocalData.removeAllPreference();
                          DialogConstant.alertError(
                              'Rubah Kata Sandi Gagal', error['message']);
                        }
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
