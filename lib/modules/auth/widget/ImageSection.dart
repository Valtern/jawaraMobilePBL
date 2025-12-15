import 'package:flutter/material.dart';

class ImageSection extends StatelessWidget {
  const ImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurveClipper(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.35,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Rumah.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo dalam kotak ungu bulat
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6938EF),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(0),
                  child: Image.asset(
                    'assets/images/TransIconJawara.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                // Text "JAWARA"
                Text(
                  'JAWARA',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Text instruksi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'SISTEM INFORMASI RT/RW',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final curveHeight = 40.0; // Tinggi kurva

    // Start from top-left
    path.lineTo(0, 0);

    // Line to top-right
    path.lineTo(size.width, 0);

    // Line to bottom-right (before curve)
    path.lineTo(size.width, size.height - curveHeight);

    // Create smooth curve at the bottom using quadratic bezier
    path.quadraticBezierTo(
      size.width / 2, // Control point x (center)
      size.height +
          10, // Control point y (below bottom for smooth upward curve)
      0, // End point x (bottom-left)
      size.height - curveHeight, // End point y (symmetric with right side)
    );

    // Close the path back to start
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
