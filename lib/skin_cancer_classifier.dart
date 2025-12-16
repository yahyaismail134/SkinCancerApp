import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Service class for skin cancer classification using TensorFlow Lite.
///
/// The model expects 224x224 RGB images and outputs probabilities for:
/// - Index 0: malignant (displayed as "Suspicious")
/// - Index 1: benign (displayed as "Likely Benign")
class SkinCancerClassifier {
  static const String _modelPath = 'assets/model_unquant.tflite';
  static const String _labelsPath = 'assets/labels.txt';
  static const int _inputSize = 224;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  /// Initialize the classifier by loading the model and labels.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load TFLite model
      _interpreter = await Interpreter.fromAsset(_modelPath);

      // Load labels
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels = labelsData
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
        // Labels format: "0 malignant" -> extract "malignant"
        final parts = line.trim().split(' ');
        return parts.length > 1 ? parts.sublist(1).join(' ') : parts[0];
      }).toList();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize classifier: $e');
    }
  }

  /// Classify a skin lesion image.
  ///
  /// Returns a [ClassificationResult] with the prediction label and confidence.
  Future<ClassificationResult> classifyImage(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_interpreter == null) {
      throw Exception('Classifier not initialized');
    }

    // Load and preprocess image
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize to 224x224
    final resizedImage = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    // Convert to appropriate input format based on model type
    // model_unquant.tflite typically expects [0, 255] float range
    // (Teachable Machine unquantized models use this convention)
    final input = _imageToFloat32List(resizedImage, normalize: false);

    // Prepare output buffer [1, num_classes]
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final numClasses = outputShape.length > 1 ? outputShape[1] : outputShape[0];
    final output = List.filled(numClasses, 0.0).reshape([1, numClasses]);

    // Run inference
    _interpreter!.run(input, output);

    // Get results
    final probabilities = (output[0] as List<double>);

    // Find the class with highest probability
    int maxIndex = 0;
    double maxProb = probabilities[0];
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    final label = maxIndex < _labels.length ? _labels[maxIndex] : 'unknown';
    final confidence = maxProb * 100; // Convert to percentage

    return ClassificationResult(
      label: label,
      confidence: confidence,
      allProbabilities: Map.fromIterables(
        _labels,
        probabilities.map((p) => p * 100),
      ),
    );
  }

  /// Convert image to float32 input tensor.
  ///
  /// [normalize]: If true, normalizes to [0.0, 1.0]. If false, keeps [0, 255].
  /// Unquantized models (model_unquant.tflite) typically expect [0, 255] range.
  List<List<List<List<double>>>> _imageToFloat32List(img.Image image,
      {bool normalize = false}) {
    final result = List.generate(
      1, // batch size
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = image.getPixel(x, y);
            if (normalize) {
              return [
                pixel.r / 255.0, // Red normalized
                pixel.g / 255.0, // Green normalized
                pixel.b / 255.0, // Blue normalized
              ];
            } else {
              // Keep original 0-255 range for unquantized models
              return [
                pixel.r.toDouble(), // Red
                pixel.g.toDouble(), // Green
                pixel.b.toDouble(), // Blue
              ];
            }
          },
        ),
      ),
    );
    return result;
  }

  /// Dispose of the interpreter resources.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}

/// Result of skin cancer classification.
class ClassificationResult {
  /// The predicted label (e.g., "benign" or "malignant")
  final String label;

  /// Confidence percentage (0-100)
  final double confidence;

  /// Probabilities for all classes (as percentages)
  final Map<String, double> allProbabilities;

  ClassificationResult({
    required this.label,
    required this.confidence,
    required this.allProbabilities,
  });

  /// Returns true if the prediction is benign.
  bool get isBenign => label.toLowerCase() == 'benign';

  /// Returns the display label for UI.
  /// Maps "malignant" to "suspicious" for consistency with UI.
  String get displayLabel => isBenign ? 'benign' : 'suspicious';
}
