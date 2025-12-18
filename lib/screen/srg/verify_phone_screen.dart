import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../constant/dialog_constant.dart';
import '../../../constant/text_constant.dart';
import '../../../controller/auth_controller.dart';
import '../../../screen/home/landing_home.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({Key? key}) : super(key: key);

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final AuthController authController = AuthController();
  int time = 0;
  int time2 = 0;
  Timer? _timer;
  Timer? _timer2;

  void _startTimer() {
    setState(() {
      time = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (time > 0) {
          time--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _startTimer2() {
    setState(() {
      time2 = 120;
    });

    _timer2 = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (time2 > 0) {
          time2--;
        } else {
          _timer2?.cancel();
        }
      });
    });
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogConstant.showOtpMethodDialog(
          title: "Pilih Metode Pengiriman OTP",
          message: "Pilih metode untuk menerima kode OTP verifikasi:",
          onWhatsApp: () {
            authController.sendOtpPhone(
                context: Get.context!,
                callback: (result, error) {
                  if (result != null) {
                    if (result['error'] != true) {
                      DialogConstant.showSuccessAlert(
                          title:
                              'Kode verifikasi telah dikirim ke Nomor Telepon Anda.',
                          message:
                              'Mohon cek kembali Whatsapp anda untuk mendapatkan kode verifikasi');
                      _startTimer2();
                    } else {
                      DialogConstant.alertError(
                          'Gagal mengirimkan kode Otp: ', result['message']);
                    }
                  } else {
                    DialogConstant.alertError(
                        'Gagal mengirimkan kode Otp: ', error['message']);
                  }
                  _startTimer();
                });
          },
          onEmail: () {
            authController.sendOtpEmail(
                context: Get.context!,
                callback: (result, error) {
                  if (result != null) {
                    if (result['error'] != true) {
                      _startTimer2();
                      DialogConstant.showSuccessAlert(
                          title: 'Kode verifikasi telah dikirim ke Email Anda.',
                          message:
                              'Mohon cek kembali email anda untuk mendapatkan kode verifikasi');
                    } else {
                      DialogConstant.alertError(
                          'Gagal mengirimkan kode Otp: ', result['message']);
                    }
                  } else {
                    DialogConstant.alertError(
                        'Gagal mengirimkan kode Otp: ', error['message']);
                  }
                  _startTimer();
                });
          });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: 20),
              // Illustration Section
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security,
                        size: 60,
                        color: Colors.green.shade600,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Verifikasi Keamanan',
                      style: TextConstant.regular.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Masukkan kode verifikasi 4 digit yang telah dikirimkan melalui WhatsApp atau Email',
                      style: TextConstant.regular.copyWith(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // PIN Code Input Section
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Kode Verifikasi',
                          style: TextConstant.regular.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        if (time2 > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.orange.shade200, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 14,
                                  color: Colors.orange.shade700,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${(time2 ~/ 60).toString().padLeft(2, '0')}:${(time2 % 60).toString().padLeft(2, '0')}',
                                  style: TextConstant.regular.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                    PinCodeTextField(
                      length: 4,
                      appContext: Get.context!,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.slide,
                      cursorColor: Colors.green.shade600,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12),
                        fieldHeight: 60,
                        fieldWidth: 55,
                        activeFillColor: Colors.green.shade50,
                        inactiveFillColor: Colors.grey.shade100,
                        selectedFillColor: Colors.green.shade50,
                        inactiveColor: Colors.grey.shade300,
                        selectedColor: Colors.green.shade400,
                        activeColor: Colors.green.shade600,
                        borderWidth: 2,
                        disabledColor: Colors.grey.shade200,
                      ),
                      enableActiveFill: true,
                      controller: authController.otpCode,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textStyle: TextConstant.regular.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      onCompleted: (v) {
                        // Auto submit when completed
                      },
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),

              // Resend Button
              Center(
                child: GestureDetector(
                  onTap: time > 0
                      ? null
                      : () {
                          DialogConstant.showOtpMethodDialog(
                              title: "Pilih Metode Pengiriman OTP",
                              message:
                                  "Pilih metode untuk menerima kode OTP verifikasi:",
                              onWhatsApp: () {
                                authController.sendOtpPhone(
                                    context: Get.context!,
                                    callback: (result, error) {
                                      if (result != null) {
                                        if (result['error'] != true) {
                                          _startTimer2();
                                          DialogConstant.showSuccessAlert(
                                              title:
                                                  'Kode verifikasi telah dikirim ke Nomor Telepon Anda.',
                                              message:
                                                  'Mohon cek kembali Whatsapp anda untuk mendapatkan kode verifikasi');
                                        } else {
                                          DialogConstant.alertError(
                                              'Gagal mengirimkan kode Otp: ',
                                              result['message']);
                                        }
                                      } else {
                                        DialogConstant.alertError(
                                            'Gagal mengirimkan kode Otp: ',
                                            error['message']);
                                      }
                                      _startTimer();
                                    });
                              },
                              onEmail: () {
                                authController.sendOtpEmail(
                                    context: Get.context!,
                                    callback: (result, error) {
                                      if (result != null) {
                                        if (result['error'] != true) {
                                          _startTimer2();
                                          DialogConstant.showSuccessAlert(
                                              title:
                                                  'Kode verifikasi telah dikirim ke Email Anda.',
                                              message:
                                                  'Mohon cek kembali email anda untuk mendapatkan kode verifikasi');
                                        } else {
                                          DialogConstant.alertError(
                                              'Gagal mengirimkan kode Otp: ',
                                              result['message']);
                                        }
                                      } else {
                                        DialogConstant.alertError(
                                            'Gagal mengirimkan kode Otp: ',
                                            error['message']);
                                      }
                                      _startTimer();
                                    });
                              });
                        },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: time > 0 ? Colors.grey.shade100 : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: time > 0
                            ? Colors.grey.shade300
                            : Colors.green.shade300,
                        width: 1.5,
                      ),
                      boxShadow: time > 0
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (time > 0) ...[
                          Icon(
                            Icons.timer,
                            size: 18,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Kirim ulang dalam ${time}s',
                            style: TextConstant.regular.copyWith(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: Colors.green.shade600,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Kirim Ulang Kode',
                            style: TextConstant.regular.copyWith(
                              color: Colors.green.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Submit Button with improved design
              Container(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => authController.validationOtp(
                    context: Get.context!,
                    callback: (result, error) async {
                      if (result != null && result['error'] != true) {
                        DialogConstant.showSuccessAlert(
                            title: 'Terimakasih telah melakukan registrasi',
                            message:
                                'Selamat datang di aplikasi Tiara Dewata Group Member',
                            onComplete: () => Get.offAll(LandingHome()));
                      } else {
                        DialogConstant.alertError(
                            'Validasi Gagal', 'Kode verifikasi salah!');
                      }
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.green.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Verifikasi Sekarang',
                        style: TextConstant.regular.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
