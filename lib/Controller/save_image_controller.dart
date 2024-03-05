import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pixvibe/Model/tune_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveImageController {
  Future<String> saveProject(Uint8List imageBytes, String imagePath,
      TuneController tuneController) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      List<String>? projectNames = prefs.getStringList('projectNames');
      int projectCount = projectNames?.length ?? 0;

      String projectName = 'Project ${projectCount + 1}';

      final file = File('${directory.path}/$projectName.png');
      await file.writeAsBytes(imageBytes);

      projectNames ??= [];
      projectNames.add(projectName);
      await prefs.setStringList('projectNames', projectNames);

      // Save image path
      await prefs.setString('$projectName-imagePath', imagePath);

      // Encode TuneController to JSON
      Map<String, dynamic> tuneControllerJson = {
        'contrast': tuneController.contrast.value,
        'saturation': tuneController.saturation.value,
        'brightness': tuneController.brightness.value,
      };

      // Save encoded TuneController
      await prefs.setString(
          '$projectName-tuneController', jsonEncode(tuneControllerJson));

      return file.path;
    } catch (e) {
      print("Failed to save project: $e");
      return '';
    }
  }

  Future<List<String>> getProjectNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('projectNames') ?? [];
  }

  Future<File?> getProjectFile(String projectName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('$projectName-imagePath');
    return imagePath != null ? File(imagePath) : null;
  }

  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Clear all data stored in SharedPreferences
    await prefs.clear();

    print('SharedPreferences cleared.');
  }

  Future<void> downloadImage(Uint8List imageBytes) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/temp_image.png');
    await file.writeAsBytes(imageBytes);

    await ImageGallerySaver.saveImage(file.readAsBytesSync());
  }
}
