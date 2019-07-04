import 'package:angular_router/angular_router.dart' show RoutePath;

import '../route_paths.dart' as parent;

class RoutePaths {
  static final dinning =
      RoutePath(path: 'dinning', parent: parent.RoutePaths.customer);
  static final vip = RoutePath(path: 'vip', parent: parent.RoutePaths.customer);
}
