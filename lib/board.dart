import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tetris/piece.dart';
import 'package:tetris/pixel.dart';
import 'package:tetris/values.dart';

// Define gameBoard as a dynamic structure that will be initialized in the widget
List<List<Tetromino?>> gameBoard = [];

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // current tetris piece
  late Piece currentPiece;
  bool isGameOver = false;
  Timer? gameTimer;

  int linesCleared = 0;
  bool isPaused = false;
  int score = 0;
  int lastScoreIncrease = 0;
  int level = 1;
  int comboCount = 0;
  int tetrisCount = 0;
  int tripleCount = 0;
  int doubleCount = 0;
  int singleCount = 0;
  int maxCombo = 0;

  Duration currentSpeed = const Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    // We'll initialize the game in didChangeDependencies after we have access to the context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Calculate grid dimensions based on screen size
    calculateGridDimensions(context);

    // Only start the game if it's not already started
    if (gameBoard.isEmpty) {
      initializeGameBoard();
      startGame();
    }
  }

  // Initialize the game board based on the calculated dimensions
  void initializeGameBoard() {
    gameBoard = List.generate(cols, (i) => List.generate(rows, (j) => null));
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void startGame() {
    initializeGameBoard();
    isGameOver = false;
    isPaused = false;
    score = 0;
    lastScoreIncrease = 0;
    linesCleared = 0;
    level = 1;
    comboCount = 0;
    maxCombo = 0;
    tetrisCount = 0;
    tripleCount = 0;
    doubleCount = 0;
    singleCount = 0;
    currentSpeed = const Duration(milliseconds: 1500);
    currentPiece = Piece(
      type: Tetromino.values[Random().nextInt(Tetromino.values.length)],
    );
    currentPiece.initializePiece();
    gameLoop(currentSpeed);
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        gameTimer?.cancel();
      } else {
        gameLoop(currentSpeed);
      }
    });
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void gameLoop(Duration frameRate) {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(frameRate, (timer) {
      if (!isGameOver && !isPaused) {
        setState(() {
          checkLanding();
          currentPiece.movePiece(Direction.down);
        });
      } else {
        timer.cancel();
      }
    });
  }

  bool checkCollision(Direction direction) {
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rows).floor();
      int col = currentPiece.position[i] % rows;

      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      // Check for wall collisions
      if (row >= cols || col < 0 || col >= rows) {
        return true;
      }

      // Check for collisions with placed pieces (for all directions)
      if (row >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    return false;
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void checkLanding() {
    if (checkCollision(Direction.down)) {
      // Check if any part of the piece is above the board (game over)
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rows).floor();
        if (row < 0) {
          gameOver();
          return;
        }
      }

      // Place the piece on the board
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rows).floor();
        int col = currentPiece.position[i] % rows;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }

      // Add points for placing a piece (optional)
      setState(() {
        score += 50; // 50 points for placing a piece
        lastScoreIncrease = 50; // Update the score increase
      });

      clearLines();
      createNewPiece();
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void gameOver() {
    setState(() {
      isGameOver = true;
    });
    gameTimer?.cancel();
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void createNewPiece() {
    Random rand = Random();

    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void moveDown() {
    if (!checkCollision(Direction.down) && !isPaused) {
      setState(() {
        currentPiece.movePiece(Direction.down);
        score += softDropPoints;
        lastScoreIncrease = softDropPoints; // Update the score increase
      });
    } else if (!isPaused) {
      // Calculate hard drop points
      int dropDistance = calculateDropDistance();
      int points = dropDistance * hardDropPoints;
      setState(() {
        score += points;
        lastScoreIncrease = points; // Update the score increase
      });
      checkLanding();
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////
  int calculateDropDistance() {
    int distance = 0;

    // Create a temporary copy of the current piece's position
    List<int> testPosition = List.from(currentPiece.position);

    // While the piece can move down, increment the distance
    bool canMoveDown = true;
    while (canMoveDown) {
      // Move the test position down by one row
      for (int i = 0; i < testPosition.length; i++) {
        testPosition[i] += rows;
      }

      // Check if the new position would collide
      canMoveDown = true;
      for (int i = 0; i < testPosition.length; i++) {
        int row = (testPosition[i] / rows).floor();
        int col = testPosition[i] % rows;

        // Check for wall or piece collisions
        if (row >= cols ||
            col < 0 ||
            col >= rows ||
            (row >= 0 && gameBoard[row][col] != null)) {
          canMoveDown = false;
          break;
        }
      }

      if (canMoveDown) {
        distance++;
      }
    }

    return distance;
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void rotatePiece() {
    // Store the original position and rotation state
    List<int> oldPosition = List.from(currentPiece.position);
    int oldRotation = currentPiece.rotationState;

    // Calculate the current piece's bounds
    int minCol = rows;
    int maxCol = 0;
    int minRow = cols;
    int maxRow = 0;

    for (int pos in currentPiece.position) {
      int row = pos ~/ rows;
      int col = pos % rows;
      minCol = minCol < col ? minCol : col;
      maxCol = maxCol > col ? maxCol : col;
      minRow = minRow < row ? minRow : row;
      maxRow = maxRow > row ? maxRow : row;
    }

    // Check if the piece is too close to the edges
    bool isTooCloseToEdge = false;

    // Different edge distance requirements for different pieces
    switch (currentPiece.type) {
      case Tetromino.I:
        // I piece needs 2 cells on each side only when rotating from vertical to horizontal
        if (currentPiece.rotationState % 2 == 0) {
          isTooCloseToEdge = minCol <= 1 || maxCol >= rows - 2;
        } else {
          // Allow rotation from horizontal to vertical without edge checks
          isTooCloseToEdge = false;
        }
        break;
      case Tetromino.O:
        // O piece doesn't need special handling as it doesn't rotate
        break;
      case Tetromino.S:
      case Tetromino.Z:
        // S and Z pieces need 1 cell on each side (same as L, J, and T)
        isTooCloseToEdge = minCol <= 0 || maxCol >= rows - 1;
        break;
      case Tetromino.L:
      case Tetromino.J:
      case Tetromino.T:
        // L, J, and T pieces need 1 cell on each side
        isTooCloseToEdge = minCol <= 0 || maxCol >= rows - 1;
        break;
    }

    // If the piece is too close to the edges, prevent rotation
    if (isTooCloseToEdge) {
      currentPiece.position = oldPosition;
      currentPiece.rotationState = oldRotation;
      return;
    }

    // Try to rotate
    currentPiece.rotate();

    // Calculate new bounds after rotation
    int newMinCol = rows;
    int newMaxCol = 0;
    int newMinRow = cols;
    int newMaxRow = 0;

    for (int pos in currentPiece.position) {
      int row = pos ~/ rows;
      int col = pos % rows;
      newMinCol = newMinCol < col ? newMinCol : col;
      newMaxCol = newMaxCol > col ? newMaxCol : col;
      newMinRow = newMinRow < row ? newMinRow : row;
      newMaxRow = newMaxRow > row ? newMaxRow : row;
    }

    // Check if the piece would go out of bounds after rotation
    bool wouldGoOutOfBounds = false;
    for (int pos in currentPiece.position) {
      int row = pos ~/ rows;
      int col = pos % rows;

      if (row < 0 || row >= cols || col < 0 || col >= rows) {
        wouldGoOutOfBounds = true;
        break;
      }
    }

    // Check for collisions with placed pieces
    bool collision = false;
    for (int pos in currentPiece.position) {
      int row = pos ~/ rows;
      int col = pos % rows;

      if (row >= 0 && gameBoard[row][col] != null) {
        collision = true;
        break;
      }
    }

    // If the piece would go out of bounds or collide, try wall kicks
    if (wouldGoOutOfBounds || collision) {
      // Special wall kicks for I-piece
      if (currentPiece.type == Tetromino.I) {
        List<int> offsets = [
          -1,
          1,
          -2,
          2,
        ]; // Try left, right, left more, right more

        for (int offset in offsets) {
          List<int> kickedPosition =
              currentPiece.position.map((pos) => pos + offset).toList();

          bool valid = true;
          for (int pos in kickedPosition) {
            int row = pos ~/ rows;
            int col = pos % rows;

            if (row < 0 ||
                row >= cols ||
                col < 0 ||
                col >= rows ||
                (row >= 0 && gameBoard[row][col] != null)) {
              valid = false;
              break;
            }
          }

          if (valid) {
            currentPiece.position = kickedPosition;
            setState(() {});
            return;
          }
        }
      } else {
        // For other pieces, try to shift the piece if it's too close to the edges
        int shift = 0;
        if (newMinCol < 0) {
          shift = -newMinCol; // Shift right if too close to left edge
        } else if (newMaxCol >= rows) {
          shift = rows - 1 - newMaxCol; // Shift left if too close to right edge
        }

        if (shift != 0) {
          List<int> shiftedPosition =
              currentPiece.position.map((pos) => pos + shift).toList();

          // Check if the shifted position is valid
          bool valid = true;
          for (int pos in shiftedPosition) {
            int row = pos ~/ rows;
            int col = pos % rows;

            if (row < 0 ||
                row >= cols ||
                col < 0 ||
                col >= rows ||
                (row >= 0 && gameBoard[row][col] != null)) {
              valid = false;
              break;
            }
          }

          if (valid) {
            currentPiece.position = shiftedPosition;
            setState(() {});
            return;
          }
        }
      }

      // If no valid position found, revert to original position and rotation
      currentPiece.position = oldPosition;
      currentPiece.rotationState = oldRotation;
    } else {
      setState(() {});
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void clearLines() {
    int linesClearedThisMove = 0;

    for (int row = cols - 1; row >= 0; row--) {
      bool rowIsFull = true;
      for (int col = 0; col < rows; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }

      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        gameBoard[0] = List.generate(rows, (index) => null);
        linesClearedThisMove++;
        row++;
      }
    }

    if (linesClearedThisMove > 0) {
      // Update line clear statistics
      switch (linesClearedThisMove) {
        case 1:
          singleCount++;
          break;
        case 2:
          doubleCount++;
          break;
        case 3:
          tripleCount++;
          break;
        case 4:
          tetrisCount++;
          break;
      }

      // Calculate score based on lines cleared and level
      int lineScore = 0;
      switch (linesClearedThisMove) {
        case 1:
          lineScore = singleLinePoints * level;
          break;
        case 2:
          lineScore = doubleLinePoints * level;
          break;
        case 3:
          lineScore = tripleLinePoints * level;
          break;
        case 4:
          lineScore = tetrisPoints * level;
          break;
      }

      // Combo system
      comboCount++;
      if (comboCount > maxCombo) {
        maxCombo = comboCount;
      }
      int comboBonus = comboBasePoints * comboCount * level;

      int totalPoints = lineScore + comboBonus;

      setState(() {
        linesCleared += linesClearedThisMove;
        score += totalPoints;
        lastScoreIncrease = totalPoints; // Update the score increase

        // Check for level up based on score (every 100 points)
        int scoreForNextLevel = level * 1000; // 500 points per level
        if (score >= scoreForNextLevel) {
          level++;
          // Calculate new speed (reduce by 50ms per level, with a minimum of 100ms)
          int newSpeed = (800 - (level - 1) * 100).clamp(100, 2000);
          currentSpeed = Duration(milliseconds: newSpeed);

          // Stop the current timer and start a new one with the updated speed
          gameTimer?.cancel();
          gameLoop(currentSpeed);

          debugPrint(
            "Level up to $level! New speed: ${currentSpeed.inMilliseconds}ms",
          );
        }
      });
    } else {
      // Reset combo if no lines were cleared
      comboCount = 0;
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////
  void restartGame() {
    gameTimer?.cancel();
    setState(() {
      isPaused = false;
      startGame();
    });
  }

  /////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    calculateGridDimensions(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: LayoutBuilder(
          builder: (context, constraints) {
            double cellWidth = constraints.maxWidth / rows;
            double cellHeight = constraints.maxHeight / cols;
            double cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;
            double boardWidth = cellSize * rows;
            double boardHeight = cellSize * cols;

            return Column(
              children: [
                // Score and level display with glass effect
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    width: boardWidth + 20,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.3 * 255).round()),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withAlpha((0.1 * 255).round()),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Score',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withAlpha(
                                  (0.7 * 255).round(),
                                ),
                              ),
                            ),
                            Text(
                              score.toString(),
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Level',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withAlpha(
                                  (0.7 * 255).round(),
                                ),
                              ),
                            ),
                            Text(
                              level.toString(),
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Game board and other elements
                Expanded(
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: GridPainter(
                            color: Colors.white.withAlpha((0.05 * 255).round()),
                            rows: rows,
                            cols: cols,
                          ),
                        ),
                      ),
                      // Centered game board with glass effect
                      Center(
                        child: Container(
                          width: boardWidth + 20,
                          height: boardHeight + 20,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha((0.3 * 255).round()),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withAlpha(
                                (0.1 * 255).round(),
                              ),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (0.3 * 255).round(),
                                ),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: GridView.builder(
                                  itemCount: rows * cols,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: rows,
                                      ),
                                  itemBuilder: (context, index) {
                                    int row = (index / rows).floor();
                                    int col = index % rows;
                                    if (currentPiece.position.contains(index)) {
                                      return Pixel(
                                        color: currentPiece.color,
                                        child: '',
                                      );
                                    } else if (row < gameBoard.length &&
                                        col < gameBoard[row].length &&
                                        gameBoard[row][col] != null) {
                                      final Tetromino? tetrominoType =
                                          gameBoard[row][col];
                                      return Pixel(
                                        color: tetroinoColors[tetrominoType],
                                        child: '',
                                      );
                                    } else {
                                      return Pixel(
                                        color: Colors.grey[900],
                                        child: '',
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Controls with glass effect
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 24,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha((0.3 * 255).round()),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withAlpha(
                                (0.1 * 255).round(),
                              ),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildControlButton(
                                onPressed:
                                    isGameOver || isPaused ? null : moveLeft,
                                icon: Icons.arrow_back_ios,
                              ),
                              _buildControlButton(
                                onPressed:
                                    isGameOver || isPaused ? null : rotatePiece,
                                icon: Icons.rotate_right,
                              ),
                              _buildControlButton(
                                onPressed:
                                    isGameOver || isPaused ? null : moveDown,
                                icon: Icons.arrow_downward,
                              ),
                              _buildControlButton(
                                onPressed:
                                    isGameOver || isPaused ? null : moveRight,
                                icon: Icons.arrow_forward_ios,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Pause button with glass effect
                      Positioned(
                        right: 16,
                        top: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha((0.3 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withAlpha(
                                (0.1 * 255).round(),
                              ),
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            onPressed: togglePause,
                            icon: Icon(
                              isPaused ? Icons.play_arrow : Icons.pause,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      // Game Over Overlay
                      if (isGameOver)
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha((0.9 * 255).round()),
                            backgroundBlendMode: BlendMode.darken,
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(
                                  (0.5 * 255).round(),
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withAlpha(
                                    (0.1 * 255).round(),
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'GAME OVER',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(color: Colors.red),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Score: $score',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.displayMedium,
                                  ),
                                  const SizedBox(height: 32),
                                  ElevatedButton(
                                    onPressed: restartGame,
                                    child: const Text('PLAY AGAIN'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      // Pause Overlay
                      if (isPaused && !isGameOver)
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha((0.8 * 255).round()),
                            backgroundBlendMode: BlendMode.darken,
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(
                                  (0.5 * 255).round(),
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withAlpha(
                                    (0.1 * 255).round(),
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'PAUSED',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.displayLarge,
                                  ),
                                  const SizedBox(height: 32),
                                  ElevatedButton(
                                    onPressed: togglePause,
                                    child: const Text('RESUME'),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      togglePause();
                                      restartGame();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.withAlpha(
                                        (0.7 * 255).round(),
                                      ),
                                    ),
                                    child: const Text('RESTART'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      // Score pop-up with animation
                      if (lastScoreIncrease > 0)
                        Positioned(
                          left: 50,
                          top: 100,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, -20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: Text(
                                    '+$lastScoreIncrease',
                                    style: TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withAlpha(
                                            (0.5 * 255).round(),
                                          ),
                                          offset: const Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            onEnd: () {
                              setState(() {
                                lastScoreIncrease = 0;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.3 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha((0.1 * 255).round()),
          width: 2,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color:
              onPressed == null
                  ? Colors.white.withAlpha((0.3 * 255).round())
                  : Colors.white,
          size: 32,
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }
}

// Custom painter for the background grid
class GridPainter extends CustomPainter {
  final Color color;
  final int rows;
  final int cols;

  GridPainter({required this.color, required this.rows, required this.cols});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1;

    // Draw vertical lines
    for (int i = 0; i <= rows; i++) {
      final x = (size.width / rows) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 0; i <= cols; i++) {
      final y = (size.height / cols) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
