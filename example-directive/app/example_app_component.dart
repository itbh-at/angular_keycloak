import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:keycloak/keycloak.dart';

import 'package:angular_keycloak/angular_keycloak.dart';

@Component(
  selector: 'my-app',
  directives: [KcSecurity, MaterialButtonComponent, NgIf],
  template: '''
  <div class="main">
    <h1>Keycloak Directives</h1>
    
    <div *ngIf="isKeycloakInitiatized">
      <p><strong>Keycloak Server:</strong> {{keycloakServer}}</p>
      <p><strong>Keycloak Realm:</strong> {{keycloakRealm}}</p>

      <p *kcSecurity="instanceId">Welcome dear user</p>

      <material-button  *kcSecurity="instanceId; showWhenDenied: true"
                        raised
                        (trigger)="login">
        Login
      </material-button>

      <div *kcSecurity="instanceId">
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

        <div *kcSecurity="roles: ['boss']">
          <h2>boss only</h2>
        </div>
        <div *kcSecurity="showWhenDenied: true; roles: ['boss']">
          <h2>No one can see</h2>
        </div>

        <div *kcSecurity="readonlyRoles: ['supervisor']; roles: ['boss']; let ro = readonly">
          <h3>This Year Bonus</h3>
          Supervisor can see.
          Boss can change.
          <br>

          <input [readonly]="ro" type="text" value="1000" />
          <br>
          <material-button  raised
                            [disabled]="ro" 
                            (trigger)="updateBonus">
            Update Bonus
          </material-button>
        </div>
      </div>

    </div>
  </div>
''',
)
class ExampleAppComponent implements OnInit {
  final KeycloakService _keycloakService;

  KeycloakProfile _keycloakProfile;
  String instanceId;

  String get keycloakServer => _keycloakService.getInstance().authServerUrl;
  String get keycloakRealm => _keycloakService.getInstance().realm;
  String get username => _keycloakProfile.username;

  bool get isKeycloakInitiatized => _keycloakService.isInstanceInitiated();
  bool get isAuthenticated => _keycloakService.isAuthenticated();
  bool get hasProfile => _keycloakProfile != null;

  ExampleAppComponent(this._keycloakService);

  @override
  void ngOnInit() async {
    instanceId = await _keycloakService.init();
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

  void updateBonus() {
    window.alert('Bonus update!');
  }
}
