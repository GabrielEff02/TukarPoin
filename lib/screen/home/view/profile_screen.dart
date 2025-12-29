import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/ocr_ktp/view/home.dart';

import '../../../screen/gabriel/core/app_export.dart';
import 'package:get/get.dart';

import '../../../screen/auth/login_screen.dart';
import '../../../screen/home/view/edit_profile_screen.dart';
import '../../../screen/srg/security_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Add state variables here if needed
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final name = await LocalData.getData('full_name');
      final mail = await LocalData.getData('email');
      if (name.isNotEmpty) {
        setState(() {
          this.name = name;
          this.email = mail;
        });
      }
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      final loading = await LocalData.getDataBool('isLoading');
      if (mounted && loading) {
        Navigator.of(context).pop();
        LocalData.saveDataBool('isLoading', false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(41, 219, 95, 29),
        elevation: 0,
        title: Text(
          "My Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/bg_all.png'), fit: BoxFit.fill),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: const Color.fromARGB(41, 219, 95, 29),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: FutureBuilder(
                        future: LocalData.getData('profile_picture'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          return ClipOval(
                            child: CustomImageView(
                              width: 80.0,
                              height: 80.0,
                              fit: BoxFit.cover,
                              imagePath:
                                  "${API.BASE_URL}/images/${snapshot.data}",
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FutureBuilder(
                      future: LocalData.getData('barcode'),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 5),

                    FutureBuilder(
                      future: LocalData.getData('vip'),
                      builder: (context, snapshot) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Text(
                            snapshot.data == '1' ? "VIP" : "Regular",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 219, 95, 29),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Menu Items Section
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Account Detail
                          _buildMenuItem(
                            title: 'Detail Akun',
                            icon: Icons.person_outline,
                            gradientColors: [
                              Color(0xFF4facfe),
                              Color(0xFF00f2fe)
                            ],
                            onTap: () => _navigateToEditProfile(),
                          ),

                          _buildMenuItem(
                            title: 'Lengkapi Data Diri',
                            icon: Icons.person_add_alt_1_rounded,
                            gradientColors: [
                              Color(0xFF43e97b),
                              Color(0xFF38f9d7)
                            ],
                            onTap: () => Get.to(KtpOCR()),
                          ),
                          // Security
                          _buildMenuItem(
                            title: 'Ubah Kata Sandi',
                            icon: Icons.security_outlined,
                            gradientColors: [
                              Color(0xFFfa709a),
                              Color(0xFFfee140)
                            ],
                            onTap: () => _navigateToSecurity(),
                          ),

                          const SizedBox(height: 30),

                          // Logout Button
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFff6b6b), Color(0xFFee5a24)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFff6b6b).withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  DialogConstant.showConfirmationDialog(
                                    title: "Keluar",
                                    message:
                                        "Apakah Anda yakin ingin keluar dari aplikasi?",
                                    confirmText: "Keluar",
                                    cancelText: "Batal",
                                    icon: Icons.logout,
                                    confirmColor: Colors.red,
                                    onConfirm: () {
                                      LocalData.removeAllPreference();
                                      Get.offAll(const LoginScreen());
                                    },
                                    onCancel: () => Get.back(),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.logout_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Log Out',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 80.v),
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

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToEditProfile() async {
    final result = await Get.to(() => const EditProfileScreen());
    // Refresh user data if needed after editing profile
    if (result == true) {
      _loadUserData();
    }
  }

  void _navigateToSecurity() {
    Get.to(() => SecurityScreen());
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
