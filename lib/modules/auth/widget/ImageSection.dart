import 'package:flutter/material.dart';

class ImageSection extends StatelessWidget {
  const ImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryPurple = Color(0xFF5F3FFF);
    const accentPink = Color(0xFFFF6FD8);

    return Container(
      height: MediaQuery.of(context).size.height * 0.36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryPurple,
            accentPink,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Opacity(
              opacity: 0.18,
              child: Padding(
                padding: const EdgeInsets.only(right: 24.0, bottom: 24.0),
                child: SizedBox(
                  height: 120,
                  child: Image.asset(
                    'assets/images/school.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Jawara Pintar',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Solusi digital untuk manajemen warga',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
