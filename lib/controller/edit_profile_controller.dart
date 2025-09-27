import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api.dart';
import '../constant/dialog_constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  void postEditProfileWithFile({
    required BuildContext context,
    required Function(dynamic result, dynamic error) callback,
    required Map<String, String> post,
    XFile? imageFile,
  }) async {
    try {
      // Show loading dialog
      DialogConstant.loading(context, "Updating profile...");

      var uri = Uri.parse('${API.BASE_URL}/api/poin/update-user');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields.addAll(post);

      // Add image file if selected
      if (imageFile != null) {
        var file = await http.MultipartFile.fromPath(
          'profile_picture',
          imageFile.path,
          filename: '${post['username']}.jpg',
        );
        request.files.add(file);
      }
      // Add headers if needed
      request.headers.addAll({
        'Accept': 'application/json',
        // Add authorization header if required
        // 'Authorization': 'Bearer $token',
      });

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      // Close loading dialog
      Get.back();

      if (response.statusCode == 200) {
        var result = json.decode(responseData);
        LocalData.saveData(
            'profile_picture', 'profile_picture/${result['profile_picture']}');
        callback(result, null);
      } else {
        var error = json.decode(responseData);
        callback(null, error);
      }
    } catch (e) {
      // Close loading dialog
      Get.back();
      print('Error uploading profile: $e');
      callback(null, {'message': 'Network error occurred'});
    }
  }
}
