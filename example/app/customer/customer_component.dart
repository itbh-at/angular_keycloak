import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/angular_keycloak.dart';

import 'routes.dart';

@Component(selector: 'customer', directives: [
  MaterialButtonComponent,
  NgIf,
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
    <div class="customer container">
      <h2>Customer Area</h2>
      <p>welcome! <strong>{{name}}</strong></p>
      <p>This is a member only area. Please suit yourself.</p>
      
      <div>What do you want to do next?</div>
      <ul>
        <li>
          <material-button raised 
                           (trigger)="(logout)">
            Logout
          </material-button>  
        </li>

        <li>
          <div *ngIf="stoppedByGuard"
              class="denied-access">
            Mere member is not allow to enter the VIP area.
          </div>
          <div *ngIf="!stoppedByGuard">
            <material-button raised 
                            (trigger)="(goToVIP)">
              Go into VIP room
            </material-button>  
          </div>
        </li>

        <li>
          <div class="sub-nav">
            Visit the
            <a [routerLink]="RoutePaths.dinning.toUrl()">Dinning</a>
            area.
          </div>
        </li>
      </ul>
      <router-outlet [routes]="Routes.fromCustomer"></router-outlet>
    </div>
  ''')
class CustomerComponent implements OnActivate {
  final KeycloakService _keycloakService;
  final Router _router;

  var stoppedByGuard = false;
  var name = "no one";

  CustomerComponent(this._keycloakService, this._router);

  void onActivate(RouterState previous, RouterState current) async {
    name = (await _keycloakService.getUserProfile(instanceId: 'customer'))
        .username;
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
