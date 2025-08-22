import 'package:e_commerce/constant/dialog_constant.dart';

import '../../../screen/gabriel/core/app_export.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../screen/auth/login_screen.dart';
import '../../navbar_menu/contact_screen.dart';
import '../../../screen/home/view/edit_profile_screen.dart';
import '../../../screen/srg/security_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Add state variables here if needed
  String userName = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    // Add your data loading logic here
    // For example, load from local storage or API
    try {
      DialogConstant.loading(context, "Loading...");
      final username = await LocalData.getData('user');
      final email = await LocalData.getData('email');
      if (username.isNotEmpty) {
        setState(() {
          userName = username;
        });
      }
      if (email.isNotEmpty) {
        setState(() {
          userEmail = email;
        });
      }

      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate loading
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "PROFILE",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Profile Header Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // User Name
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // User Email
                    Text(
                      userEmail,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
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
                            title: 'Account Detail',
                            icon: Icons.person_outline,
                            gradientColors: [
                              Color(0xFF4facfe),
                              Color(0xFF00f2fe)
                            ],
                            onTap: () => _navigateToEditProfile(),
                          ),

                          // Security
                          _buildMenuItem(
                            title: 'Security',
                            icon: Icons.security_outlined,
                            gradientColors: [
                              Color(0xFFfa709a),
                              Color(0xFFfee140)
                            ],
                            onTap: () => _navigateToSecurity(),
                          ),

                          // Contact Us
                          _buildMenuItem(
                            title: 'Contact Us',
                            icon: Icons.support_agent_outlined,
                            gradientColors: [
                              Color(0xFF43e97b),
                              Color(0xFF38f9d7)
                            ],
                            onTap: () => _navigateToContact(),
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
                                onTap: () => _showLogoutDialog(context),
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
                                      style: GoogleFonts.poppins(
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
                    style: GoogleFonts.poppins(
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

  void _navigateToContact() {
    Get.to(() => const ContactScreen());
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirm Logout',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _handleLogout(),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: Color(0xFFff6b6b),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout() async {
    Navigator.of(context).pop();

    DialogConstant.loading(context, "Logging out...");

    try {
      // Clear user data
      await LocalData.removeAllPreference();

      // Navigate to login screen
      Get.offAll(const LoginScreen());
    } catch (e) {
      print('Error during logout: $e');
      // Show error message if needed
    } finally {
      Get.back(); // Close the loading dialog
    }
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
