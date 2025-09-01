import 'package:flutter/material.dart';
import 'dart:math' as math;

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:   Color(0xFF232B3A),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Gradient background with stars
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1220), // darker blue-black
                  Color(0xFF1A2332), // medium blue-gray
                  Color(0xFF232B3A), // lighter blue-gray
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: CustomPaint(
              painter: StarsPainter(),
              size: Size.infinite,
            ),
          ),
          // Moon and star at top right
          Positioned(
            top: 50,
            right: 32,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    top: 20,
                    child: Image.asset('assets/images/moon.png',height: 60,width: 60,)
                  ),
                  Positioned(
                    top: 0,
                    right: 15,
                    child: Icon(
                      Icons.star,
                      color: const Color(0xFFF6E7B2),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                children: [
                  const SizedBox(height: 60),
                  Text(
                    "TODAY'S MYSTERY O\nAI PROMPT",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7B9BBF),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'What values do you\nfind most important\nin life?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'TRUE PARTICIPATION',
                    style: TextStyle(
                      color: Color(0xFF7B9BBF),
                      fontSize: 14,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Robot illustration
                
                  const Spacer(),

                  Image.asset('assets/images/robot.png',height: 300,width: 300,),
                  // Text field with mic icon
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Color(0xFF2A3441),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF4A90E2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Tap here to start typing...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF7B9BBF),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              _textController.clear();
                            },
                            child: Icon(
                              Icons.refresh,
                              color: Color(0xFF7B9BBF),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom section
              
                ],
              ),
            ),
          ),
        ),
      ),)
        ],
      ),
    );
  }
}

class StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent stars
    
    // Define exclusion zone for text area (approximate position of "TODAY'S MYSTERY AI PROMPT")
    final textExclusionRect = Rect.fromLTWH(
      size.width * 0.1, // 10% from left
      size.height * 0.12, // Around 12% from top (after SafeArea + spacing)
      size.width * 0.8, // 80% width
      size.height * 0.15, // 15% height to cover the text area
    );
    
    // Further reduced number of stars for minimal, elegant look
    // Small dim stars
    final dimPaint = Paint()
      ..color = Color.fromARGB(120, 216, 194, 116)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 20; i++) {
      double x, y;
      do {
        x = random.nextDouble() * size.width;
        y = random.nextDouble() * size.height;
      } while (textExclusionRect.contains(Offset(x, y)));
      
      final starSize = random.nextDouble() * 2 + 1; // Very small stars
      _drawStar(canvas, dimPaint, Offset(x, y), starSize);
    }
    
    // Medium brightness stars
    final mediumPaint = Paint()
      ..color = Color.fromARGB(180, 216, 194, 116)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 10; i++) {
      double x, y;
      do {
        x = random.nextDouble() * size.width;
        y = random.nextDouble() * size.height;
      } while (textExclusionRect.contains(Offset(x, y)));
      
      final starSize = random.nextDouble() * 3 + 1.5;
      _drawStar(canvas, mediumPaint, Offset(x, y), starSize);
    }
    
    // Bright stars
    final brightPaint = Paint()
      ..color = Color.fromARGB(255, 246, 231, 178)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 5; i++) {
      double x, y;
      do {
        x = random.nextDouble() * size.width;
        y = random.nextDouble() * size.height;
      } while (textExclusionRect.contains(Offset(x, y)));
      
      final starSize = random.nextDouble() * 4 + 2;
      _drawStar(canvas, brightPaint, Offset(x, y), starSize);
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double size) {
    const int numPoints = 5;
    final double outerRadius = size;
    final double innerRadius = size * 0.4;
    
    final Path path = Path();
    
    for (int i = 0; i < numPoints * 2; i++) {
      final double angle = (i * math.pi) / numPoints;
      final double radius = i.isEven ? outerRadius : innerRadius;
      
      final double x = center.dx + radius * math.cos(angle - math.pi / 2);
      final double y = center.dy + radius * math.sin(angle - math.pi / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}