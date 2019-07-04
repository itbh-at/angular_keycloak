import 'package:angular_router/angular_router.dart' show RouteDefinition;

import 'dinning_component.template.dart' as dinning_template;
import 'vip_room_component.template.dart' as vip_room_template;

import 'route_paths.dart';
export 'route_paths.dart';

class Routes {
  static final dinning = RouteDefinition(
      routePath: RoutePaths.dinning,
      component: dinning_template.DinningComponentNgFactory);

  static final vipRoom = RouteDefinition(
      routePath: RoutePaths.vip,
      component: vip_room_template.VipRoomComponentNgFactory);

  static final all = [dinning, vipRoom];
}
