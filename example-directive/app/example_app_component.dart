import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';

import 'package:angular_keycloak/angular_keycloak.dart';

const storageKey = 'kcInstanceId';

@Component(
    selector: 'my-app',
    directives: [KcSecurity, MaterialButtonComponent, NgIf],
    templateUrl: 'example_app_component.html')
class ExampleAppComponent implements OnInit {
  final KeycloakService _keycloakService;

  String instanceId;
  bool initialized = false;

  String get customerInstanceId => 'customer';
  String get employeeInstanceId => 'employee';

  String get keycloakServer => _keycloakService.getInstance().authServerUrl;
  String get keycloakRealm => _keycloakService.getInstance().realm;

  bool get isKeycloakInitiatized => initialized;
  bool get isAuthenticated => _keycloakService.isAuthenticated();

  ExampleAppComponent(this._keycloakService);

  @override
  void ngOnInit() async {
    final lastLoginInstance = window.localStorage[storageKey];
    if (lastLoginInstance != null) {
      await _init(lastLoginInstance);
      instanceId = lastLoginInstance;
    }
    initialized = true;
  }

  Future _init(String instanceId) async {
    if (!_keycloakService.isInstanceInitiated(instanceId: instanceId)) {
      await _keycloakService.init(KeycloackServiceInstanceConfig(
          id: instanceId, configFilePath: '$instanceId.json'));
    }
  }

  List<String> bossRole = ['boss'];
  List<String> supervisorRole = ['supervisor'];
  List<String> memberRole = ['member'];
  List<String> vipRole = ['vip'];

  void loginCustomer() {
    _login(customerInstanceId);
  }

  void loginEmployee() {
    _login(employeeInstanceId);
  }

  void _login(String instanceId) async {
    window.localStorage[storageKey] = instanceId;

    await _init(instanceId);

    _keycloakService.login(instanceId: instanceId);
  }

  void logout() {
    _keycloakService.logout();
  }

  void updateBonus() {
    window.alert('Bonus update!');
  }
}
