import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// The vertical pill of map controls: layer style toggle, and a
/// combined recenter+align-north action.
class MapControlsPill extends StatelessWidget {
  final VoidCallback onRecenterAndAlign;
  final VoidCallback? onToggleLayers;

  const MapControlsPill({
    super.key,
    required this.onRecenterAndAlign,
    this.onToggleLayers,
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

  const _PillIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.yellow, size: 22),
    );
  }
}
