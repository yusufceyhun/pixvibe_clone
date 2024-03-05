import 'package:flutter/material.dart';

class TuneController {
  final ValueNotifier<double> contrast;
  final ValueNotifier<double> saturation;
  final ValueNotifier<double> brightness;

  TuneController({
    double initialContrast = 1,
    double initialSaturation = 1,
    double initialBrightness = 1,
    double initialSharpness = 1,
  })  : contrast = ValueNotifier<double>(initialContrast),
        saturation = ValueNotifier<double>(initialSaturation),
        brightness = ValueNotifier<double>(initialBrightness);

  void adjustContrast(double newValue) {
    contrast.value = newValue;
  }

  void adjustSaturation(double newValue) {
    saturation.value = newValue;
  }

  void adjustBrightness(double newValue) {
    brightness.value = newValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'contrast': contrast.value,
      'saturation': saturation.value,
      'brightness': brightness.value,
    };
  }

  factory TuneController.fromJson(Map<String, dynamic> json) {
    return TuneController(
      initialContrast: json['contrast'] ?? 1.0,
      initialSaturation: json['saturation'] ?? 1.0,
      initialBrightness: json['brightness'] ?? 1.0,
    );
  }
}
