import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fp_ppb/enums/image_cloud_endpoint.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ImageCloudService {
  final ImagePicker _picker = ImagePicker();
  final String uploadEndpoint =
      'http://20.80.233.67:9999'; // Replace with your endpoint URL

  String getEndpoint(ImageUploadEndpoint type, {String? arg = ""}) {
    switch (type) {
      case ImageUploadEndpoint.uploadImage:
        return "$uploadEndpoint/upload/";
      case ImageUploadEndpoint.getImageByFilename:
        return "$uploadEndpoint/images/$arg/";
      case ImageUploadEndpoint.deleteImageByFilename:
        return "$uploadEndpoint/images/$arg/";
      case ImageUploadEndpoint.getImages:
        return "$uploadEndpoint/images/";
      default:
        return "";
    }
  }

  Future deleteImageByFilename(String filename) async {
    try {
      if (kDebugMode) {
        print(filename);
      }
      String encodedFilename = Uri.encodeComponent(filename);

      var response = await http.delete(
          Uri.parse(getEndpoint(ImageUploadEndpoint.deleteImageByFilename,
              arg: encodedFilename)),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          });

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Image deleted successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to delete image, status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
    }
  }

  Future<String?> uploadImage(XFile image) async {
    try {
      // if want to get the image, put this code to decode string to URL format
      // String encodedFilename = Uri.encodeComponent(image.name);

      var request = http.MultipartRequest(
          'POST', Uri.parse(getEndpoint(ImageUploadEndpoint.uploadImage)));
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseData);
        if (kDebugMode) {
          print("success upload image ${decodedResponse['filename']}");
        }
        return decodedResponse[
            'filename']; // Assuming the server returns the URL in the 'url' field
      } else {
        if (kDebugMode) {
          print('Failed to upload image, status code: ${response.statusCode}');
          var responseData = await response.stream.bytesToString();
          print('Response body: $responseData');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  // Example method to directly upload from a file path
  Future<String?> uploadImageFromFile(String filePath) async {
    final XFile image = XFile(filePath);
    return await uploadImage(image);
  }

  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null; // Ensure we return null in case of error
    }
  }

  Future<XFile?> pickImageFromCamera() async {
    try {
      return await _picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null; // Ensure we return null in case of error
    }
  }
}
