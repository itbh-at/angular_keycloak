import 'package:keycloak_dart/src/js_interop/keycloak.dart';
@TestOn("browser")
import 'package:test/test.dart';

import 'package:keycloak_dart/keycloak.dart';

void main() {
  group('Initialization.', () {
    // test('Create keycloak instance by config file', () {
    //   fail('Need to implemet');
    // }, skip: 'Need to implemet');

    test('Create keycloak instance by parameters', () async {
      var service = KeycloakService('keycloak.json');
      await service.init();
      await service.login();
    });

    // test('Create two keycloak instances, 1 by config, 1 by params', () {
    //   fail('Need to implemet');
    // }, skip: 'Need to implemet');
  });
}
