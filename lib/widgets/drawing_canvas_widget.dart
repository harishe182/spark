import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';

import '../core/theme.dart';
import 'glass/glass.dart';

/// Child-friendly wrapper around `flutter_drawing_board`. We deliberately do
/// NOT use the package's dense default toolbar; instead we expose a small,
/// large-button toolbar: a limited color palette, three brush sizes, an
/// eraser, and undo/redo. The caller owns the [DrawingController] so it can
/// export PNGs (snapshots / final drawing) via `getImageData()`.
class DrawingCanvasWidget extends StatefulWidget {
  const DrawingCanvasWidget({super.key, required this.controller});

  final DrawingController controller;

  @override
  State<DrawingCanvasWidget> createState() => _DrawingCanvasWidgetState();
}

class _DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  static const _palette = <Color>[
    SparkTheme.ink,
    SparkTheme.coral,
    SparkTheme.sparkAmber,
    SparkTheme.leafGreen,
    SparkTheme.skyBlue,
    Color(0xFF8E24AA), // purple
  ];

  static const _brushSizes = <double>[4, 10, 20];

  Color _color = SparkTheme.ink;
  double _strokeWidth = 10;
  bool _erasing = false;

  @override
  void initState() {
    super.initState();
    _applyStyle();
    widget.controller.setPaintContent(SmoothLine());
  }

  void _applyStyle() {
    widget.controller.setStyle(color: _color, strokeWidth: _strokeWidth);
  }

  void _selectColor(Color color) {
    setState(() {
      _color = color;
      _erasing = false;
    });
    widget.controller.setPaintContent(SmoothLine());
    _applyStyle();
  }

  void _selectBrush(double size) {
    setState(() => _strokeWidth = size);
    _applyStyle();
  }

  void _toggleEraser() {
    setState(() => _erasing = !_erasing);
    if (_erasing) {
      widget.controller.setPaintContent(Eraser());
      widget.controller.setStyle(strokeWidth: _strokeWidth * 2.5);
    } else {
      widget.controller.setPaintContent(SmoothLine());
      _applyStyle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GlassSurface(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  tintOpacity: 0.92,
                  blurSigma: 8,
                  child: DrawingBoard(
                    controller: widget.controller,
                    background: Container(
                      color: Colors.white.withValues(alpha: 0.85),
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),
                    boardPanEnabled: false,
                    boardScaleEnabled: false,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        _Toolbar(
          palette: _palette,
          brushSizes: _brushSizes,
          selectedColor: _color,
          selectedBrush: _strokeWidth,
          erasing: _erasing,
          onColor: _selectColor,
          onBrush: _selectBrush,
          onEraser: _toggleEraser,
          onUndo: widget.controller.undo,
          onRedo: widget.controller.redo,
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.palette,
    required this.brushSizes,
    required this.selectedColor,
    required this.selectedBrush,
    required this.erasing,
    required this.onColor,
    required this.onBrush,
    required this.onEraser,
    required this.onUndo,
    required this.onRedo,
  });

  final List<Color> palette;
  final List<double> brushSizes;
  final Color selectedColor;
  final double selectedBrush;
  final bool erasing;
  final ValueChanged<Color> onColor;
  final ValueChanged<double> onBrush;
  final VoidCallback onEraser;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final c in palette)
            _ColorDot(
              color: c,
              selected: !erasing && c == selectedColor,
              onTap: () => onColor(c),
            ),
          const _Divider(),
          for (final s in brushSizes)
            _BrushDot(
              size: s,
              selected: s == selectedBrush,
              onTap: () => onBrush(s),
            ),
          const _Divider(),
          _ToolButton(
            icon: Icons.cleaning_services,
            label: 'Erase',
            active: erasing,
            onTap: onEraser,
          ),
          _ToolButton(icon: Icons.undo, label: 'Undo', onTap: onUndo),
          _ToolButton(icon: Icons.redo, label: 'Redo', onTap: onRedo),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot(
      {required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? SparkTheme.ink : Colors.white,
            width: selected ? 4 : 2,
          ),
        ),
      ),
    );
  }
}

class _BrushDot extends StatelessWidget {
  const _BrushDot(
      {required this.size, required this.selected, required this.onTap});

  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? SparkTheme.cream.withValues(alpha: 0.5)
              : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? SparkTheme.sparkAmber : Colors.grey.shade300,
            width: selected ? 3 : 1,
          ),
        ),
        child: Center(
          child: Container(
            width: size + 6,
            height: size + 6,
            decoration: const BoxDecoration(
              color: SparkTheme.ink,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active
                ? SparkTheme.sparkAmber.withValues(alpha: 0.2)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 32, color: SparkTheme.ink),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: Colors.grey.shade300);
  }
}
