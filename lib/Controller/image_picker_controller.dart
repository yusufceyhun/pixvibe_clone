import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../view/edit_image_page.dart';

class ImagePickerController {
  Future<void> selectImage(BuildContext context) async {
    await Permission.manageExternalStorage.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      _getImage(context, ImageSource.gallery);
    } else {
      if (permissionStatus.isDenied) {
        permissionStatus = await Permission.photos.request();
        if (permissionStatus.isGranted) {
          _getImage(context, ImageSource.gallery);
        } else {
          print('Gallery permission denied');
        }
      } else {
        print('Gallery permission denied.');
      }
    }
  }

  Future<void> capturePhoto(BuildContext context) async {
    var permissionStatus = await Permission.camera.status;
    if (permissionStatus.isGranted) {
      _getImage(context, ImageSource.camera);
    } else {
      if (permissionStatus.isDenied) {
        permissionStatus = await Permission.camera.request();
        if (permissionStatus.isGranted) {
          _getImage(context, ImageSource.camera);
        } else {
          print('Camera permission denied');
        }
      } else {
        print('Camera permission denied');
      }
    }
  }

  void _getImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      _navigateToEditImagePage(context, imageFile);
    } else {}
  }

  void _navigateToEditImagePage(BuildContext context, File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditImagePage(image: imageFile),
      ),
    );
  }
}
