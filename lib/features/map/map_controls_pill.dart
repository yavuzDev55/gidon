import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// The vertical pill of map controls: layer style toggle, optional
/// route-planning toggle, and a combined recenter+align-north action.
class MapControlsPill extends StatelessWidget {
  final VoidCallback onRecenterAndAlign;
  final VoidCallback? onToggleLayers;
  final VoidCallback? onTogglePlanning;
  final bool isPlanning;

  const MapControlsPill({
    super.key,
    required this.onRecenterAndAlign,
    this.onToggleLayers,
    this.onTogglePlanning,
    this.isPlanning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onTogglePlanning != null)
            _PillIcon(
              icon: Icons.route_outlined,
              onTap: onTogglePlanning,
              selected: isPlanning,
            ),
          if (onTogglePlanning != null) const SizedBox(height: 4),
          _PillIcon(icon: Icons.layers_outlined, onTap: onToggleLayers),
          const SizedBox(height: 4),
          _PillIcon(icon: Icons.navigation_outlined, onTap: onRecenterAndAlign),
        ],
      ),
    );
  }
}

class _PillIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool selected;

  const _PillIcon({
    required this.icon,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: selected ? AppColors.black : AppColors.yellow,
        size: 22,
      ),
      style: selected
          ? IconButton.styleFrom(backgroundColor: AppColors.yellow)
          : null,
    );
  }
}
