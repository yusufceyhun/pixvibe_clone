import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pixvibe/Model/tune_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../Controller/save_image_controller.dart';

class EditImagePage extends StatefulWidget {
  final File image;
  final String? projectName;

  EditImagePage({
    required this.image,
    this.projectName,
  });

  @override
  _EditImagePageState createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  late TuneController _tuneController;
  late img.Image _originalImage;
  img.Image? _editedImage;
  String selectedButton = '';
  bool isSliderVisible = false;
  late SaveImageController _saveImageController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tuneController = TuneController();
    _saveImageController = SaveImageController();
    _originalImage = img.decodeImage(widget.image.readAsBytesSync())!;
    _editedImage = _originalImage.clone();

    if (widget.projectName != null) {
      fetchAdjustments(widget.projectName!);
    }
    setState(() {
      isLoading = false;
    });
  }

// Method to fetch adjustments for the selected project name
  Future<void> fetchAdjustments(String projectName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tuneControllerJson = prefs.getString('$projectName-tuneController');
    if (tuneControllerJson != null) {
      Map<String, dynamic> tuneControllerData = jsonDecode(tuneControllerJson);
      double contrast = tuneControllerData['contrast'] ?? 1.0;
      double saturation = tuneControllerData['saturation'] ?? 1.0;
      double brightness = tuneControllerData['brightness'] ?? 1.0;

      // Apply adjustments to the TuneController
      _tuneController.adjustContrast(contrast);
      _tuneController.adjustSaturation(saturation);
      _tuneController.adjustBrightness(brightness);

      // Update the edited image with adjusted values
      setState(() {
        _editedImage = _applyAdjustments(_originalImage.clone());
      });
    } else {
      print('Adjustments not found for project: $projectName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              String savedPath = await _saveImageController.saveProject(
                img.encodePng(_editedImage!),
                widget.image.path, // Pass the image path here
                _tuneController,
              );

              if (savedPath.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project saved successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to save project')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _saveImageController.downloadImage(img.encodePng(_editedImage!));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image downloaded successfully')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: !isLoading
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Center(
                      child: Image.memory(
                        Uint8List.fromList(
                          img.encodePng(
                            _editedImage!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 8),
                        _buildButton('Contrast', Icons.adjust, () {
                          _toggleSliderVisibility('Contrast');
                        }),
                        _buildButton('Saturation', Icons.color_lens, () {
                          _toggleSliderVisibility('Saturation');
                        }),
                        _buildButton('Brightness', Icons.brightness_6, () {
                          _toggleSliderVisibility('Brightness');
                        }),
                      ],
                    ),
                  ),
                  if (isSliderVisible) ...[
                    _buildSlider(selectedButton),
                  ],
                  const SizedBox(height: 20),
                ],
              )
            : const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, VoidCallback onPressed) {
    final isSelected = selectedButton == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? Colors.indigoAccent.shade700 : Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : null),
              Text(label,
                  style: TextStyle(color: isSelected ? Colors.white : null)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String label) {
    double value = 0.5;

    switch (label) {
      case 'Contrast':
        value = _tuneController.contrast.value;
        break;
      case 'Saturation':
        value = _tuneController.saturation.value;
        break;
      case 'Brightness':
        value = _tuneController.brightness.value;
        break;
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: SizedBox(
        height: isSliderVisible ? 120 : 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SfSlider(
                min: 0.5,
                max: 1.5,
                showTicks: true,
                showDividers: true,
                showLabels: true,
                interval: 0.1,
                minorTicksPerInterval: 1,
                enableTooltip: true,
                value: value,
                onChanged: isSliderVisible
                    ? (dynamic newValue) {
                        _updateImage(label, newValue.toDouble());
                      }
                    : null,
                activeColor: Colors.indigoAccent,
                inactiveColor: Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSliderVisibility(String buttonName) {
    setState(() {
      if (selectedButton == buttonName) {
        isSliderVisible = !isSliderVisible;
      } else {
        selectedButton = buttonName;
        isSliderVisible = true;
      }
    });
  }

  void _updateImage(String label, double value) {
    switch (label) {
      case 'Contrast':
        _tuneController.adjustContrast(value);
        break;
      case 'Saturation':
        _tuneController.adjustSaturation(value);
        break;
      case 'Brightness':
        _tuneController.adjustBrightness(value);
        break;
    }

    setState(() {
      _editedImage = _applyAdjustments(_originalImage.clone());
    });
  }

  img.Image _applyAdjustments(img.Image originalImage) {
    img.adjustColor(
      originalImage,
      contrast: _tuneController.contrast.value,
      saturation: _tuneController.saturation.value,
      brightness: _tuneController.brightness.value,
    );

    return originalImage;
  }
}
