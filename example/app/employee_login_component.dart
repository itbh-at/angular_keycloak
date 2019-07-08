import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_keycloak/keycloak_service.dart';
import 'package:angular_router/angular_router.dart';

import 'route_paths.dart';

@Component(
    selector: 'employee-login',
    directives: [MaterialButtonComponent],
    template: '''
  <h2>Employee Login</h2>
  <p>Please click the button to log in as a employee</p>
  <material-button (trigger)="login"></material-button>
  ''')
class EmployeeLoginComponent implements OnActivate {
  final KeycloakService _keycloakService;
  final LocationStrategy _locationStrategy;

  EmployeeLoginComponent(this._keycloakService, this._locationStrategy);

  @override
  void onActivate(RouterState previous, RouterState current) {}

  void login() async {
    final keycloakInstanceId = 'employee';
    if (!_keycloakService.isInstanceInitiated(instanceId: keycloakInstanceId)) {
      await _keycloakService.initInstance(instanceId: keycloakInstanceId);
    }
    final url =
        '${window.location.origin}/${_locationStrategy.prepareExternalUrl(RoutePaths.employee.toUrl())}';
    _keycloakService.login(id: keycloakInstanceId, redirectUri: url);
  }
}
