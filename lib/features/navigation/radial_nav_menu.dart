import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum MenuEdge { left, right, top, bottom }

/// A button pinned to the current edge, showing the current section's
/// icon. Tapping it expands into an arc of the OTHER navigation
/// options, fanning INWARD from whichever screen edge it's currently
/// pinned to (so options never open off-screen).
class RadialNavMenu extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final MenuEdge edge;

  const RadialNavMenu({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.edge = MenuEdge.right,
  });

  static const double radius = 76;
  static const double optionButtonSize = 56;
  static const double centerButtonSize = 64;

  /// Footprint size depends on which edge the menu is pinned to:
  /// left/right pinned menus are "tall and narrow" (fanning
  /// vertically), top/bottom pinned menus are "wide and short"
  /// (fanning horizontally).
  static Size footprintSizeForEdge(MenuEdge edge) {
    switch (edge) {
      case MenuEdge.left:
      case MenuEdge.right:
        return const Size(
          radius + optionButtonSize,
          radius * 2 + optionButtonSize,
        );
      case MenuEdge.top:
      case MenuEdge.bottom:
        return const Size(
          radius * 2 + optionButtonSize,
          radius + optionButtonSize,
        );
    }
  }

  /// Where the center button's own center sits within its footprint,
  /// for a given edge — exposed so the drag wrapper can compute the
  /// exact top-left to position this widget at, given a desired
  /// on-screen center point for the circle.
  static Offset centerButtonOffset(MenuEdge edge, Size footprint) {
    switch (edge) {
      case MenuEdge.left:
        return Offset(centerButtonSize / 2, footprint.height / 2);
      case MenuEdge.right:
        return Offset(
          footprint.width - centerButtonSize / 2,
          footprint.height / 2,
        );
      case MenuEdge.top:
        return Offset(footprint.width / 2, centerButtonSize / 2);
      case MenuEdge.bottom:
        return Offset(
          footprint.width / 2,
          footprint.height - centerButtonSize / 2,
        );
    }
  }

  @override
  State<RadialNavMenu> createState() => _RadialNavMenuState();
}

class _RadialNavMenuState extends State<RadialNavMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isOpen = false;

  static const _items = [
    (icon: Icons.map_outlined, label: 'Map'),
    (icon: Icons.person_outline, label: 'Profile'),
    (icon: Icons.sports_esports_outlined, label: 'Games'),
  ];

  static const double _arcHalfSpreadDeg = 70;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleSelect(int index) {
    widget.onSelect(index);
    setState(() => _isOpen = false);
    _controller.reverse();
  }

  double get _centerAngleDeg {
    switch (widget.edge) {
      case MenuEdge.left:
        return 0;
      case MenuEdge.right:
        return 180;
      case MenuEdge.top:
        return 270;
      case MenuEdge.bottom:
        return 90;
    }
  }

  Offset _centerButtonCenter(Size footprint) =>
      RadialNavMenu.centerButtonOffset(widget.edge, footprint);

  List<double> _computeAngles(int count) {
    final centerDeg = _centerAngleDeg;
    if (count <= 1) return [centerDeg * pi / 180];
    return List.generate(count, (i) {
      final deg =
          centerDeg -
          _arcHalfSpreadDeg +
          (2 * _arcHalfSpreadDeg) * i / (count - 1);
      return deg * pi / 180;
    });
  }

  @override
  Widget build(BuildContext context) {
    final footprint = RadialNavMenu.footprintSizeForEdge(widget.edge);
    final visibleEntries = List.generate(
      _items.length,
      (i) => i,
    ).where((i) => i != widget.selectedIndex).toList();

    final angles = _computeAngles(visibleEntries.length);
    final center = _centerButtonCenter(footprint);

    return SizedBox(
      width: footprint.width,
      height: footprint.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...List.generate(visibleEntries.length, (i) {
            final itemIndex = visibleEntries[i];
            final item = _items[itemIndex];
            final angle = angles[i];

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final progress = Curves.easeOutBack.transform(
                  _controller.value,
                );
                final dx = cos(angle) * RadialNavMenu.radius * progress;
                final dy = -sin(angle) * RadialNavMenu.radius * progress;
                final iconCenter = center + Offset(dx, dy);

                return Positioned(
                  left: iconCenter.dx - RadialNavMenu.optionButtonSize / 2,
                  top: iconCenter.dy - RadialNavMenu.optionButtonSize / 2,
                  child: Opacity(
                    opacity: _controller.value.clamp(0, 1),
                    child: child,
                  ),
                );
              },
              child: _RadialIconButton(
                icon: item.icon,
                size: RadialNavMenu.optionButtonSize,
                onTap: () => _handleSelect(itemIndex),
              ),
            );
          }),
          Positioned(
            left: center.dx - RadialNavMenu.centerButtonSize / 2,
            top: center.dy - RadialNavMenu.centerButtonSize / 2,
            child: GestureDetector(
              onTap: _toggle,
              child: Container(
                width: RadialNavMenu.centerButtonSize,
                height: RadialNavMenu.centerButtonSize,
                decoration: const BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _items[widget.selectedIndex].icon,
                  color: AppColors.black,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadialIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _RadialIconButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.white, size: 24),
      ),
    );
  }
}
