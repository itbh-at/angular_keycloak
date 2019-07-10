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

import 'dinning_component.template.dart' as dinning_template;
import 'vip_room_component.template.dart' as vip_room_template;
import 'washroom_component.template.dart' as washroom_template;

import 'route_paths.dart';
export 'route_paths.dart';

class Routes {
  static final dinning = RouteDefinition(
      routePath: RoutePaths.dinning,
      component: dinning_template.DinningComponentNgFactory);

  static final vipRoom = RouteDefinition(
      routePath: RoutePaths.vip,
      component: vip_room_template.VipRoomComponentNgFactory);

  static final washroom = RouteDefinition(
      routePath: RoutePaths.washroom,
      component: washroom_template.WashroomComponentNgFactory);

  static final all = [dinning, vipRoom, washroom];
}
