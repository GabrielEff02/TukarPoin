import 'dart:async';
import 'package:e_commerce/screen/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:e_commerce/utils/local_data.dart';

import '../../../constant/dialog_constant.dart';
import '../../../constant/image_constant.dart';
import '../../../controller/auth_controller.dart';

class SecurityScreen extends StatefulWidget {
  final bool forget;
  const SecurityScreen({
    Key? key,
    this.forget = false,
  }) : super(key: key);

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  AuthController authController = Get.put(AuthController());
  String passwordCheck = '';
  int time = 0;
  int time2 = 0;
  Timer? _timer;
  Timer? _timer2;

  initState() {
    super.initState();
    passwordCheck =
        'Password harus minimal 8 karakter dan mengandung huruf besar, huruf kecil, angka, & simbol (@\$!%*?&)!';
  }

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
  void dispose() {
    _timer?.cancel();
    _timer2?.cancel();

    super.dispose();
    authController.changePass.text = "";
    authController.otpCode.text = "";
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Keamanan Akun',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              ImageConstant.ilus_forgot_pass,
                              height: size.height * 0.15,
                            ),
                          ),
                          SizedBox(height: 30),
                          // Title with modern styling
                          Text(
                            'Ubah Kata Sandi',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Masukkan kata sandi baru dan kode verifikasi untuk mengamankan akun Anda.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF718096),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 35),
                          _buildPasswordInput(),
                          if (passwordCheck.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(top: 12),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade600, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      passwordCheck,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 30),
                          _buildOTPInput(),
                          SizedBox(height: 40),
                          Center(
                            child: Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF667eea).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () => _submit(),
                                  child: Center(
                                    child: Text(
                                      'Konfirmasi',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kata Sandi Baru',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                child: Icon(
                  Icons.lock_outline,
                  color: Color(0xFF667eea),
                  size: 22,
                ),
              ),
              Expanded(
                child: TextField(
                  maxLength: 20,
                  controller: authController.changePass,
                  obscureText: true,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                  decoration: InputDecoration(
                    hintText: "Masukkan Kata Sandi Baru",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                  ),
                  onChanged: (value) {
                    String password = value;

                    if (password.isEmpty) {
                      setState(() {
                        passwordCheck = 'Password tidak boleh kosong!';
                      });
                    } else if (password.length < 8) {
                      setState(() {
                        passwordCheck = 'Password harus minimal 8 karakter';
                        if (!RegExp(r'[a-z]').hasMatch(password)) {
                          passwordCheck += ' & mengandung huruf kecil';
                        }
                        if (!RegExp(r'[A-Z]').hasMatch(password)) {
                          passwordCheck += ' & mengandung huruf besar';
                        }
                        if (!RegExp(r'\d').hasMatch(password)) {
                          passwordCheck += ' & mengandung angka';
                        }
                        if (!RegExp(r'[@$!%*?&]').hasMatch(password)) {
                          passwordCheck += ' & mengandung simbol (@\$!%*?&)';
                        }
                        passwordCheck += '!';
                      });
                    } else if (!RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                        .hasMatch(password)) {
                      setState(() {
                        passwordCheck =
                            'Password harus mengandung huruf besar, huruf kecil, angka, dan simbol (@\$!%*?&)!';
                      });
                    } else {
                      setState(() {
                        passwordCheck = ''; // Tidak ada error
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 15),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOTPInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Kode Verifikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            Spacer(),
            if (time2 > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF667eea).withOpacity(0.1),
                      Color(0xFF764ba2).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(0xFF667eea).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Color(0xFF667eea),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${(time2 ~/ 60).toString().padLeft(2, '0')}:${(time2 % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667eea),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 15),
        PinCodeTextField(
          length: 4,
          appContext: Get.context!,
          keyboardType: TextInputType.number,
          animationType: AnimationType.scale,
          animationDuration: Duration(milliseconds: 300),
          enableActiveFill: true,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12),
            fieldHeight: 60,
            fieldWidth: 55,
            activeFillColor: Color(0xFF667eea).withOpacity(0.1),
            inactiveFillColor: Colors.grey.shade100,
            selectedFillColor: Color(0xFF667eea).withOpacity(0.2),
            inactiveColor: Colors.grey.shade300,
            selectedColor: Color(0xFF667eea),
            activeColor: Color(0xFF667eea),
            borderWidth: 2,
            disabledColor: Colors.grey.shade200,
          ),
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
          controller: authController.otpCode,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: time > 0
                ? null
                : () async {
                    if (!await LocalData.containsKey('email')) {
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

                      return;
                    }
                    if (!await LocalData.containsKey('phone')) {
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

                      return;
                    }
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
                color: time > 0
                    ? Colors.grey.shade100
                    : Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: time > 0
                      ? Colors.grey.shade300
                      : Color(0xFF667eea).withOpacity(0.3),
                ),
              ),
              child: Text(
                time > 0
                    ? 'Kirim ulang dalam ${time}s'
                    : 'Kirim kode verifikasi',
                style: TextStyle(
                  color: time > 0 ? Colors.grey.shade600 : Color(0xFF667eea),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (passwordCheck == '') {
      authController.validationOtp(
        context: Get.context!,
        callback: (result, error) async {
          if (result != null && result['error'] != true) {
            authController.changePass.text = "";
            authController.otpCode.text = "";
            DialogConstant.showSuccessAlert(
                title: 'Kata sandi berhasil diubah!',
                message: 'Silahkan login ulang menggunakan password yang baru',
                onComplete: () => Get.offAll(LoginScreen()));
          } else {
            DialogConstant.alertError(
                'Validasi Gagal', 'Kode verifikasi salah!');
          }
        },
      );
    } else {
      DialogConstant.alertError('Ganti Password', passwordCheck);
    }
  }
}
