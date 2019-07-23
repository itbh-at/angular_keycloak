import 'package:angular_router/angular_router.dart' show RoutePath;

import '../route_paths.dart' as parent;

class RoutePaths {
  static final door = RoutePath(path: 'door', parent: parent.RoutePaths.public);
  static final window =
      RoutePath(path: 'window', parent: parent.RoutePaths.public);
}
