import 'package:angular_router/angular_router.dart' show RouteDefinition;

import 'boss_room_component.template.dart' as boss_room_template;
import 'cashier_component.template.dart' as cashier_template;
import 'kitchen_component.template.dart' as kitchen_template;

import 'route_paths.dart';
export 'route_paths.dart';

class Routes {
  static final bossRoom = RouteDefinition(
      routePath: RoutePaths.bossRoom,
      component: boss_room_template.BossRoomComponentNgFactory);

  static final cashier = RouteDefinition(
      routePath: RoutePaths.cashier,
      component: cashier_template.CashierComponentNgFactory);

  static final kitchen = RouteDefinition(
      routePath: RoutePaths.kitchen,
      component: kitchen_template.KitchenComponentNgFactory);

  static final all = [bossRoom, cashier, kitchen];
}
