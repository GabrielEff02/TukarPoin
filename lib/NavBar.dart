import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/auth/login_screen.dart';
import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:e_commerce/screen/gabriel/request_item/request_history_screen/request_history_screen.dart';
import 'package:e_commerce/screen/home/view/edit_profile_screen.dart';
import 'package:e_commerce/screen/navbar_menu/about_us_screen.dart';
import 'package:e_commerce/screen/navbar_menu/history_screen.dart';
import 'package:e_commerce/screen/navbar_menu/others_screen.dart';
import 'package:e_commerce/screen/navbar_menu/contact_screen.dart';
import 'package:e_commerce/screen/navbar_menu/outlet_screen.dart';
// import 'package:e_commerce/screen/ocr_ktp/view/home.dart';
import 'package:e_commerce/screen/srg/security_screen.dart';
import 'package:get/get.dart';

import 'screen/navbar_menu/checkout_main_screen.dart';

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
              margin: EdgeInsets.fromLTRB(10.h, 30.v, 10.h, 10.v),
              child: Image.asset(
                'assets/images/logo.png',
                width: 150.adaptSize,
                height: 150.adaptSize,
              )),

          // ListTile(
          //   leading: Icon(Icons.person),
          //   title: Text('Friends'),
          //   onTap: () => null,
          // ),

          // ListTile(
          //   leading: Icon(Icons.notifications),
          //   title: Text('Request'),
          //   onTap: () => null,
          //   trailing: ClipOval(
          //     child: Container(
          //       color: Colors.red,
          //       width: 20,
          //       height: 20,
          //       child: Center(
          //         child: Text(
          //           '8',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 12,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // ListTile(
          //   leading: Icon(Icons.shop),
          //   title: Text('Checkouts Cart'),
          //   // onTap: () => Get.to(() => CheckoutsSplashScreen()),
          //   onTap: () => mainCheckouts(),
          // ),
          Divider(),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Redeem your points'),
            onTap: () => Get.to(() => CheckoutMainScreen()),
          ),
          ListTile(
            leading: Icon(Icons.request_page),
            title: Text('Request Item'),
            onTap: () => Get.to(() => RequestHistoryScreen()),
          ),
          ListTile(
            leading: Icon(Icons.history_edu),
            title: Text('Riwayat Transaksi'),
            onTap: () => Get.to(() => HistoryScreen()),
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Change Password'),
            onTap: () => Get.to(() => SecurityScreen()),
          ),

          ListTile(
            leading: Icon(Icons.person),
            title: Text('Edit Profile'),
            onTap: () => Get.to(() => EditProfileScreen()),
          ),
          // ListTile(
          //   leading: Icon(Icons.person_add),
          //   title: Text('Complete your details'),
          //   onTap: () => Get.to(() => KtpOCR()),
          // ),

          Divider(),
          ListTile(
            leading: Icon(Icons.house),
            title: Text('Tiara Outlet Store'),
            onTap: () => Get.to(() => OutletScreen()),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Contact US'),
            onTap: () => Get.to(() => ContactScreen()),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.more_horiz),
            title: Text('Terms & Conditions'),
            onTap: () => Get.to(() => OthersScreen()),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About US'),
            onTap: () => Get.to(() => AboutUsScreen()),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app_rounded),
            title: Text('Log Out'),
            onTap: () {
              DialogConstant.showConfirmationDialog(
                title: "Keluar",
                message: "Apakah Anda yakin ingin keluar dari aplikasi?",
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
          ),
        ],
      ),
    );
  }
}
