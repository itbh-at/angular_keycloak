import 'package:angular_router/angular_router.dart' show RoutePath;

import '../route_paths.dart' as parent;

class RoutePaths {
  static final kitchen =
      RoutePath(path: 'kitchen', parent: parent.RoutePaths.employee);
  static final cashier = RoutePath(path: 'cashier', parent: kitchen);
  static final bossRoom = RoutePath(path: 'boss-room', parent: cashier);
}
