import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/angular_keycloak.dart';

import 'routes.dart';

@Component(selector: 'employee', directives: [
  MaterialButtonComponent,
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <div class="employee container">
    <h2>Employee Area</h2>
    <p>Good Evening, <strong>{{name}}</strong></p>
    <p>You are here to serve.</p>
    
    <div>What do you want to do next?</div>
    <ul>
      <li>
        <material-button raised 
                         (trigger)="(logout)">
          Logout
        </material-button>  
      </li>

      <li>
        <div class="sub-nav">
          Go to the
          <a [routerLink]="RoutePaths.kitchen.toUrl()">Kitchen</a>.
        </div>
      </li>
    </ul>
    <router-outlet [routes]="Routes.all"></router-outlet>
  </div>
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
