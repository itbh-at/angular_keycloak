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

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/keycloak_service.dart';

import 'routes.dart';

@Component(selector: 'employee', directives: [
  MaterialButtonComponent,
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <h1>Employee Area</h1>
  <p>Only employee can come here.</p>

  <p>welcome {{name}}</p>
  <material-button (trigger)="(logout)">Logout</material-button>

  <div class="sub-nav">
  <a [routerLink]="RoutePaths.kitchen.toUrl()">Kitchen</a>
  </div>
  <router-outlet [routes]="Routes.all">
  </router-outlet>
  ''')
class EmployeeComponent implements OnActivate {
  final KeycloakService _keycloakService;
  var name = "no one";

  EmployeeComponent(this._keycloakService);

  void onActivate(RouterState previous, RouterState current) async {
    name = (await _keycloakService.getUserProfile()).username;
  }

  void logout() async {
    _keycloakService.logout(instanceId: 'employee');
  }
}
