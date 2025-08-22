// import 'package:barcode/barcode.dart';
// import '../../../screen/gabriel/core/app_export.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../../constant/text_constant.dart';
// import '../../../screen/auth/login_screen.dart';
// import '../../navbar_menu/contact_screen.dart';
// import '../../../screen/home/view/edit_profile_screen.dart';
// import '../../../screen/srg/security_screen.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Center(
//             child: const Text(
//               "ACCOUNT",
//               style: TextStyle(
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w800,
//                 fontSize: 20,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ),
//       backgroundColor: Colors.transparent,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFFB3E5FC), // Light blue
//               Color.fromARGB(255, 61, 192, 253), // Medium light blue
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         height: double.infinity,
//         width: double.infinity,
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     // Row(
//                     //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     //   children: [
//                     //     GestureDetector(
//                     //       onTap: () => _showBarcodePopup(context, false),
//                     //       child: itemMenu("Barcode", FontAwesomeIcons.barcode,
//                     //           barcode: true),
//                     //     ),
//                     //     GestureDetector(
//                     //       onTap: () => _showBarcodePopup(context, true),
//                     //       child: itemMenu("QR Code", Icons.qr_code_2,
//                     //           barcode: true),
//                     //     ),
//                     //   ],
//                     // ),
//                     // const SizedBox(height: 5),
//                     GestureDetector(
//                       onTap: () => Get.to(() => const EditProfileScreen()),
//                       child: itemMenu('Account Detail', Icons.person),
//                     ),
//                     // const SizedBox(height: 5),
//                     // GestureDetector(
//                     //   onTap: () => Get.to(() => AddressListScreen()),
//                     //   child: itemMenu('Address Detail', Icons.house),
//                     // ),
//                     const SizedBox(height: 5),
//                     GestureDetector(
//                       onTap: () => Get.to(() => SecurityScreen()),
//                       child: itemMenu('Security', Icons.lock),
//                     ),
//                     const SizedBox(height: 5),
//                     GestureDetector(
//                       onTap: () => Get.to(() => const ContactScreen()),
//                       child: itemMenu('Contact Us', Icons.call),
//                     ),
//                     const SizedBox(height: 5),
//                     GestureDetector(
//                       onTap: () {
//                         LocalData.removeAllPreference();
//                         Get.offAll(const LoginScreen());
//                       },
//                       child: itemMenu('Log Out', Icons.exit_to_app_rounded),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget itemMenu(String title, IconData icons,
//       {bool barcode = false, bool point = false}) {
//     final decoration = barcode
//         ? BoxDecoration(
//             gradient: const LinearGradient(
//                 // colors: [Color.fromARGB(255, 204, 239, 237), Color(0xFF80CBC4)],
//                 // colors: [Color(0xFFD7C49E), Color(0xFFA67C47)],4
//                 // colors: [Color(0xFFE7D3E2), Color(0xFFC0A3C6)],
//                 colors: [Color(0xFFFF6F61), Color(0xFFFFB74D)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight),
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 spreadRadius: 1,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           )
//         : point
//             ? BoxDecoration(
//                 color: Color.fromARGB(255, 255, 255, 255),
//                 // gradient: LinearGradient(
//                 //   colors: [Colors.orangeAccent, Colors.deepOrange],
//                 //   begin: Alignment.topLeft,
//                 //   end: Alignment.bottomRight,
//                 // ),
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Color(0xFFF8E2C8).withValues(alpha: 100),
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               )
//             : BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 8,
//                     spreadRadius: 1,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               );
//     return Container(
//       decoration: decoration,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       margin: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         children: [
//           point
//               ? Icon(
//                   Icons.stars,
//                   color: Colors.black,
//                   size: 40,
//                 )
//               : Icon(icons, color: Colors.black87),
//           const SizedBox(width: 15),
//           point
//               ? Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Your Points",
//                       style: GoogleFonts.poppins(
//                         color: Colors.black,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       title,
//                       style: GoogleFonts.poppins(
//                         color: Colors.black,
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 )
//               : Text(
//                   title,
//                   style: TextConstant.medium.copyWith(
//                     color: Colors.black87,
//                     fontSize: 15,
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }

//   void _showBarcodePopup(BuildContext context, bool isQRCode) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return FutureBuilder(
//           future: LocalData.getData('phone'),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return const Center(child: Icon(Icons.error));
//             } else if (!snapshot.hasData || snapshot.data == null) {
//               return const Center(child: Icon(Icons.error)); // If no data
//             }

//             final code = isQRCode
//                 ? Barcode.qrCode().toSvg(snapshot.data.toString())
//                 : Barcode.code39().toSvg(snapshot.data.toString());

//             return TweenAnimationBuilder<double>(
//               tween: Tween<double>(begin: 1.0, end: 1.1),
//               duration: const Duration(milliseconds: 500),
//               builder: (context, scale, child) {
//                 return Transform.scale(
//                   scale: scale,
//                   child: Dialog(
//                     child: Container(
//                       height: 400,
//                       decoration: const BoxDecoration(color: Colors.white),
//                       padding: const EdgeInsets.symmetric(vertical: 20),
//                       child: Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 10),
//                               child: SvgPicture.string(code,
//                                   height: isQRCode ? 200 : 250,
//                                   width: isQRCode ? 200 : 200,
//                                   fit:
//                                       isQRCode ? BoxFit.cover : BoxFit.contain),
//                             ),
//                             const SizedBox(height: 10),
//                             if (isQRCode) // Display text only for QR Code
//                               Text(
//                                 snapshot.data.toString(),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
