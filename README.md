<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/TensorFlow_Lite-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white" alt="TensorFlow Lite"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License"/>
</p>

<h1 align="center">🔬 SkinGuard AI</h1>

<p align="center">
  <strong>AI-Powered Skin Lesion Detection Assistant</strong>
</p>

<p align="center">
  A cross-platform mobile application built with Flutter that uses machine learning to analyze skin lesions and provide preliminary assessments for potential skin cancer indicators.
</p>

---

## ⚠️ Medical Disclaimer

> **This application is for educational and screening purposes only.** It is NOT a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified dermatologist for professional evaluation of any skin concerns.

---

## ✨ Features

### 🎯 Core Functionality
- **AI-Powered Analysis** - Uses a fine-tuned MobileNetV2 TensorFlow Lite model for on-device skin lesion classification
- **Camera Integration** - Capture images directly using the device camera with positioning guides
- **Gallery Support** - Upload existing images from your photo library
- **Image Cropping** - Advanced crop tool with rule-of-thirds grid for precise lesion targeting
- **Real-time Processing** - Fast on-device inference without requiring internet connection

### 📊 Classification Results
- **Binary Classification** - Distinguishes between benign and suspicious (potentially malignant) lesions
- **Confidence Scores** - Displays AI confidence percentage for each prediction
- **Visual Feedback** - Color-coded results with clear visual indicators

### 📱 User Experience
- **Scan History** - Automatically saves and tracks all previous scans
- **Modern UI** - Clean, intuitive Material Design 3 interface
- **Educational Content** - Built-in guide explaining how to capture optimal images
- **Cross-Platform** - Runs on Android, iOS, Windows, macOS, Linux, and Web

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter 3.x** | Cross-platform UI framework |
| **Dart 3.x** | Programming language |
| **TensorFlow Lite** | On-device ML inference |
| **MobileNetV2** | CNN architecture for image classification |
| **image_picker** | Camera and gallery integration |
| **image** | Image processing and manipulation |

---

## 📋 Prerequisites

Before running this project, ensure you have:

- **Flutter SDK** >= 3.0.0
- **Dart SDK** >= 3.0.0 < 4.0.0
- **Android Studio** / **VS Code** with Flutter extensions
- **Android SDK** (for Android builds)
- **Xcode** (for iOS/macOS builds)

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yahyaismail134/SkinCancerApp.git
cd SkinCancerApp
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the Application

```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For Windows
flutter run -d windows

# For Web
flutter run -d chrome
```

---

## 📁 Project Structure

```
SkinCancerApp/
├── lib/
│   ├── main.dart                    # Main app entry point & UI screens
│   └── skin_cancer_classifier.dart  # TFLite model inference logic
├── assets/
│   ├── model_unquant.tflite         # Pre-trained ML model
│   └── labels.txt                   # Classification labels
├── android/                         # Android-specific configuration
├── ios/                             # iOS-specific configuration
├── windows/                         # Windows-specific configuration
├── macos/                           # macOS-specific configuration
├── linux/                           # Linux-specific configuration
├── web/                             # Web-specific configuration
└── pubspec.yaml                     # Project dependencies
```

---

## 🧠 AI Model

### Architecture
The application uses a **MobileNetV2** convolutional neural network fine-tuned for binary skin lesion classification. The model:

- **Input**: 224×224 RGB images
- **Output**: Binary classification (benign/malignant)
- **Format**: TensorFlow Lite (optimized for mobile inference)

### Classification Output
| Label | Display Name | Description |
|-------|--------------|-------------|
| `benign` | Likely Benign | Lesion appears non-cancerous |
| `malignant` | Suspicious | Lesion shows potential concerning features |

---

## 📱 Application Screens

| Screen | Description |
|--------|-------------|
| **Home** | Main landing page with navigation options |
| **Camera** | Live camera view with positioning guide |
| **Preview** | Review captured/uploaded image before analysis |
| **Crop** | Interactive image cropping with corner handles |
| **Processing** | Loading screen during AI inference |
| **Results** | Classification results with confidence score |
| **History** | Timeline of previous scans |
| **Info** | Educational content and usage tips |

---

## 📸 Usage Tips for Best Results

1. **Use good lighting** - Natural daylight works best
2. **Keep the camera steady** and focused on the lesion
3. **Fill the frame** with the lesion
4. **Avoid shadows** on the lesion area
5. **Clean the camera lens** before capturing
6. **Capture from directly above** the lesion for accurate perspective

---

## 🔧 Configuration

### Android Permissions
Required permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- Camera access
- Storage access (for gallery images)

### iOS Permissions
Required permissions are configured in `ios/Runner/Info.plist`:
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Yahya Ismail
```

---

## 👤 Author

**Yahya Ismail**

- GitHub: [@yahyaismail134](https://github.com/yahyaismail134)

---

## 🙏 Acknowledgments

- TensorFlow team for TensorFlow Lite
- Flutter team for the amazing cross-platform framework
- The open-source community for various packages used in this project

---

<p align="center">
  Made with ❤️ and Flutter
</p>