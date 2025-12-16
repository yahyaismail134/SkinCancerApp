import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'skin_cancer_classifier.dart';

// Global list to store scan history
class ScanHistoryManager {
  static final List<ScanResult> _history = [];

  static void addScan(ScanResult scan) {
    _history.insert(0, scan);
  }

  static List<ScanResult> getHistory() {
    return _history;
  }

  static void clearHistory() {
    _history.clear();
  }
}

class ScanResult {
  final String imagePath;
  final String prediction;
  final double confidence;
  final DateTime date;

  ScanResult({
    required this.imagePath,
    required this.prediction,
    required this.confidence,
    required this.date,
  });
}

void main() {
  runApp(const SkinCancerApp());
}

class SkinCancerApp extends StatelessWidget {
  const SkinCancerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinGuard AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SkinGuard AI',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Early Skin Lesion Detection Assistant',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                        left: BorderSide(
                            color: Colors.yellow.shade700, width: 4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.yellow.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Medical Disclaimer',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'This app is not a substitute for professional medical diagnosis. Always consult a dermatologist.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildButton(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Take a Photo',
                  color: Colors.blue.shade600,
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CameraScreen())),
                ),
                const SizedBox(height: 16),
                _buildButton(
                  context,
                  icon: Icons.upload_file,
                  label: 'Upload Image',
                  color: Colors.white,
                  textColor: Colors.blue.shade600,
                  borderColor: Colors.blue.shade600,
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                PreviewScreen(imagePath: image.path)),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildButton(
                  context,
                  icon: Icons.history,
                  label: 'View History',
                  color: Colors.grey.shade100,
                  textColor: Colors.grey.shade700,
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen())),
                ),
                const SizedBox(height: 16),
                _buildButton(
                  context,
                  icon: Icons.info_outline,
                  label: 'How to Use',
                  color: Colors.grey.shade100,
                  textColor: Colors.grey.shade700,
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const InfoScreen())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    Color? textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor ?? Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 2)
                : BorderSide.none,
          ),
          elevation: color == Colors.white ? 0 : 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(label,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// Camera Screen
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool flashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.white, width: 4, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Position lesion in center\nKeep camera steady',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                    style:
                        IconButton.styleFrom(backgroundColor: Colors.black45),
                  ),
                  IconButton(
                    onPressed: () => setState(() => flashOn = !flashOn),
                    icon: Icon(flashOn ? Icons.flash_on : Icons.flash_off,
                        color: flashOn ? Colors.yellow : Colors.white,
                        size: 28),
                    style:
                        IconButton.styleFrom(backgroundColor: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PreviewScreen(imagePath: image.path)),
                    );
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Preview Screen
class PreviewScreen extends StatelessWidget {
  final String imagePath;

  const PreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Review Image'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(imagePath),
                      height: 320,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.tips_and_updates,
                            color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tip: You can crop the image to focus on the lesion area for better analysis.',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CropScreen(imagePath: imagePath),
                          ),
                        );
                      },
                      icon: const Icon(Icons.crop),
                      label: const Text('Crop Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.all(14),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProcessingScreen(imagePath: imagePath)),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Analyze Lesion',
                          style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// NEW: Crop Screen with initialized box and fixed offset
class CropScreen extends StatefulWidget {
  final String imagePath;

  const CropScreen({super.key, required this.imagePath});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final GlobalKey _imageKey = GlobalKey();

  // Crop rectangle in image widget coordinates
  Rect? _cropRect;
  Size? _imageWidgetSize;
  Size? _actualImageSize;

  // For dragging
  String?
      _activeHandle; // 'topLeft', 'topRight', 'bottomLeft', 'bottomRight', 'move'
  Offset? _dragStart;
  Rect? _initialRect;

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    final imageFile = File(widget.imagePath);
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image != null && mounted) {
      setState(() {
        _actualImageSize =
            Size(image.width.toDouble(), image.height.toDouble());
      });
      // Initialize crop rect after first frame
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _initializeCropRect());
    }
  }

  void _initializeCropRect() {
    final RenderBox? imageBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (imageBox == null) return;

    final imageWidgetSize = imageBox.size;
    setState(() {
      _imageWidgetSize = imageWidgetSize;
      // Initialize a centered square crop box (80% of smaller dimension)
      final minDim = imageWidgetSize.width < imageWidgetSize.height
          ? imageWidgetSize.width
          : imageWidgetSize.height;
      final boxSize = minDim * 0.8;
      final left = (imageWidgetSize.width - boxSize) / 2;
      final top = (imageWidgetSize.height - boxSize) / 2;
      _cropRect = Rect.fromLTWH(left, top, boxSize, boxSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Crop Image'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_cropRect != null)
            TextButton(
              onPressed: _cropImage,
              child: const Text(
                'DONE',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Stack(
                      children: [
                        Image.file(
                          File(widget.imagePath),
                          key: _imageKey,
                          fit: BoxFit.contain,
                        ),
                        if (_cropRect != null && _imageWidgetSize != null)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: CropOverlayPainter(
                                cropRect: _cropRect!,
                                imageSize: _imageWidgetSize!,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: const Text(
              'Drag corners to resize • Drag center to move',
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (_cropRect == null || _imageWidgetSize == null) return;

    final RenderBox? imageBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (imageBox == null) return;

    // Convert global position to image widget local position
    final localPos = imageBox.globalToLocal(details.globalPosition);

    // Check which handle or area is being touched
    const handleSize = 40.0;
    final rect = _cropRect!;

    if (_isNear(localPos, rect.topLeft, handleSize)) {
      _activeHandle = 'topLeft';
    } else if (_isNear(localPos, rect.topRight, handleSize)) {
      _activeHandle = 'topRight';
    } else if (_isNear(localPos, rect.bottomLeft, handleSize)) {
      _activeHandle = 'bottomLeft';
    } else if (_isNear(localPos, rect.bottomRight, handleSize)) {
      _activeHandle = 'bottomRight';
    } else if (rect.contains(localPos)) {
      _activeHandle = 'move';
    } else {
      _activeHandle = null;
    }

    _dragStart = localPos;
    _initialRect = _cropRect;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeHandle == null || _dragStart == null || _initialRect == null)
      return;
    if (_imageWidgetSize == null) return;

    final RenderBox? imageBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (imageBox == null) return;

    final localPos = imageBox.globalToLocal(details.globalPosition);
    final delta = localPos - _dragStart!;

    setState(() {
      final minSize = 50.0;
      Rect newRect = _initialRect!;

      switch (_activeHandle) {
        case 'topLeft':
          newRect = Rect.fromLTRB(
            (_initialRect!.left + delta.dx)
                .clamp(0, _initialRect!.right - minSize),
            (_initialRect!.top + delta.dy)
                .clamp(0, _initialRect!.bottom - minSize),
            _initialRect!.right,
            _initialRect!.bottom,
          );
          break;
        case 'topRight':
          newRect = Rect.fromLTRB(
            _initialRect!.left,
            (_initialRect!.top + delta.dy)
                .clamp(0, _initialRect!.bottom - minSize),
            (_initialRect!.right + delta.dx)
                .clamp(_initialRect!.left + minSize, _imageWidgetSize!.width),
            _initialRect!.bottom,
          );
          break;
        case 'bottomLeft':
          newRect = Rect.fromLTRB(
            (_initialRect!.left + delta.dx)
                .clamp(0, _initialRect!.right - minSize),
            _initialRect!.top,
            _initialRect!.right,
            (_initialRect!.bottom + delta.dy)
                .clamp(_initialRect!.top + minSize, _imageWidgetSize!.height),
          );
          break;
        case 'bottomRight':
          newRect = Rect.fromLTRB(
            _initialRect!.left,
            _initialRect!.top,
            (_initialRect!.right + delta.dx)
                .clamp(_initialRect!.left + minSize, _imageWidgetSize!.width),
            (_initialRect!.bottom + delta.dy)
                .clamp(_initialRect!.top + minSize, _imageWidgetSize!.height),
          );
          break;
        case 'move':
          var newLeft = _initialRect!.left + delta.dx;
          var newTop = _initialRect!.top + delta.dy;
          // Keep within bounds
          newLeft =
              newLeft.clamp(0, _imageWidgetSize!.width - _initialRect!.width);
          newTop =
              newTop.clamp(0, _imageWidgetSize!.height - _initialRect!.height);
          newRect = Rect.fromLTWH(
              newLeft, newTop, _initialRect!.width, _initialRect!.height);
          break;
      }

      _cropRect = newRect;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _activeHandle = null;
    _dragStart = null;
    _initialRect = null;
  }

  bool _isNear(Offset point, Offset target, double threshold) {
    return (point - target).distance < threshold;
  }

  Future<void> _cropImage() async {
    if (_cropRect == null ||
        _actualImageSize == null ||
        _imageWidgetSize == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Load image
      final imageFile = File(widget.imagePath);
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      // Calculate scale from widget coordinates to actual image pixels
      final scaleX = _actualImageSize!.width / _imageWidgetSize!.width;
      final scaleY = _actualImageSize!.height / _imageWidgetSize!.height;

      // Convert crop rect to actual image coordinates
      final cropX =
          (_cropRect!.left * scaleX).round().clamp(0, image.width - 1);
      final cropY =
          (_cropRect!.top * scaleY).round().clamp(0, image.height - 1);
      final cropWidth =
          (_cropRect!.width * scaleX).round().clamp(1, image.width - cropX);
      final cropHeight =
          (_cropRect!.height * scaleY).round().clamp(1, image.height - cropY);

      // Crop image
      final croppedImage = img.copyCrop(
        image,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      // Save cropped image
      final croppedPath =
          '${imageFile.parent.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(img.encodeJpg(croppedImage));

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close crop screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => PreviewScreen(imagePath: croppedPath)),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cropping image: $e')),
        );
      }
    }
  }
}

// Custom Painter for crop rectangle (legacy - kept for reference)
class CropPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  CropPainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Rect.fromPoints(start, end);
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Draw corner handles
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const handleSize = 12.0;
    canvas.drawCircle(Offset(rect.left, rect.top), handleSize, handlePaint);
    canvas.drawCircle(Offset(rect.right, rect.top), handleSize, handlePaint);
    canvas.drawCircle(Offset(rect.left, rect.bottom), handleSize, handlePaint);
    canvas.drawCircle(Offset(rect.right, rect.bottom), handleSize, handlePaint);
  }

  @override
  bool shouldRepaint(CropPainter oldDelegate) => true;
}

// Crop overlay painter with darkened background outside crop area
class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final Size imageSize;

  CropOverlayPainter({required this.cropRect, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw semi-transparent overlay outside crop area
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Draw four rectangles around the crop area
    // Top
    canvas.drawRect(
      Rect.fromLTRB(0, 0, imageSize.width, cropRect.top),
      overlayPaint,
    );
    // Bottom
    canvas.drawRect(
      Rect.fromLTRB(0, cropRect.bottom, imageSize.width, imageSize.height),
      overlayPaint,
    );
    // Left
    canvas.drawRect(
      Rect.fromLTRB(0, cropRect.top, cropRect.left, cropRect.bottom),
      overlayPaint,
    );
    // Right
    canvas.drawRect(
      Rect.fromLTRB(
          cropRect.right, cropRect.top, imageSize.width, cropRect.bottom),
      overlayPaint,
    );

    // Draw crop rectangle border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(cropRect, borderPaint);

    // Draw corner handles
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final handleBorderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const handleSize = 14.0;

    // Draw filled circles with blue border at corners
    for (final corner in [
      cropRect.topLeft,
      cropRect.topRight,
      cropRect.bottomLeft,
      cropRect.bottomRight,
    ]) {
      canvas.drawCircle(corner, handleSize, handlePaint);
      canvas.drawCircle(corner, handleSize, handleBorderPaint);
    }

    // Draw grid lines (rule of thirds)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final thirdWidth = cropRect.width / 3;
    final thirdHeight = cropRect.height / 3;

    // Vertical lines
    canvas.drawLine(
      Offset(cropRect.left + thirdWidth, cropRect.top),
      Offset(cropRect.left + thirdWidth, cropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left + 2 * thirdWidth, cropRect.top),
      Offset(cropRect.left + 2 * thirdWidth, cropRect.bottom),
      gridPaint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + thirdHeight),
      Offset(cropRect.right, cropRect.top + thirdHeight),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + 2 * thirdHeight),
      Offset(cropRect.right, cropRect.top + 2 * thirdHeight),
      gridPaint,
    );
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) =>
      cropRect != oldDelegate.cropRect || imageSize != oldDelegate.imageSize;
}

// Processing Screen
class ProcessingScreen extends StatefulWidget {
  final String imagePath;

  const ProcessingScreen({super.key, required this.imagePath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final SkinCancerClassifier _classifier = SkinCancerClassifier();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _runClassification();
  }

  Future<void> _runClassification() async {
    try {
      // Initialize classifier and run inference
      await _classifier.initialize();
      final result = await _classifier.classifyImage(widget.imagePath);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              imagePath: widget.imagePath,
              prediction: result.displayLabel,
              confidence: result.confidence,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Classification failed: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Colors.white],
          ),
        ),
        child: Center(
          child: _errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Analysis Failed',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 4),
                    SizedBox(height: 24),
                    Text(
                      'Analyzing Image...',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'AI model is processing your image',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Results Screen
class ResultsScreen extends StatefulWidget {
  final String imagePath;
  final String prediction;
  final double confidence;

  const ResultsScreen({
    super.key,
    required this.imagePath,
    required this.prediction,
    required this.confidence,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    // Automatically save to history when results are shown
    _saveToHistory();
  }

  void _saveToHistory() {
    final scan = ScanResult(
      imagePath: widget.imagePath,
      prediction: widget.prediction,
      confidence: widget.confidence,
      date: DateTime.now(),
    );
    ScanHistoryManager.addScan(scan);
    setState(() {
      _isSaved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBenign = widget.prediction.toLowerCase() == 'benign';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(widget.imagePath),
                      height: 128,
                      width: 128,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color:
                          isBenign ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isBenign
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isBenign ? Icons.check_circle : Icons.warning,
                          size: 48,
                          color: isBenign
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isBenign
                              ? 'Likely Benign'
                              : 'Suspicious - Needs Evaluation',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isBenign
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Confidence: ${widget.confidence.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                          left: BorderSide(
                              color: Colors.orange.shade700, width: 4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber,
                            color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Important Disclaimer',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'This result is generated by AI and is NOT a medical diagnosis. Please consult a qualified dermatologist for professional evaluation.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Scan Another Lesion',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isSaved
                          ? 'Already saved to history'
                          : 'Saved to history'),
                      backgroundColor: _isSaved ? Colors.grey : Colors.green,
                    ),
                  );
                },
                icon: Icon(_isSaved ? Icons.check : Icons.save),
                label: Text(_isSaved ? 'Saved to History' : 'Save to History',
                    style: const TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isSaved ? Colors.green.shade100 : Colors.grey.shade200,
                  foregroundColor:
                      _isSaved ? Colors.green.shade700 : Colors.grey.shade700,
                  padding: const EdgeInsets.all(16),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// History Screen
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final history = ScanHistoryManager.getHistory();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear History'),
                    content: const Text(
                        'Are you sure you want to clear all scan history?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            ScanHistoryManager.clearHistory();
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('History cleared')),
                          );
                        },
                        child: const Text('Clear',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No scans yet',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your scan history will appear here',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final scan = history[index];
                final isBenign = scan.prediction.toLowerCase() == 'benign';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultsScreen(
                            imagePath: scan.imagePath,
                            prediction: scan.prediction,
                            confidence: scan.confidence,
                          ),
                        ),
                      ).then((_) => setState(() {})); // Refresh when returning
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(scan.imagePath),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.grey.shade400),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isBenign
                                          ? Icons.check_circle
                                          : Icons.warning,
                                      size: 20,
                                      color: isBenign
                                          ? Colors.green.shade600
                                          : Colors.red.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isBenign ? 'Benign' : 'Suspicious',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isBenign
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Confidence: ${scan.confidence.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 14, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(scan.date),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Info Screen
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('How It Works'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInfoCard(
              'About This App',
              'SkinGuard AI uses artificial intelligence to analyze images of skin lesions and provide preliminary assessments. The AI model has been trained on thousands of dermatological images.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Tips for Best Results',
              '1. Use good lighting - natural daylight works best\n'
                  '2. Keep the camera steady and focused\n'
                  '3. Fill the frame with the lesion\n'
                  '4. Avoid shadows on the lesion\n'
                  '5. Clean the camera lens before capturing\n'
                  '6. Capture from directly above the lesion',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'AI Model Information',
              'Our AI classifier uses a convolutional neural network (CNN) trained to distinguish between benign and potentially suspicious skin lesions based on visual features.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                    left: BorderSide(color: Colors.red.shade700, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medical Disclaimer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This application is designed for educational and screening purposes only. It is NOT a substitute for professional medical advice, diagnosis, or treatment.',
                    style: TextStyle(fontSize: 14, color: Colors.red.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          const BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
                fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }
}
