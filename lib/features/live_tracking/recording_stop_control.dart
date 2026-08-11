import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// The bottom stop control during an active ride. Tapping the center
/// square icon expands to reveal Cancel and Finish actions. Menu
/// navigation (Map/Profile/Games) lives separately in the always-on
/// radial nav menu, not here.
class RecordingStopControl extends StatefulWidget {
  final VoidCallback onFinish;
  final VoidCallback onCancel;

  const RecordingStopControl({
    super.key,
    required this.onFinish,
    required this.onCancel,
  });

  @override
  State<RecordingStopControl> createState() => _RecordingStopControlState();
}

class _RecordingStopControlState extends State<RecordingStopControl> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(36),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isExpanded) ...[
              _ControlIcon(icon: Icons.close, onTap: widget.onCancel),
              const SizedBox(width: 8),
              _ControlIcon(
                icon: Icons.flag,
                onTap: widget.onFinish,
                backgroundColor: AppColors.yellow,
                iconColor: AppColors.black,
              ),
              const SizedBox(width: 8),
            ],
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _isExpanded ? AppColors.yellow : AppColors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.yellow, width: 2),
                ),
                child: Icon(
                  Icons.stop_rounded,
                  color: _isExpanded ? AppColors.black : AppColors.yellow,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  const _ControlIcon({
    required this.icon,
    required this.onTap,
    this.backgroundColor = AppColors.secondaryBlack,
    this.iconColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
