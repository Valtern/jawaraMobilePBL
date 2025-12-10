// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:jawarapbl/modules/auth/pages/login.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );

//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );

//     _controller.forward();

//     // Navigasi ke halaman login setelah animasi selesai
//     Future.delayed(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         PageTransition(
//           type: PageTransitionType.fade,
//           duration: const Duration(milliseconds: 800),
//           child: const LoginPage(),
//         ),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: FadeTransition(
//           opacity: _animation,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Logo Aplikasi
//               Image.asset(
//                 'assets/images/LogoJawara.png',
//                 width: 150,
//                 height: 150,
//                 fit: BoxFit.contain,
//               ),
//               const SizedBox(height: 20),
//               // Nama Aplikasi dengan Animasi
//               const Text(
//                 'Jawara',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF6C5CE7),
//                   fontFamily: 'Poppins',
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Animasi Loading Lottie
//               SizedBox(
//                 width: 100,
//                 height: 100,
//                 child: Lottie.asset(
//                   'assets/animations/loading_animation.json', // Ganti dengan path animasi Lottie Anda
//                   controller: _controller,
//                   onLoaded: (composition) {
//                     _controller
//                       ..duration = composition.duration
//                       ..forward();
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }