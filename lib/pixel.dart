import 'package:flutter/material.dart';

// This is a custom widget that represents a single cell/pixel on the Tetris board
class Pixel extends StatelessWidget {
  final Color? color;
  final String child;

  // Constructor for creating a Pixel with a specific color and optional child widget
  const Pixel({super.key, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        gradient:
            color != Colors.grey[900]
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color!.withAlpha((0.8 * 255).round()), color!],
                )
                : null,
        boxShadow: [
          if (color != Colors.grey[900])
            BoxShadow(
              color: color!.withAlpha((0.3 * 255).round()),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          BoxShadow(
            color:
                color != Colors.grey[900]
                    ? Colors.white.withAlpha((0.2 * 255).round())
                    : Colors.transparent,
            offset: const Offset(-1, -1),
            blurRadius: 1,
          ),
          BoxShadow(
            color:
                color != Colors.grey[900]
                    ? Colors.black.withAlpha((0.2 * 255).round())
                    : Colors.transparent,
            offset: const Offset(1, 1),
            blurRadius: 1,
          ),
        ],
        border: Border.all(
          color:
              color != Colors.grey[900]
                  ? Colors.white.withAlpha((0.2 * 255).round())
                  : Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          child,
          style: TextStyle(
            color:
                color != Colors.grey[900]
                    ? Colors.white.withAlpha((0.8 * 255).round())
                    : Colors.transparent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
