import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/keycloak_service.dart';

import 'routes.dart';

@Component(selector: 'customer', directives: [
  MaterialButtonComponent,
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <h1>Customer Area</h1>
  <p>Only customer can come here.</p>
  
  <p>welcome {{name}}</p>
  <material-button (trigger)="(logout)">Logout</material-button>  

  <div class="sub-nav">
  <a [routerLink]="RoutePaths.dinning.toUrl()">Dinning</a>
  <a [routerLink]="RoutePaths.vip.toUrl()">VIP Room</a>
  </div>
  <router-outlet [routes]="Routes.all"></router-outlet>
  ''')
class CustomerComponent implements OnInit {
  final KeycloakService _keycloakService;
  var name = "no one";

  CustomerComponent(this._keycloakService);

  void ngOnInit() async {
    name = await _keycloakService.getUserName();
  }

  void logout() async {
    _keycloakService.logout(id: 'customer');
  }
}
