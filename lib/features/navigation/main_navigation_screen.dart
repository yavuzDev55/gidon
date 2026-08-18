import 'package:flutter/material.dart';
import '../games/games_screen.dart';
import '../live_tracking/live_tracking_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/location/isar_service.dart';
import 'draggable_radial_nav_menu.dart';

/// Root screen hosting the app's three main sections — Map/Ride,
/// Profile, Games — behind a draggable radial navigation menu. Only
/// the Ride tab is kept alive across navigation.
class MainNavigationScreen extends StatefulWidget {
  final IsarService isarService;

  const MainNavigationScreen({super.key, required this.isarService});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static const int _tabMap = 0;
  static const int _tabProfile = 1;
  static const int _tabGames = 2;

  int _selectedIndex = _tabMap;
  late final Widget _rideScreen;

  @override
  void initState() {
    super.initState();
    _rideScreen = LiveTrackingScreen(isarService: widget.isarService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Offstage(offstage: _selectedIndex != _tabMap, child: _rideScreen),
          if (_selectedIndex == _tabProfile)
            ProfileScreen(isarService: widget.isarService),
          if (_selectedIndex == _tabGames)
            GamesScreen(isarService: widget.isarService),
          DraggableRadialNavMenu(
            selectedIndex: _selectedIndex,
            onSelect: (index) => setState(() => _selectedIndex = index),
          ),
        ],
      ),
    );
  }
}
