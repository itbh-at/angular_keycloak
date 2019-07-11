import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_keycloak/angular_keycloak.dart';
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
  final LocationStrategy _locationStrategy;

  var _originUri = RoutePaths.customer.toUrl();

  CustomerLoginComponent(this._keycloakService, this._locationStrategy);

  @override
  void onActivate(_, RouterState current) {
    final origin = current.queryParameters['origin'];
    if (origin != null) {
      _originUri = origin;
    }
  }

  void login() async {
    final keycloakInstanceId = 'customer';
    if (!_keycloakService.isInstanceInitiated(instanceId: keycloakInstanceId)) {
      await _keycloakService.initWithProvidedConfig(
          instanceId: keycloakInstanceId);
    }
    final url =
        '${window.location.origin}/${_locationStrategy.prepareExternalUrl(_originUri)}';
    _keycloakService.login(instanceId: keycloakInstanceId, redirectUri: url);
  }
}
