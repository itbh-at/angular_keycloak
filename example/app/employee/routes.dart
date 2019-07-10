// This file is part of AngularKeycloak
//
// AngularKeycloak is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published by the
// Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

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
