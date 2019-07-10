import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/keycloak_service.dart';

import 'routes.dart';

@Component(selector: 'customer', directives: [
  MaterialButtonComponent,
  NgIf,
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <h1>Customer Area</h1>
  <p>Only customer can come here.</p>
  
  <p>welcome {{name}}</p>
  <material-button (trigger)="(logout)">Logout</material-button>  
  
  <div *ngIf="stoppedByGuard">
    Mere member is not allow to enter the VIP area.
  </div>
  <div *ngIf="!stoppedByGuard">
    <material-button (trigger)="(goToVIP)">Go into VIP room</material-button>  
  </div>


  <div class="sub-nav">
  <a [routerLink]="RoutePaths.dinning.toUrl()">Dinning</a>
  </div>
  <router-outlet [routes]="Routes.all"></router-outlet>
  ''')
class CustomerComponent implements OnActivate {
  final KeycloakService _keycloakService;
  final Router _router;

  var stoppedByGuard = false;
  var name = "no one";

  CustomerComponent(this._keycloakService, this._router);

  void onActivate(RouterState previous, RouterState current) async {
    name = (await _keycloakService.getUserProfile()).username;
  }

  void goToVIP() async {
    final result = await _router.navigate(RoutePaths.vip.toUrl());
    if (result == NavigationResult.BLOCKED_BY_GUARD) {
      stoppedByGuard = true;
    }
  }

  void logout() async {
    _keycloakService.logout(instanceId: 'customer');
  }
}
