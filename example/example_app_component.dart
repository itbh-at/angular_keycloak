import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';

import 'package:keycloak_dart/keycloak.dart';

import 'keycloak_service_provider.dart';

@Component(
  selector: 'my-app',
  directives: [MaterialButtonComponent, NgIf],
  providers: [keycloakServiceProvider],
  template: '''
    <h1>Keycloak example</h1>

    <div style="padding: 8px;" [innerHtml]="info">
    </div>

    <material-button raised *ngIf="!isAuthenticated" (trigger)="login">
      Login
    </material-button>
    <material-button raised *ngIf="isAuthenticated" (trigger)="logout">
      Logout
    </material-button>
  ''',
)
class ExampleAppComponent implements OnInit {
  final KeycloakService _keycloakService;

  bool get isAuthenticated => _keycloakService.isAuthenticated;

  String get info {
    if (isAuthenticated) {
      return 'Logged in';
    } else {
      return '''
      Server: ${_keycloakService.authServerUrl}
      <br>
      Realm: ${_keycloakService.realm}
      <br>
      Client ID: ${_keycloakService.clientId} 
      ''';
    }
  }

  ExampleAppComponent(this._keycloakService);

  @override
  void ngOnInit() async {
    await _keycloakService.init();
  }

  void login() {
    _keycloakService.login();
  }

  void logout() {
    _keycloakService.logout();
  }
}
