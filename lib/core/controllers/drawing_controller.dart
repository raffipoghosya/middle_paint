import 'package:flutter/material.dart';
import 'package:middle_paint/base/colors/app_colors.dart';

/// Data structure to hold a single point and its associated [Paint] properties.
class DrawingPoint {
  final Offset point;
  final Paint paint;

  DrawingPoint(this.point, this.paint);
}

/// A [ChangeNotifier] that manages the state and logic for the canvas drawing.
/// It tracks paths, handles drawing/erasing modes, manages stroke width and color,
/// and implements undo/redo functionality for path history.
class DrawingController extends ChangeNotifier {
  final List<List<DrawingPoint>> _paths = [];
  final List<List<DrawingPoint>> _undonePaths = [];

  int _focusedPathIndex = -1;

  Color _currentColor = Colors.black;
  double _pencilStrokeWidth = 5.0;
  double _eraserStrokeWidth = 20.0;

  Color _defaultPencilColor = Colors.black;
  bool _isErasing = false;

  List<List<DrawingPoint>> get paths => _paths;
  Color get currentColor => _currentColor;

  double get currentStrokeWidth =>
      _isErasing ? _eraserStrokeWidth : _pencilStrokeWidth;

  bool get canUndo => _paths.isNotEmpty;
  bool get canRedo => _undonePaths.isNotEmpty;

  bool get isErasing => _isErasing;

  bool get canMoveUp =>
      _focusedPathIndex != -1 && _focusedPathIndex < _paths.length - 1;
  bool get canMoveDown => _focusedPathIndex > 0;

  void setCurrentStrokeWidth(double width) {
    if (_isErasing) {
      _eraserStrokeWidth = width;
    } else {
      _pencilStrokeWidth = width;
    }
    notifyListeners();
  }

  void setCurrentColor(Color color) {
    if (color != AppColors.white) {
      _defaultPencilColor = color;
    }
    _currentColor = color;
    _isErasing = false;
    notifyListeners();
  }

  /// Sets the controller to Erase mode, using [BlendMode.clear].
  void setEraseMode() {
    _isErasing = true;
    notifyListeners();
  }

  /// Sets the controller back to Draw mode, restoring the default pencil color.
  void setDrawMode() {
    _currentColor = _defaultPencilColor;
    _isErasing = false;
    notifyListeners();
  }

  /// Moves the currently focused path up in the list (drawing on top of others).
  void movePathUp() {
    if (canMoveUp) {
      final path = _paths.removeAt(_focusedPathIndex);
      _focusedPathIndex++;
      _paths.insert(_focusedPathIndex, path);
      notifyListeners();
    }
  }

  /// Moves the currently focused path down in the list (drawing under others).
  void movePathDown() {
    if (canMoveDown) {
      final path = _paths.removeAt(_focusedPathIndex);
      _focusedPathIndex--;
      _paths.insert(_focusedPathIndex, path);
      notifyListeners();
    }
  }

  /// Starts a new drawing path at the given point, clearing the redo history.
  void startNewPath(Offset point) {
    _undonePaths.clear();
    final newPath = <DrawingPoint>[];

    final currentPaint =
        Paint()
          ..color = _isErasing ? AppColors.primaryBlack : _currentColor
          ..strokeWidth = currentStrokeWidth
          ..isAntiAlias = true
          ..strokeCap = StrokeCap.round;

    if (_isErasing) {
      currentPaint.blendMode = BlendMode.clear;
    } else {
      currentPaint.blendMode = BlendMode.srcOver;
    }

    newPath.add(DrawingPoint(point, currentPaint));
    _paths.add(newPath);
    _focusedPathIndex = _paths.length - 1;
    notifyListeners();
  }

  /// Adds a new point to the currently active path.
  void addPointToCurrentPath(Offset point) {
    if (_paths.isEmpty) return;
    final currentPath = _paths.last;
    final currentPaint = currentPath.last.paint;

    currentPath.add(DrawingPoint(point, currentPaint));
    notifyListeners();
  }

  void endPath() {}

  /// Removes the last path from the history and saves it for a potential redo.
  void undo() {
    if (_paths.isNotEmpty) {
      final lastPath = _paths.removeLast();
      _undonePaths.add(lastPath);
      if (_paths.isEmpty) {
        _focusedPathIndex = -1;
      } else {
        _focusedPathIndex = _paths.length - 1;
      }
      notifyListeners();
    }
  }

  /// Restores the last undone path back onto the canvas.
  void redo() {
    if (_undonePaths.isNotEmpty) {
      final lastUndonePath = _undonePaths.removeLast();
      _paths.add(lastUndonePath);
      _focusedPathIndex = _paths.length - 1;
      notifyListeners();
    }
  }

  void clear() {
    _paths.clear();
    _undonePaths.clear();
    _focusedPathIndex = -1;
    notifyListeners();
  }
}
