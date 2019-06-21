@TestOn("browser")
import 'package:test/test.dart';

import 'package:keycloak_dart/keycloak.dart';

void main() {
  group('Initialization.', () {
    test('Create keycloak instance by config file', () async {
      var service = KeycloakService('keycloak.json');
      await service.init();

      expect(service.realm, 'demo');
      expect(service.clientId, 'angulardart_alpha');
    });

    test('Create keycloak instance by parameters', () async {
      var service = KeycloakService.parameters({
        "realm": "demo",
        "auth-server-url": "http://localhost:8080/auth",
        "ssl-required": "external",
        "resource": "angulardart_alpha",
        "public-client": true,
        "confidential-port": 0
      });
      await service.init();

      expect(service.realm, 'demo');
      expect(service.clientId, 'angulardart_beta');
    });
  });
}
