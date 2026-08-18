import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'radial_nav_menu.dart';

/// A YouTube-style floating mini-player. While dragging, it's a
/// simple fixed-size circle (no edge-dependent shape), so it can
/// move freely across the whole screen with no invisible obstacles.
/// On release, it docks to the nearest edge and morphs into the full
/// expandable RadialNavMenu, precisely flush against that edge.
class DraggableRadialNavMenu extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  /// Full-width zone to avoid at the top (e.g. the stats panel,
  /// which spans nearly edge-to-edge — so the top edge itself
  /// becomes entirely unusable for docking).
  final double topForbiddenHeight;

  /// Half-width of a CENTERED obstacle at the bottom (e.g. the stop
  /// control) — unlike the top, this doesn't span the full width,
  /// so the bottom edge stays usable everywhere except that centered
  /// strip.
  final double bottomObstacleHalfWidth;

  const DraggableRadialNavMenu({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.topForbiddenHeight = 0,
    this.bottomObstacleHalfWidth = 0,
  });

  @override
  State<DraggableRadialNavMenu> createState() => _DraggableRadialNavMenuState();
}

class _DraggableRadialNavMenuState extends State<DraggableRadialNavMenu>
    with SingleTickerProviderStateMixin {
  static const double _edgeMargin = 4;
  static const double _circleSize = RadialNavMenu.centerButtonSize;

  MenuEdge _edge = MenuEdge.right;
  // Position along the docked edge (Y for left/right, X for
  // top/bottom), measured at the button's CENTER.
  double? _alongEdge;

  Offset? _dragCenter;
  Offset? _dragStartCenter;
  Offset? _dragStartGlobal;
  bool _isDragging = false;

  late final AnimationController _snapController;
  Animation<Offset>? _snapAnimation;
  MenuEdge? _pendingEdge;

  @override
  void initState() {
    super.initState();
    _snapController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 240),
          )
          ..addListener(() {
            if (_snapAnimation != null) {
              setState(() => _dragCenter = _snapAnimation!.value);
            }
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && _pendingEdge != null) {
              final finalCenter = _dragCenter!;
              setState(() {
                _edge = _pendingEdge!;
                _alongEdge = _perpendicularCoord(finalCenter, _edge);
                _dragCenter = null;
                _pendingEdge = null;
              });
            }
          });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  double _perpendicularCoord(Offset center, MenuEdge edge) {
    switch (edge) {
      case MenuEdge.left:
      case MenuEdge.right:
        return center.dy;
      case MenuEdge.top:
      case MenuEdge.bottom:
        return center.dx;
    }
  }

  /// The exact screen-space center of the circle when docked to
  /// [edge] at position [alongEdge] along that edge.
  Offset _dockedCenter(MenuEdge edge, double alongEdge, Size screenSize) {
    final half = _circleSize / 2;
    switch (edge) {
      case MenuEdge.left:
        return Offset(_edgeMargin + half, alongEdge);
      case MenuEdge.right:
        return Offset(screenSize.width - _edgeMargin - half, alongEdge);
      case MenuEdge.top:
        return Offset(alongEdge, _edgeMargin + half);
      case MenuEdge.bottom:
        return Offset(alongEdge, screenSize.height - _edgeMargin - half);
    }
  }

  void _startDrag(Offset globalPosition, Size screenSize) {
    _snapController.stop();
    final currentCenter = _dockedCenter(
      _edge,
      _alongEdge ?? screenSize.height / 2,
      screenSize,
    );
    _dragStartCenter = currentCenter;
    _dragStartGlobal = globalPosition;
    setState(() {
      _dragCenter = currentCenter;
      _isDragging = true;
    });
  }

  void _updateDrag(Offset globalPosition, Size screenSize) {
    if (_dragStartCenter == null || _dragStartGlobal == null) return;
    final delta = globalPosition - _dragStartGlobal!;
    final half = _circleSize / 2;

    // Only constraint: stay fully on-screen. No edge-shape-dependent
    // obstacles — the circle is the same size everywhere.
    final newCenter = Offset(
      (_dragStartCenter!.dx + delta.dx).clamp(half, screenSize.width - half),
      (_dragStartCenter!.dy + delta.dy).clamp(half, screenSize.height - half),
    );
    setState(() => _dragCenter = newCenter);
  }

  void _endDrag(Size screenSize) {
    setState(() => _isDragging = false);
    final released = _dragCenter;
    if (released == null) return;

    final half = _circleSize / 2;

    // Left/right docking only needs to duck below the top panel
    // (which spans full width) — the bottom control is centered and
    // narrow, so it never reaches the side edges. No bottom limit
    // needed here.
    final minY = widget.topForbiddenHeight + half;
    final maxY = screenSize.height - half;

    final distances = <MenuEdge, double>{
      MenuEdge.left: released.dx,
      MenuEdge.right: screenSize.width - released.dx,
      if (widget.topForbiddenHeight == 0) MenuEdge.top: released.dy,
      MenuEdge.bottom: screenSize.height - released.dy,
    };

    final targetEdge = distances.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;

    double alongEdge;
    switch (targetEdge) {
      case MenuEdge.left:
      case MenuEdge.right:
        alongEdge = released.dy.clamp(minY, maxY < minY ? minY : maxY);
      case MenuEdge.top:
        alongEdge = released.dx.clamp(half, screenSize.width - half);
      case MenuEdge.bottom:
        alongEdge = _resolveBottomX(released.dx, screenSize, half);
    }

    final target = _dockedCenter(targetEdge, alongEdge, screenSize);
    _pendingEdge = targetEdge;

    _snapAnimation = Tween<Offset>(begin: released, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapController.forward(from: 0);
  }

  /// Picks an X position along the bottom edge that avoids the
  /// centered obstacle (if any) by sliding to whichever side is
  /// closer to where the user released.
  double _resolveBottomX(double releasedX, Size screenSize, double half) {
    if (widget.bottomObstacleHalfWidth <= 0) {
      return releasedX.clamp(half, screenSize.width - half);
    }

    final centerX = screenSize.width / 2;
    final obstacleLeft = centerX - widget.bottomObstacleHalfWidth;
    final obstacleRight = centerX + widget.bottomObstacleHalfWidth;

    var x = releasedX.clamp(half, screenSize.width - half);
    final overlapsObstacle =
        x + half > obstacleLeft && x - half < obstacleRight;

    if (overlapsObstacle) {
      x = x < centerX ? obstacleLeft - half : obstacleRight + half;
      x = x.clamp(half, screenSize.width - half);
    }

    return x;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        _alongEdge ??= (screenSize.height - 200).clamp(
          widget.topForbiddenHeight,
          screenSize.height - widget.bottomObstacleHalfWidth,
        );

        final isTransient = _isDragging || _snapController.isAnimating;

        if (isTransient) {
          final center =
              _dragCenter ?? _dockedCenter(_edge, _alongEdge!, screenSize);
          return Stack(
            children: [
              Positioned(
                left: center.dx - _circleSize / 2,
                top: center.dy - _circleSize / 2,
                child: GestureDetector(
                  onLongPressStart: (d) =>
                      _startDrag(d.globalPosition, screenSize),
                  onLongPressMoveUpdate: (d) =>
                      _updateDrag(d.globalPosition, screenSize),
                  onLongPressEnd: (_) => _endDrag(screenSize),
                  child: _FreeCircle(
                    selectedIndex: widget.selectedIndex,
                    scaled: _isDragging,
                  ),
                ),
              ),
            ],
          );
        }

        // Docked, idle state: render the full expandable menu,
        // positioned so its internal circle lands exactly at our
        // tracked center point.
        final footprint = RadialNavMenu.footprintSizeForEdge(_edge);
        final internalOffset = RadialNavMenu.centerButtonOffset(
          _edge,
          footprint,
        );
        final dockedCenter = _dockedCenter(_edge, _alongEdge!, screenSize);
        final topLeft = dockedCenter - internalOffset;

        return Stack(
          children: [
            Positioned(
              left: topLeft.dx,
              top: topLeft.dy,
              child: GestureDetector(
                onLongPressStart: (d) =>
                    _startDrag(d.globalPosition, screenSize),
                onLongPressMoveUpdate: (d) =>
                    _updateDrag(d.globalPosition, screenSize),
                onLongPressEnd: (_) => _endDrag(screenSize),
                child: RadialNavMenu(
                  selectedIndex: widget.selectedIndex,
                  onSelect: widget.onSelect,
                  edge: _edge,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FreeCircle extends StatelessWidget {
  final int selectedIndex;
  final bool scaled;

  const _FreeCircle({required this.selectedIndex, required this.scaled});

  static const _icons = [
    Icons.map_outlined,
    Icons.person_outline,
    Icons.sports_esports_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scaled ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        width: RadialNavMenu.centerButtonSize,
        height: RadialNavMenu.centerButtonSize,
        decoration: const BoxDecoration(
          color: AppColors.yellow,
          shape: BoxShape.circle,
        ),
        child: Icon(_icons[selectedIndex], color: AppColors.black, size: 28),
      ),
    );
  }
}
