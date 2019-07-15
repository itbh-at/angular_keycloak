import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_keycloak/angular_keycloak.dart';
import 'package:keycloak/keycloak.dart';

@Component(
  selector: 'my-app',
  directives: [MaterialButtonComponent, NgIf],
  template: '''
  <h1>Keycloak Service Only Example</h1>
  
  <div *ngIf="isKeycloakInitiatized">
    <p>{{keycloakInfo}}</p>
    <material-button *ngIf="!isAuthenticated" (trigger)="login">Login</material-button>

    <div *ngIf="isAuthenticated">
      <material-button raised (trigger)="loadUser">Load User Information</material-button>
      <div *ngIf="hasProfile">UserName: {{username}}</div>
      
      <material-button (trigger)="logout">Logout</material-button>
    </div>
  </div>

''',
)
class ExampleAppComponent implements OnInit {
  final KeycloakService _keycloakService;

  KeycloakProfile _keycloakProfile;

  String get keycloakInfo =>
      'Keycloak server: ${_keycloakService.getInstance().authServerUrl}';
  bool get isKeycloakInitiatized => _keycloakService.isInstanceInitiated();
  bool get isAuthenticated => _keycloakService.isAuthenticated();
  bool get hasProfile => _keycloakProfile != null;
  String get username => _keycloakProfile.username;

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

  void loadUser() async {
    _keycloakProfile = await _keycloakService.getUserProfile();
  }
}
