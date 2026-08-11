import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A central floating button showing the current section's icon.
/// Tapping it expands into an arc of the OTHER navigation options
/// (Map, Profile, Games — minus whichever one is currently active).
/// Tapping an option (or the center button again) collapses it back.
class RadialNavMenu extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const RadialNavMenu({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

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

  static const double _centerButtonSize = 64;
  static const double _optionButtonSize = 56;
  static const double _radius = 76;
  // Narrower arc than before — options sit closer together, just
  // above the center button.
  static const double _arcStartDeg = 215;
  static const double _arcEndDeg = 325;

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

  @override
  Widget build(BuildContext context) {
    // Everything except the currently selected tab is offered as an
    // option when the menu opens.
    final visibleEntries = List.generate(
      _items.length,
      (i) => i,
    ).where((i) => i != widget.selectedIndex).toList();

    final angles = _computeAngles(visibleEntries.length);

    return SizedBox(
      width: _radius * 2 + _optionButtonSize,
      height: _radius + _optionButtonSize,
      child: Stack(
        alignment: Alignment.bottomCenter,
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
                final dx = cos(angle) * _radius * progress;
                final dy = sin(angle) * _radius * progress;

                return Positioned(
                  bottom: (_centerButtonSize / 2) - dy,
                  left:
                      (_radius + _optionButtonSize / 2) +
                      dx -
                      _optionButtonSize / 2,
                  child: Opacity(
                    opacity: _controller.value.clamp(0, 1),
                    child: child,
                  ),
                );
              },
              child: _RadialIconButton(
                icon: item.icon,
                size: _optionButtonSize,
                onTap: () => _handleSelect(itemIndex),
              ),
            );
          }),
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: _centerButtonSize,
              height: _centerButtonSize,
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
        ],
      ),
    );
  }

  List<double> _computeAngles(int count) {
    if (count <= 1) {
      final mid = (_arcStartDeg + _arcEndDeg) / 2;
      return [mid * pi / 180];
    }
    return List.generate(count, (i) {
      final deg = _arcStartDeg + (_arcEndDeg - _arcStartDeg) * i / (count - 1);
      return deg * pi / 180;
    });
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
