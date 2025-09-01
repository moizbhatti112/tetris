import 'package:flutter/material.dart';
import 'package:tetris/values.dart';

class Piece {
  Tetromino type;
  List<int> position = [];
  int rotationState = 0; // Track current rotation state (0-3)

  Piece({required this.type});

  Color get color {
    return tetroinoColors[type] ?? Colors.white;
  }

  void initializePiece() {
    position = getInitialPosition();
    // Set initial rotation state for I piece to be vertical
    if (type == Tetromino.I) {
      rotationState = 0; // Start in vertical position (0 instead of 1)
    }
  }

  List<int> getInitialPosition() {
    // Calculate a starting position at the top of the board
    int centerCol = rows ~/ 2; // Center column

    switch (type) {
      case Tetromino.L:
        // L shape:
        // []
        // []
        // [][]
        return [
          -2 * rows + centerCol - 1, // Top block, one column to the left
          -1 * rows + centerCol - 1, // Middle block, one column to the left
          centerCol - 1, // Bottom block, one column to the left
          centerCol, // Bottom corner block
        ];
      case Tetromino.J:
        // J shape:
        //   []
        //   []
        // [][]
        return [
          -2 * rows + centerCol + 1, // Top block, one column to the right
          -1 * rows + centerCol + 1, // Middle block, one column to the right
          centerCol + 1, // Bottom block, one column to the right
          centerCol, // Bottom corner block
        ];
      case Tetromino.I:
        // I shape (vertical by default):
        // []
        // []
        // []
        // []
        return [
          -3 * rows + centerCol, // Top block
          -2 * rows + centerCol, // Second block
          -1 * rows + centerCol, // Third block
          centerCol, // Bottom block
        ];
      case Tetromino.O:
        // O shape (square):
        // [][]
        // [][]
        return [
          -1 * rows + centerCol, // Top-left
          -1 * rows + centerCol + 1, // Top-right
          centerCol, // Bottom-left
          centerCol + 1, // Bottom-right
        ];
      case Tetromino.S:
        // S shape:
        //  [][]
        // [][]
        return [
          -1 * rows + centerCol, // Top-left
          -1 * rows + centerCol + 1, // Top-right
          centerCol - 1, // Bottom-left
          centerCol, // Bottom-right
        ];
      case Tetromino.Z:
        // Z shape:
        // [][]
        //  [][]
        return [
          -1 * rows + centerCol - 1, // Top-left
          -1 * rows + centerCol, // Top-right
          centerCol, // Bottom-left
          centerCol + 1, // Bottom-right
        ];
      case Tetromino.T:
        // T shape:
        // [][][]
        //   []
        return [
          -1 * rows + centerCol - 1, // Top-left
          -1 * rows + centerCol, // Top-center
          -1 * rows + centerCol + 1, // Top-right
          centerCol, // Bottom-center
        ];
    }
  }

  void movePiece(Direction direction) {
    switch (direction) {
      case Direction.down:
        for (int i = 0; i < position.length; i++) {
          position[i] += rows;
        }
        break;
      case Direction.left:
        for (int i = 0; i < position.length; i++) {
          position[i] -= 1;
        }
        break;
      case Direction.right:
        for (int i = 0; i < position.length; i++) {
          position[i] += 1;
        }
        break;
    }
  }

  void rotate() {
    // Skip rotation for O tetromino
    if (type == Tetromino.O) return;

    // Special case for I tetromino
    if (type == Tetromino.I) {
      // Use the pivot point (center of the piece)
      int pivot = position[1]; // Second block is our reference point

      // Calculate row and column of the pivot
      int pivotRow = (pivot / rows).floor();
      int pivotCol = pivot % rows;

      // Calculate bounds for current position
      int minCol = rows;
      int maxCol = 0;
      int maxRow = 0;

      for (int pos in position) {
        int row = pos ~/ rows;
        int col = pos % rows;
        minCol = minCol < col ? minCol : col;
        maxCol = maxCol > col ? maxCol : col;
        maxRow = maxRow > row ? maxRow : row;
      }

      // Check if we can rotate based on current position
      bool canRotate = true;
      if (rotationState % 2 == 0) {
        // Currently vertical, check if we can rotate to horizontal
        // Need at least 2 cells on each side of the pivot
        canRotate = pivotCol >= 2 && pivotCol <= rows - 3;
      } else {
        // Currently horizontal, always allow rotation to vertical
        canRotate = true;
      }

      if (canRotate) {
        if (rotationState % 2 == 0) {
          // Vertical to horizontal
          position = [
            pivotRow * rows + (pivotCol - 1), // Left of pivot
            pivot, // Pivot position
            pivotRow * rows + (pivotCol + 1), // Right of pivot
            pivotRow * rows + (pivotCol + 2), // Two right of pivot
          ];
        } else {
          // Horizontal to vertical
          position = [
            (pivotRow - 1) * rows + pivotCol, // Above pivot
            pivot, // Pivot position
            (pivotRow + 1) * rows + pivotCol, // Below pivot
            (pivotRow + 2) * rows + pivotCol, // Two below pivot
          ];
        }
        rotationState = (rotationState + 1) % 4;
      }
    } else {
      // Standard rotation for other pieces
      // Use the second block (index 1) as the center of rotation
      int pivot = position[1];
      List<int> newPosition = [];

      for (int i = 0; i < position.length; i++) {
        // Calculate the relative position to the pivot
        int rowOffset = (position[i] / rows).floor() - (pivot / rows).floor();
        int colOffset = position[i] % rows - pivot % rows;

        // Apply rotation matrix (90 degrees clockwise)
        // [x'] = [0 1] [x]
        // [y']   [-1 0] [y]
        int newRowOffset = colOffset;
        int newColOffset = -rowOffset;

        // Calculate new absolute position
        int newPos = pivot + newRowOffset * rows + newColOffset;
        newPosition.add(newPos);
      }

      // For S and Z pieces, ensure the rotation stays within bounds
      if (type == Tetromino.S || type == Tetromino.Z) {
        // Calculate bounds of the new position
        int minCol = rows;
        int maxCol = 0;
        for (int pos in newPosition) {
          int col = pos % rows;
          minCol = minCol < col ? minCol : col;
          maxCol = maxCol > col ? maxCol : col;
        }

        // If the piece would go out of bounds, don't rotate
        if (minCol < 0 || maxCol >= rows) {
          return;
        }
      }

      position = newPosition;
      rotationState = (rotationState + 1) % 4;
    }
  }
}
