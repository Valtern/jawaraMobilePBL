import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class KtpCameraPage extends StatefulWidget {
  const KtpCameraPage({super.key});

  @override
  State<KtpCameraPage> createState() => _KtpCameraPageState();
}

class _KtpCameraPageState extends State<KtpCameraPage> {
  CameraController? _controller;
  bool _isProcessing = false;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false; 

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.high, 
      enableAudio: false,
    );

    await _controller!.initialize();
    
    _toggleFlash(true);

    if (mounted) setState(() => _isCameraInitialized = true);
  }

  Future<void> _toggleFlash(bool enable) async {
    if (_controller == null) return;
    try {
      await _controller!.setFlashMode(enable ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _isFlashOn = enable);
    } catch (e) {
      debugPrint("Flash error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndCrop() async {
    if (_controller == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final XFile rawImage = await _controller!.takePicture();
      _toggleFlash(false); // Turn off after snap

      final File imageFile = File(rawImage.path);
      final bytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      
      if (originalImage != null) {
        // Crop Center 85%
        int cropW = (originalImage.width * 0.85).toInt();
        int cropH = (cropW / 1.58).toInt();
        
        if (cropH > originalImage.height) {
          cropH = (originalImage.height * 0.9).toInt();
          cropW = (cropH * 1.58).toInt();
        }

        int offsetX = (originalImage.width - cropW) ~/ 2;
        int offsetY = (originalImage.height - cropH) ~/ 2;

        img.Image cropped = img.copyCrop(originalImage, x: offsetX, y: offsetY, width: cropW, height: cropH);
        img.Image resized = img.copyResize(cropped, width: 1000);
        
        await imageFile.writeAsBytes(img.encodeJpg(resized, quality: 85));
        
        if (mounted) Navigator.pop(context, imageFile);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraInitialized) Center(child: CameraPreview(_controller!)),
          if (_isCameraInitialized) _buildOverlay(context),
          
          // Flash Toggle Button (Top Right)
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white, size: 30),
              onPressed: () => _toggleFlash(!_isFlashOn),
            ),
          ),

          const Positioned(
            top: 100,
            left: 0, right: 0,
            child: Text("Posisikan KTP di dalam kotak", 
              textAlign: TextAlign.center, 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ),

          if (_isProcessing)
            Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: Colors.white))),

          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePictureAndCrop,
                child: Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.grey, width: 4)),
                  child: const Icon(Icons.camera_alt, size: 30, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return LayoutBuilder(builder: (ctx, cons) {
      final double boxWidth = cons.maxWidth * 0.85;
      final double boxHeight = boxWidth / 1.58;
      return Stack(children: [
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(children: [
            Container(decoration: const BoxDecoration(color: Colors.transparent, backgroundBlendMode: BlendMode.dstOut)),
            Center(child: Container(width: boxWidth, height: boxHeight, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)))),
          ]),
        ),
        Center(child: Container(width: boxWidth, height: boxHeight, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(12))))
      ]);
    });
  }
}