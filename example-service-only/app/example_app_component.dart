import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_keycloak/angular_keycloak.dart';
import 'package:keycloak/keycloak.dart';

@Component(
  selector: 'my-app',
  directives: [MaterialButtonComponent, NgIf],
  template: '''
  <div class="main">
    <h1>Single Instance Keycloak Service Only</h1>
    
    <div *ngIf="isKeycloakInitiatized">
      <p><strong>Keycloak Server:</strong> {{keycloakServer}}</p>
      <p><strong>Keycloak Realm:</strong> {{keycloakRealm}}</p>

      <material-button  *ngIf="!isAuthenticated" 
                        raised
                        (trigger)="login">
        Login
      </material-button>

      <div *ngIf="isAuthenticated">
        <material-button  *ngIf="!hasProfile" 
                          raised 
                          (trigger)="loadUser">
          Load User Information
        </material-button>

        <div *ngIf="hasProfile">
          <strong>UserName:</strong> {{username}}
        </div>
        
        <br>
        <material-button  raised 
                          (trigger)="logout">
          Logout
        </material-button>
      </div>
    </div>
  </div>
''',
)
class ExampleAppComponent implements OnInit {
  final KeycloakService _keycloakService;

  KeycloakProfile _keycloakProfile;

  String get keycloakServer => _keycloakService.getInstance().authServerUrl;
  String get keycloakRealm => _keycloakService.getInstance().realm;
  String get username => _keycloakProfile.username;

  bool get isKeycloakInitiatized => _keycloakService.isInstanceInitiated();
  bool get isAuthenticated => _keycloakService.isAuthenticated();
  bool get hasProfile => _keycloakProfile != null;

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
