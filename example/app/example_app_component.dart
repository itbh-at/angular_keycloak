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
import 'package:angular_router/angular_router.dart' show routerDirectives;
import 'package:angular_components/laminate/popup/module.dart';

import 'package:angular_keycloak/keycloak_service.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(
  selector: 'my-app',
  directives: [
    routerDirectives,
  ],
  exports: [Routes, RoutePaths],
  //Blanket provider for all kind of Angular Component. VERY BAD. But too lazy to find the right one for each component.
  providers: [popupBindings],
  template: '''
  <h1>Keycloak Service Example</h1>
  <a [routerLink]="RoutePaths.customer.toUrl()">Customer</a>
  <a [routerLink]="RoutePaths.employee.toUrl()">Employee</a>
  <a [routerLink]="RoutePaths.public.toUrl()">Public</a>

  <router-outlet [routes]="Routes.all"></router-outlet>
''',
)
class ExampleAppComponent {
  final KeycloakService _keycloakService;

  ExampleAppComponent(this._keycloakService);

  void logoutCustomer() async {
    _keycloakService.logout(instanceId: 'customer');
  }
}
