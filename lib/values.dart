// // values.dart
// import 'dart:ui';

// int rows = 10;
// int cols = 15;

// enum Direction { left, right, down }

// enum Tetromino { L, J, I, O, S, Z, T }

// const Map<Tetromino, Color> tetroinoColors = {
//   Tetromino.L: Color(0xFF00FF00),
//   Tetromino.J: Color(0xFF0000FF),
//   Tetromino.I: Color(0xFFFF0000),
//   Tetromino.O: Color(0xFFFFFF00),
//   Tetromino.S: Color(0xFFFF00FF),
//   Tetromino.Z: Color(0xFF00FFFF),
//   Tetromino.T: Color(0xFFFFA500),
// };

// // Scoring constants
// const int singleLinePoints = 100;
// const int doubleLinePoints = 300;
// const int tripleLinePoints = 500;
// const int tetrisPoints = 800;
// const int pointsPerLevel = 10; // Lines needed to level up
// const int softDropPoints = 1; // Points per cell soft dropped
// const int hardDropPoints = 2; // Points per cell hard dropped
// const int comboBasePoints = 50;

// values.dart
import 'package:flutter/material.dart';

// These will be overridden dynamically by the calculateGridDimensions function
int rows = 12; // Default fallback value (increased from 10)
int cols = 15; // Default fallback value

// Target aspect ratio for the game board (height:width)
const double targetAspectRatio = 1.2; // Less tall, more wide

// Minimum and maximum grid dimensions to ensure the game remains playable
const int minRows = 12; // Increased from 10
const int maxRows = 30;
const int minCols = 10;
const int maxCols = 40;

// Target cell size in logical pixels
const double targetCellSize = 30.0;

// Function to calculate grid dimensions based on screen size
void calculateGridDimensions(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  final double availableWidth = screenSize.width * 0.98; // Use almost all width
  final double availableHeight = screenSize.height * 0.80; // Use more height

  // Calculate based on target cell size
  int calcRows = (availableWidth / targetCellSize).floor();
  int calcCols = (availableHeight / targetCellSize).floor();

  // Adjust to maintain aspect ratio (height:width)
  if (calcCols / calcRows > targetAspectRatio) {
    // Too tall, adjust columns
    calcCols = (calcRows * targetAspectRatio).floor();
  } else if (calcCols / calcRows < targetAspectRatio) {
    // Too wide, adjust rows
    calcRows = (calcCols / targetAspectRatio).floor();
  }

  // Apply min/max constraints
  rows = calcRows.clamp(minRows, maxRows);
  cols = calcCols.clamp(minCols, maxCols);

  // Debug output
  debugPrint('Screen size: $screenSize');
  debugPrint('Calculated grid: $rows x $cols');
}

enum Direction { left, right, down }

enum Tetromino { L, J, I, O, S, Z, T }

const Map<Tetromino, Color> tetroinoColors = {
  Tetromino.L: Color(0xFF00FF00),
  Tetromino.J: Color(0xFF0000FF),
  Tetromino.I: Color(0xFFFF0000),
  Tetromino.O: Color(0xFFFFFF00),
  Tetromino.S: Color(0xFFFF00FF),
  Tetromino.Z: Color(0xFF00FFFF),
  Tetromino.T: Color(0xFFFFA500),
};

// Scoring constants
const int singleLinePoints = 100;
const int doubleLinePoints = 300;
const int tripleLinePoints = 500;
const int tetrisPoints = 800;
const int pointsPerLevel = 10; // Lines needed to level up
const int softDropPoints = 1; // Points per cell soft dropped
const int hardDropPoints = 2; // Points per cell hard dropped
const int comboBasePoints = 50;
