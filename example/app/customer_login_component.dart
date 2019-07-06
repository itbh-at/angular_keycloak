import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_keycloak/keycloak_service.dart';
import 'package:angular_router/angular_router.dart';

import 'route_paths.dart';

@Component(
    selector: 'customer-login',
    directives: [MaterialButtonComponent],
    template: '''
  <h2>Customer Login</h2>
  <p>Please click the button to log in as a customer</p>
  <material-button (trigger)="login"></material-button>
  ''')
class CustomerLoginComponent implements OnActivate {
  final KeycloakService _keycloakService;

  CustomerLoginComponent(this._keycloakService);

  @override
  void onActivate(RouterState previous, RouterState current) {}

  void login() {
    _keycloakService.login(
        id: 'customer', redirectUri: RoutePaths.customer.toUrl());
  }
}
