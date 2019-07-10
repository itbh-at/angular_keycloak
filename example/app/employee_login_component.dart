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

  var _originUri = RoutePaths.employee.toUrl();

  EmployeeLoginComponent(this._keycloakService, this._locationStrategy);

  @override
  void onActivate(_, RouterState current) {
    final origin = current.queryParameters['origin'];
    if (origin != null) {
      _originUri = origin;
    }
  }

  void login() async {
    final keycloakInstanceId = 'employee';
    if (!_keycloakService.isInstanceInitiated(instanceId: keycloakInstanceId)) {
      await _keycloakService.initWithId(instanceId: keycloakInstanceId);
    }
    final url =
        '${window.location.origin}/${_locationStrategy.prepareExternalUrl(_originUri)}';
    _keycloakService.login(instanceId: keycloakInstanceId, redirectUri: url);
  }
}
