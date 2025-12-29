import 'dart:convert';
import 'package:e_commerce/screen/auth/login_screen.dart';
import 'package:intl/intl.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constant/dialog_constant.dart';
import '../../../controller/edit_profile_controller.dart';
import '../../../screen/gabriel/core/app_export.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  XFile? _selectedImageFile; // Changed from Uint8List to XFile
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController pointsController = TextEditingController();
  Map<String, String> listController = {};
  String points = "0";
  String originalEmailAddress = "";
  String originalPhoneNumber = "";
  String? profilePicturePath;
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    pointsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A59),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _getImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _getImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF667eea).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF667eea).withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color(0xFF667eea),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF667eea),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = pickedFile; // Store XFile directly
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _fetchUserData() async {
    String? email = await LocalData.getData('email');
    String? fullName = await LocalData.getData('full_name');
    String? phone = await LocalData.getData('phone');
    String? pointValue = await LocalData.getData('point');
    String? profilePicture = await LocalData.getData('profile_picture');
    setState(() {
      emailController.text = email ?? '';
      nameController.text = fullName ?? '';
      phoneController.text = phone ?? '';
      originalEmailAddress = email ?? '';
      originalPhoneNumber = phone ?? '';
      points = pointValue ?? '0';
      pointsController.text = points;
      profilePicturePath = profilePicture;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              onPressed: () => _confirmEditProfile(),
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF9A3412), // orange gelap
              Color(0xFFF97316), // orange utama
              Color(0xFFFDBA74), // orange terang
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 120),

                  // Profile Picture Section
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Profile Picture',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: () {
                              if (mounted) {
                                _pickImage(context);
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _buildProfileImage(),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4facfe),
                                          Color(0xFF00f2fe)
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildPointsBalanceCard(),

                  const SizedBox(height: 30),

                  // Form Fields
                  _buildModernTextField(
                      nameController, 'Full Name', Icons.person_rounded),
                  const SizedBox(height: 20),

                  _buildModernTextField(
                      emailController, 'Email Address', Icons.email_rounded),
                  const SizedBox(height: 20),

                  _buildModernTextField(
                      phoneController, 'Phone Number', Icons.phone_rounded),
                  const SizedBox(height: 40),

                  // Delete Account Section
                  _buildDeleteAccountSection(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    // If there's a selected image file, show it
    if (_selectedImageFile != null) {
      return Image.file(
        File(_selectedImageFile!.path),
        width: 120.0,
        height: 120.0,
        fit: BoxFit.cover,
      );
    }

    // Otherwise show image from server
    return CustomImageView(
      imagePath: "${API.BASE_URL}/images/$profilePicturePath",
      width: 120.0,
      height: 120.0,
      fit: BoxFit.cover,
    );
  }

  void _saveProfile() async {
    listController['email'] = emailController.text;
    listController['name'] = nameController.text;
    listController['phone'] = phoneController.text;
    listController['username'] = await LocalData.getData('user') ?? '';

    print(listController);
    if (_formKey.currentState!.validate()) {
      EditProfileController().postEditProfileWithFile(
          context: context,
          callback: (result, error) {
            if (result != null && result['error'] != true) {
              setState(() {
                LocalData.saveData('email', listController['email']!);
                LocalData.saveData('phone', listController['phone']!);
                LocalData.saveData('full_name', listController['name']!);
              });

              DialogConstant.showSuccessAlert(
                  title: 'Success',
                  message: 'Profile updated successfully!',
                  onComplete: () {
                    if (result['email'] == true) {
                      Get.offAll(() => const LoginScreen());
                    }
                  });
            } else {
              print(error);
              print(result);
              DialogConstant.alert('Maaf ada kesalahan');
            }
          },
          post: listController,
          imageFile: _selectedImageFile); // Pass XFile directly
    }
  }

  Widget _buildDeleteAccountSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Danger Zone',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Once you delete your account, there is no going back. Please be certain.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _showDeleteAccountDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_forever_rounded,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Delete Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildPointsBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD700), // Gold
            Color(0xFFFFA500), // Orange
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Points Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormatter
                      .format(double.tryParse(points.replaceAll(',', '')) ?? 0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isOptional = false,
    bool isReadOnly = false,
    bool isPoints = false,
  }) {
    if (isPoints) {
      double? value = double.tryParse(
          controller.text.replaceAll(',', '')); // Menghapus koma
      if (value != null) {
        controller.text = currencyFormatter.format(value);
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isReadOnly ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        style: TextStyle(
          color: isPoints ? const Color(0xFFFFD700) : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isPoints ? const Color(0xFFFFD700) : Colors.white,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.warning_rounded,
                              color: Colors.red.shade600,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Delete Account',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E3A59),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Warning Text
                      const Text(
                        'This action cannot be undone. All your data including:',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Data List Container
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(child: Text('Profile information')),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.history,
                                    size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(child: Text('Purchase history')),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.stars, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(child: Text('Points and rewards')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'will be permanently deleted.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Please enter your password to confirm:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Password TextField
                      TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              passwordController.dispose();
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (passwordController.text.isNotEmpty) {
                                _handleDeleteAccount(passwordController.text);
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Please enter your password',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Delete Account'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleDeleteAccount(String password) async {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    // Show loading dialog for delete account process
    DialogConstant.loading(context, "Deleting account...");

    try {
      String? username = await LocalData.getData('user');
      if (username == null || username.isEmpty) {
        throw Exception('User data not found');
      }
      Map<String, dynamic> requestData = {
        'username': username,
        'password': password,
      };
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      API.basePost('/api/poin/delete-account', requestData, headers, true,
          (result, error) async {
        if (result != null && error == null) {
          print('Delete account success: $result');

          await LocalData.removeAllPreference();

          Get.snackbar(
            'Account Deleted',
            result['message'] ?? 'Your account has been permanently deleted.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
            icon: const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
          );

          Get.offAll(() => const LoginScreen());
        } else {
          print('Delete account error: $error');

          String errorMessage;

          if (error != null) {
            // Handle specific error cases
            if (error['message'] != null) {
              errorMessage = error['message'];
            } else if (error.toString().contains('401') ||
                error.toString().contains('password')) {
              errorMessage = 'Invalid password. Please try again.';
            } else if (error.toString().contains('404') ||
                error.toString().contains('not found')) {
              errorMessage = 'Account not found in the system.';
            } else {
              errorMessage = 'Failed to delete account. Please try again.';
            }
          } else {
            errorMessage = 'Failed to delete account. Please try again.';
          }
          Get.back();
          Get.snackbar(
            'Delete Failed',
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            icon: const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
          );
        }
      });
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      print('Error during account deletion: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to delete account. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _confirmEditProfile() {
    // Check if email address has changed
    if (emailController.text != originalEmailAddress) {
      _showEmailChangeConfirmation(
          "Email telah diubah",
          "Anda telah mengubah alamat email Anda. Demi keamanan, Anda perlu masuk kembali.",
          originalEmailAddress,
          emailController.text);
    } else if (phoneController.text != originalPhoneNumber) {
      _showEmailChangeConfirmation(
          "Nomor Telepon telah diubah",
          "Anda telah mengubah nomor telepon Anda. Demi keamanan, Anda perlu masuk kembali.",
          originalPhoneNumber,
          phoneController.text);
    } else {
      _showNormalConfirmation();
    }
  }

  void _showEmailChangeConfirmation(title, subTitle, original, baru) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.orange.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A59),
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subTitle,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Sebelumnya: ",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          original.isEmpty ? "Not set" : original,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        "New: ",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          baru,
                          style: const TextStyle(
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Are you sure you want to continue?",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3A59),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _saveProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Yes, Update"),
          ),
        ],
      ),
    );
  }

  void _showNormalConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Confirm Update",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A59),
          ),
        ),
        content: const Text(
          "Are you sure you want to update your profile information?",
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _saveProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
