import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LiquidBackground extends StatelessWidget {
  final Widget child;
  const LiquidBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark gradient
        Container(
          decoration: const BoxDecoration(gradient: AppTheme.liquidGradient),
        ),
        // Abstract Orbs/Blobs
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  blurRadius: 100,
                  spreadRadius: 20,
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFA000).withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  blurRadius: 100,
                  spreadRadius: 20,
                  color: const Color(0xFFFFA000).withValues(alpha: 0.1),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1F3C).withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  blurRadius: 80,
                  spreadRadius: 10,
                  color: const Color(0xFF1A1F3C).withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
