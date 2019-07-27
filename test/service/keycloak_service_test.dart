@TestOn("browser")
import 'package:keycloak/keycloak.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:angular_keycloak/src/keycloak_instance_factory.dart';
import 'package:angular_keycloak/src/keycloak_service_impl.dart';

class MockKeycloakInstance extends Mock implements KeycloakInstance {}

class MockKeycloakInstanceFactory extends Mock
    implements KeycloakInstanceFactory {}

main() {
  test('initing keycloak service', () {
    final mockFactory = MockKeycloakInstanceFactory();
    final mockInstnace = MockKeycloakInstance();
    when(mockFactory.create()).thenReturn(mockInstnace);

    final _service = KeycloakServiceImpl(mockFactory, null);
    _service.init();

    verify(mockInstnace.init(any));
  });
}
