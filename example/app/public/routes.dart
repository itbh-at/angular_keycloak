import 'package:angular_router/angular_router.dart' show RouteDefinition;

import 'door_component.template.dart' as door_template;
import 'window_component.template.dart' as window_template;

import 'route_paths.dart';
export 'route_paths.dart';

class Routes {
  static final door = RouteDefinition(
      routePath: RoutePaths.door,
      component: door_template.DoorComponentNgFactory);

  static final window = RouteDefinition(
      routePath: RoutePaths.window,
      component: window_template.WindowComponentNgFactory);

  static final all = [door, window];
}
