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
class EmployeeComponent implements OnInit {
  final KeycloakService _keycloakService;
  var name = "no one";

  EmployeeComponent(this._keycloakService);

  void ngOnInit() async {
    name = await _keycloakService.getUserName();
  }

  void logout() async {
    _keycloakService.logout(id: 'employee');
  }
}
