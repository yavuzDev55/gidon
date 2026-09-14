import 'package:flutter/material.dart';

import '../../services/location/isar_service.dart';
import '../../services/routing/planned_route.dart';
import '../../services/routing/route_plan_controller.dart';
import '../../services/routing/route_waypoint.dart';
import '../../theme/app_colors.dart';

class RoutePlannerPanel extends StatelessWidget {
  final RoutePlanController plan;
  final IsarService isarService;
  final bool compact;

  const RoutePlannerPanel({
    super.key,
    required this.plan,
    required this.isarService,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!plan.isPlanning && !plan.hasWaypoints) {
      return const SizedBox.shrink();
    }

    final distanceKm = (plan.distanceMeters / 1000).toStringAsFixed(1);
    final nextIndex = plan.nextWaypointIndex;
    final nextLabel = plan.allStopsReached
        ? 'Route complete'
        : nextIndex >= 0
        ? 'Next stop ${nextIndex + 1}'
        : 'Add stops';

    return Material(
      color: AppColors.black,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.route, color: AppColors.yellow, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan.hasWaypoints
                        ? '$nextLabel · $distanceKm km'
                        : 'Tap the map to add a stop',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (plan.isRouting)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.yellow,
                    ),
                  ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _openEditor(context),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.yellow,
                    size: 20,
                  ),
                ),
              ],
            ),
            if (plan.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  plan.errorMessage!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                  ),
                ),
              ),
            if (!compact && plan.waypoints.isNotEmpty)
              SizedBox(
                height: 72,
                child: ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false,
                  itemCount: plan.waypoints.length,
                  onReorder: plan.reorder,
                  itemBuilder: (context, index) {
                    return _StopChip(
                      key: ValueKey(plan.waypoints[index].id),
                      index: index,
                      waypoint: plan.waypoints[index],
                      isNext: index == nextIndex,
                      onRemove: () => plan.removeAt(index),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AnimatedBuilder(
          animation: plan,
          builder: (context, _) {
            return RoutePlannerEditorSheet(
              plan: plan,
              isarService: isarService,
            );
          },
        );
      },
    );
  }
}

class _StopChip extends StatelessWidget {
  final int index;
  final RouteWaypoint waypoint;
  final bool isNext;
  final VoidCallback onRemove;

  const _StopChip({
    super.key,
    required this.index,
    required this.waypoint,
    required this.isNext,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableDelayedDragStartListener(
      index: index,
      child: Container(
        width: 88,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
        decoration: BoxDecoration(
          color: isNext ? AppColors.yellow : AppColors.secondaryBlack,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                waypoint.completed ? 'Done ${index + 1}' : '${index + 1}',
                style: TextStyle(
                  color: isNext ? AppColors.black : AppColors.white,
                  fontWeight: FontWeight.bold,
                  decoration: waypoint.completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 16,
                color: isNext ? AppColors.black : AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoutePlannerEditorSheet extends StatelessWidget {
  final RoutePlanController plan;
  final IsarService isarService;

  const RoutePlannerEditorSheet({
    super.key,
    required this.plan,
    required this.isarService,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.62;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Stops',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (plan.nextWaypointIndex >= 0)
                  TextButton(
                    onPressed: plan.skipNext,
                    child: const Text('Skip next'),
                  ),
                TextButton(
                  onPressed: () => _openSavedRoutes(context),
                  child: const Text('Saved'),
                ),
              ],
            ),
            const Text(
              'Hold and drag to change order. Delete a stop with the X.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: plan.waypoints.isEmpty
                  ? const Center(
                      child: Text(
                        'Tap the map to add stops.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ReorderableListView.builder(
                      itemCount: plan.waypoints.length,
                      onReorder: plan.reorder,
                      itemBuilder: (context, index) {
                        final waypoint = plan.waypoints[index];
                        final isNext = index == plan.nextWaypointIndex;
                        return ListTile(
                          key: ValueKey(waypoint.id),
                          leading: CircleAvatar(
                            backgroundColor: waypoint.completed
                                ? Colors.white24
                                : isNext
                                ? AppColors.yellow
                                : AppColors.secondaryBlack,
                            foregroundColor: isNext
                                ? AppColors.black
                                : AppColors.white,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            waypoint.label.isEmpty
                                ? 'Stop ${index + 1}'
                                : waypoint.label,
                            style: TextStyle(
                              color: AppColors.white,
                              decoration: waypoint.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            waypoint.completed
                                ? 'Reached'
                                : isNext
                                ? 'Next stop'
                                : 'Upcoming',
                            style: const TextStyle(color: Colors.white54),
                          ),
                          trailing: IconButton(
                            onPressed: () => plan.removeAt(index),
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.white,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: plan.hasWaypoints ? plan.clear : null,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: plan.hasWaypoints
                        ? () => _saveRoute(context)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: AppColors.black,
                    ),
                    child: const Text('Save route'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveRoute(BuildContext context) async {
    final nameController = TextEditingController(
      text: plan.loadedRouteName.isEmpty ? '' : plan.loadedRouteName,
    );
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save route'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Route name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(nameController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (name == null) return;
    final resolvedName = name.isEmpty ? 'Planned route' : name;
    final id = await isarService.savePlannedRoute(
      routeId: plan.loadedRouteId,
      name: resolvedName,
      waypoints: plan.waypoints,
      polyline: plan.polyline,
      distanceMeters: plan.distanceMeters,
    );
    plan.markSaved(routeId: id, name: resolvedName);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved "$resolvedName"')));
    }
  }

  Future<void> _openSavedRoutes(BuildContext context) async {
    final routes = await isarService.getAllPlannedRoutes();
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.secondaryBlack,
      builder: (context) {
        return SavedRoutesSheet(
          routes: routes,
          onLoad: (route) {
            plan.loadSaved(
              routeId: route.routeId,
              name: route.name,
              savedWaypoints: route.waypoints
                  .map(
                    (waypoint) => RouteWaypoint(
                      id: waypoint.waypointId,
                      latitude: waypoint.latitude,
                      longitude: waypoint.longitude,
                      label: waypoint.label,
                    ),
                  )
                  .toList(),
            );
            Navigator.of(context).pop();
          },
          onDelete: (route) async {
            await isarService.deletePlannedRoute(route.routeId);
            if (plan.loadedRouteId == route.routeId) {
              plan.clear();
            }
            if (context.mounted) Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class SavedRoutesSheet extends StatelessWidget {
  final List<PlannedRoute> routes;
  final void Function(PlannedRoute route) onLoad;
  final void Function(PlannedRoute route) onDelete;

  const SavedRoutesSheet({
    super.key,
    required this.routes,
    required this.onLoad,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Saved routes',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (routes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No saved routes yet.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    final km = (route.distanceMeters / 1000).toStringAsFixed(1);
                    return ListTile(
                      title: Text(
                        route.name,
                        style: const TextStyle(color: AppColors.white),
                      ),
                      subtitle: Text(
                        '${route.waypoints.length} stops · $km km',
                        style: const TextStyle(color: Colors.white54),
                      ),
                      onTap: () => onLoad(route),
                      trailing: IconButton(
                        onPressed: () => onDelete(route),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.danger,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
