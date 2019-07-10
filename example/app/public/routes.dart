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
