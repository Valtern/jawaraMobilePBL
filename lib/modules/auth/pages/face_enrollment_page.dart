import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:jawarapbl/services/auth_services.dart';

class FaceEnrollmentPage extends StatefulWidget {
  final int userId;
  const FaceEnrollmentPage({super.key, required this.userId});

  @override
  State<FaceEnrollmentPage> createState() => _FaceEnrollmentPageState();
}

class _FaceEnrollmentPageState extends State<FaceEnrollmentPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  
  final List<File> _capturedImages = [];
  final AuthService _authService = AuthService();
  
  bool _isRecording = false;
  bool _isUploading = false;
  
  final int _targetPhotoCount = 40; 
  final Duration _burstInterval = const Duration(milliseconds: 250); 

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium, 
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _capturedImages.clear();
    });
    // This triggers the UI rebuild to turn the screen WHITE
    _captureBurst();
  }

  Future<void> _captureBurst() async {
    // Stop if we left the page or stopped recording
    if (!_isRecording || _controller == null || !_controller!.value.isInitialized) return;

    try {
      if (_controller!.value.isTakingPicture) {
        // If camera is busy, retry a bit later
        Future.delayed(const Duration(milliseconds: 100), _captureBurst);
        return;
      }

      // Force exposure auto to adjust to the new bright screen
      await _controller!.setExposureMode(ExposureMode.auto);

      final image = await _controller!.takePicture();
      
      if (!mounted) return;

      setState(() {
        _capturedImages.add(File(image.path));
      });

      if (_capturedImages.length < _targetPhotoCount) {
        Future.delayed(_burstInterval, _captureBurst);
      } else {
        _finishRecordingAndUpload();
      }
    } catch (e) {
      debugPrint("Error taking picture: $e");
      // If error occurs (e.g. camera glitch), keep trying until we hit target count
      if (_capturedImages.length < _targetPhotoCount && _isRecording) {
         Future.delayed(_burstInterval, _captureBurst);
      }
    }
  }

  Future<void> _finishRecordingAndUpload() async {
    setState(() {
      _isRecording = false;
      _isUploading = true;
    });

    final errorMessage = await _authService.enrollFace(
      _capturedImages, 
      widget.userId
    );

    if (!mounted) return;

    if (errorMessage == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Wajah berhasil direkam dengan pencahayaan penuh!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); 
                // Go to login or back to profile depending on flow
                Navigator.of(context).pop(); 
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _isUploading = false;
        _capturedImages.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $errorMessage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isRecording ? Colors.white : Colors.black,
      // Hide AppBar during recording to maximize white screen area
      appBar: _isRecording ? null : AppBar(title: const Text("Scan Wajah")),
      
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // 1. Camera Preview
                Center(
                  child: Container(
                    // If recording: Shrink preview to a circle to let white background dominate
                    width: _isRecording ? 250 : double.infinity,
                    height: _isRecording ? 250 : double.infinity,
                    decoration: BoxDecoration(
                      shape: _isRecording ? BoxShape.circle : BoxShape.rectangle,
                      border: _isRecording ? Border.all(color: Colors.green, width: 4) : null,
                    ),
                    child: ClipOval(
                      clipper: _isRecording ? _CircleClipper() : null,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),

                // 2. Instructions (When NOT recording)
                if (!_isRecording && !_isUploading)
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "💡 Mode Malam Aktif",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Layar akan menyala PUTIH TERANG. Dekatkan wajah ke layar agar pencahayaan maksimal.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _startRecording,
                              icon: const Icon(Icons.flash_on, size: 28),
                              label: const Text("Mulai Scan", style: TextStyle(fontSize: 18)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.amber[700], 
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 3. Progress Overlay (When recording)
                if (_isRecording)
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        const Text(
                          "TAHAN POSISI",
                          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${_capturedImages.length} / $_targetPhotoCount",
                          style: const TextStyle(color: Colors.green, fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.0),
                          child: Text(
                            "Gerakkan kepala sedikit (atas, bawah, kiri, kanan) untuk hasil terbaik.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 4. Uploading Loading Screen
                if (_isUploading)
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text(
                            "Memproses data biometrik...",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class _CircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );
  }
  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}