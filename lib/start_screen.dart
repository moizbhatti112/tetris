import 'package:flutter/material.dart';
import 'package:tetris/board.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Tetris blocks above the title
            SizedBox(height: 80, child: _AnimatedTetrisBlocks()),
            const SizedBox(height: 10),
            // Vibrant, shadowed title
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [
                    Colors.cyanAccent,
                    Colors.purpleAccent,
                    Colors.yellowAccent,
                  ],
                  tileMode: TileMode.mirror,
                ).createShader(bounds);
              },
              child: const Text(
                'TETRIS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Fun subtitle/tagline
            const Text(
              'Stack, Clear, Repeat!',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            // Animated Start Button
            _AnimatedStartButton(),
            const SizedBox(height: 30),
            // Instructions with icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back_ios, color: Colors.grey[400], size: 22),
                Icon(Icons.arrow_downward, color: Colors.grey[400], size: 22),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Move',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
                const SizedBox(width: 16),
                Icon(Icons.rotate_right, color: Colors.grey[400], size: 22),
                const SizedBox(width: 8),
                Text(
                  'Rotate',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Animated Tetris blocks widget
class _AnimatedTetrisBlocks extends StatefulWidget {
  @override
  State<_AnimatedTetrisBlocks> createState() => _AnimatedTetrisBlocksState();
}

class _AnimatedTetrisBlocksState extends State<_AnimatedTetrisBlocks>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, _animation.value),
              child: _block(Colors.cyanAccent),
            ),
            const SizedBox(width: 8),
            Transform.translate(
              offset: Offset(0, -_animation.value),
              child: _block(Colors.purpleAccent),
            ),
            const SizedBox(width: 8),
            Transform.translate(
              offset: Offset(0, _animation.value / 2),
              child: _block(Colors.yellowAccent),
            ),
            const SizedBox(width: 8),
            Transform.translate(
              offset: Offset(0, -_animation.value / 2),
              child: _block(Colors.greenAccent),
            ),
          ],
        );
      },
    );
  }

  Widget _block(Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((0.8 * 255).toInt()),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// Animated Start Button widget
class _AnimatedStartButton extends StatefulWidget {
  @override
  State<_AnimatedStartButton> createState() => _AnimatedStartButtonState();
}

class _AnimatedStartButtonState extends State<_AnimatedStartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const GameBoard()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: Colors.greenAccent,
        ),
        child: const Text(
          'START GAME',
          style: TextStyle(
            fontSize: 26,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
