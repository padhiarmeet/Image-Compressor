import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Compression App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ImageCompressionHomepage(),
    );
  }
}

class ImageCompressionHomepage extends StatefulWidget {
  @override
  _ImageCompressionHomepageState createState() => _ImageCompressionHomepageState();
}

class _ImageCompressionHomepageState extends State<ImageCompressionHomepage> {
  // Stores the original image
  File? _selectedImage;

  // Stores the compressed image
  File? _compressedImage;

  // Checks if compression is in progress
  bool _isCompressing = false;

  // Stores error messages
  String? _error;

  // Function to pick an image from the gallery
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          // Store the selected image
          _selectedImage = File(pickedFile.path);
          // Reset previous compressed image
          _compressedImage = null;
          // Clear any previous error
          _error = null;
          // Show that compression is starting
          _isCompressing = true;
        });

        // Compress the selected image
        await compressImage(_selectedImage!);
      }
    } catch (e) {
      setState(() {
        // Store error message
        _error = 'Error picking image: $e';
        // Stop compressing state
        _isCompressing = false;
      });
    }
  }

  // Function to pick an image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _compressedImage = null;
          _error = null;
          _isCompressing = true;
        });

        await compressImage(_selectedImage!);
      }
    } catch (e) {
      setState(() {
        _error = 'Error taking photo: $e';
        _isCompressing = false;
      });
    }
  }

  // Function to compress the selected image
  Future<void> compressImage(File image) async {
    try {
      // Get a temporary directory to store the compressed image
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_image.jpg';

      // Compress the image and store it in the new location
      var result = await FlutterImageCompress.compressAndGetFile(
        image.absolute.path,
        targetPath,
        // Set image quality (lower value = more compression)
        quality: 85,
        minWidth: 1080,
        minHeight: 720,
      );

      if (result != null) {
        final compressedFile = File(result.path);

        if (await compressedFile.exists()) {
          final originalSize = await image.length();
          final compressedSize = await compressedFile.length();

          setState(() {
            // Save the compressed image
            _compressedImage = compressedFile;
            // Compression is done
            _isCompressing = false;
            // Clear any error messages
            _error = null;
          });

          // Print the sizes of original and compressed images
          print('Original size: ${(originalSize / 1024).toStringAsFixed(2)} KB');
          print('Compressed size: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
        } else {
          throw Exception('Compressed file not found at path: $targetPath');
        }
      } else {
        throw Exception('Compression returned null path');
      }
    } catch (e) {
      setState(() {
        // Store error message
        _error = 'Error compressing image: $e';
        // Stop compressing state
        _isCompressing = false;
      });
      print('Error compressing image: $e');
    }
  }

  // Function to reset all images
  void resetImages() {
    setState(() {
      _selectedImage = null;
      _compressedImage = null;
      _error = null;
      _isCompressing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Compression'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.compress,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome to Image Compressor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Compress your images to reduce file size while maintaining quality',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isCompressing ? null : pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isCompressing ? null : pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Reset button
            if (_selectedImage != null || _compressedImage != null)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: resetImages,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),

            const SizedBox(height: 20),

            // Loading indicator
            if (_isCompressing)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Compressing image...'),
                    ],
                  ),
                ),
              ),

            // Error message
            if (_error != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Original image display
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Original Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ),
            ],

            // Compressed image display
            if (_compressedImage != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Compressed Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _compressedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ),
            ],

            // File size comparison
            if (_selectedImage != null && _compressedImage != null)
              FutureBuilder<List<int>>(
                future: Future.wait([
                  _selectedImage!.length(),
                  _compressedImage!.length(),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final originalSize = snapshot.data![0] / 1024;
                    final compressedSize = snapshot.data![1] / 1024;
                    final savings = ((originalSize - compressedSize) / originalSize * 100);

                    return Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Original Size:'),
                                Text('${originalSize.toStringAsFixed(2)} KB'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Compressed Size:'),
                                Text('${compressedSize.toStringAsFixed(2)} KB'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Space Saved:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${savings.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
          ],
        ),
      ),
    );
  }
}
