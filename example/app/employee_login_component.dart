import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_keycloak/angular_keycloak.dart';
import 'package:angular_router/angular_router.dart';

import 'route_paths.dart';

@Component(
    selector: 'employee-login',
    directives: [MaterialButtonComponent, NgIf],
    template: '''
    <div class="employee container">
      <h2>Employee Login</h2>
      <div class="denied-access">
        Access Denied for "{{fullOriginUrl}}".<br>
        Please log in.
      </div>
      <material-button raised (trigger)="login">Login</material-button>
    </div>
    ''')
class EmployeeLoginComponent implements OnActivate {
  final KeycloakService _keycloakService;
  final LocationStrategy _locationStrategy;

  var _originUri = RoutePaths.employee.toUrl();

  String get fullOriginUrl =>
      '${window.location.origin}/${_locationStrategy.prepareExternalUrl(_originUri)}';

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

    // A safety check to ensure the instance is initiated in the Service.
    // The current example allows user to type in the URL of this component directly,
    // which might circumvent SecuredRouterHook's initiatlization.
    if (!_keycloakService.isInstanceInitiated(instanceId: keycloakInstanceId)) {
      await _keycloakService.initWithProvidedConfig(
          instanceId: keycloakInstanceId);
    }

    _keycloakService.login(
        instanceId: keycloakInstanceId, redirectUri: fullOriginUrl);
  }
}
