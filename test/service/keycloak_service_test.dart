import 'package:angular_keycloak/angular_keycloak.dart';
import 'package:angular_keycloak/src/keycloak_service.dart';
@TestOn("browser")
import 'package:keycloak/keycloak.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:angular_keycloak/src/keycloak_instance_factory.dart';
import 'package:angular_keycloak/src/keycloak_service_impl.dart';

main() {
  MockKeycloakInstanceFactory _mockFactory;
  KeycloakService _service;

  setUp(() {
    _mockFactory = MockKeycloakInstanceFactory();
  });

  group('Single instance', () {
    MockKeycloakInstance _mockInstance;

    setUp(() {
      _mockInstance = MockKeycloakInstance();
      _service = KeycloakServiceImpl(_mockFactory, null);
    });

    test('init with default option', () {
      when(_mockFactory.create()).thenReturn(_mockInstance);

      _service.init();

      final captured = verify(_mockInstance.init(captureAny)).captured[0]
          as KeycloakInitOptions;
      expect(captured.onLoad, isNull);
      expect(captured.flow, isNull);
    });

    test('init with configuration', () async {
      final instanceId = 'testing-instance-id';
      final configFilePath = 'testing.json';

      when(_mockFactory.create(configFilePath)).thenReturn(_mockInstance);

      final id = await _service.init(KeycloackServiceInstanceConfig(
          id: instanceId,
          configFilePath: configFilePath,
          loadType: InitLoadType.checkSSO,
          flowType: InitFlowType.hybrid));

      expect(id, instanceId);

      final captured = verify(_mockInstance.init(captureAny)).captured[0]
          as KeycloakInitOptions;
      expect(captured.onLoad, 'check-sso');
      expect(captured.flow, 'hybrid');
    });

    test('Unintialized before init is called', () {
      expect(_service.isInstanceInitiated(), isFalse);
    });

    test('throw exception when accessing API before init', () {
      expect(_service.isAuthenticated,
          throwsA(TypeMatcher<UninitializedException>()));
    });

    group('accessing without instance Id', () {
      setUp(() async {
        when(_mockFactory.create()).thenReturn(_mockInstance);
        await _service.init();
      });

      test('authenticated', () {
        when(_mockInstance.authenticated).thenReturn(true);

        expect(_service.isInstanceInitiated(), isTrue);
        expect(_service.isAuthenticated(), isTrue);
        verify(_mockInstance.authenticated);
      });

      test('roles', () {
        final realmRoles = ['realm1'];
        final clientRoles = ['client1'];

        final mockKeycloakResourceAccess = MockKeycloakResourceAccess();
        when(_mockInstance.resourceAccess)
            .thenReturn(mockKeycloakResourceAccess);
        when(mockKeycloakResourceAccess[any])
            .thenReturn(KeycloakRoles(roles: clientRoles));
        when(_mockInstance.realmAccess)
            .thenReturn(KeycloakRoles(roles: realmRoles));

        expect(_service.getRealmRoles(), realmRoles);
        expect(_service.getResourceRoles(), clientRoles);

        verify(_mockInstance.realmAccess);
        verify(_mockInstance.resourceAccess);
      });

      test('user profile', () async {
        final profile = KeycloakProfile(username: 'tester');
        when(_mockInstance.loadUserProfile())
            .thenAnswer((_) => Future.value(profile));

        final profileFromService = await _service.getUserProfile();
        expect(profileFromService.username, profile.username);

        verify(_mockInstance.loadUserProfile());
      });

      test('token', () async {
        final token = 'crytic token';
        when(_mockInstance.token).thenReturn(token);

        expect(await _service.getToken(), token);
        verify(_mockInstance.token);
      });

      test('log in log out', () {
        _service.login();
        _service.logout();

        verify(_mockInstance.login(any));
        verify(_mockInstance.logout());
      });

      test('login with redirect url', () {
        final redirectUrl = 'www.testing.com/redirect';
        _service.login(redirectUri: redirectUrl);

        final captured = verify(_mockInstance.login(captureAny)).captured[0]
            as KeycloakLoginOptions;
        expect(captured.redirectUri, redirectUrl);
      });
    });
  });

  group('Multiple instances', () {
    final _configs = KeycloackServiceConfig([
      KeycloackServiceInstanceConfig(
          id: 'employee',
          configFilePath: 'employee.json',
          redirectUri: 'www.testing.com/employee',
          loadType: InitLoadType.checkSSO),
      KeycloackServiceInstanceConfig(
          id: 'customer',
          configFilePath: 'customer.json',
          redirectUri: 'www.testing.com/customer',
          loadType: InitLoadType.checkSSO)
    ]);

    MockKeycloakInstance _mockEmployeeInstance;
    MockKeycloakInstance _mockCustomerInstance;

    setUp(() {
      _mockEmployeeInstance = MockKeycloakInstance();
      when(_mockFactory.create(_configs.instanceConfigs[0].configFilePath))
          .thenReturn(_mockEmployeeInstance);

      _mockCustomerInstance = MockKeycloakInstance();
      when(_mockFactory.create(_configs.instanceConfigs[1].configFilePath))
          .thenReturn(_mockCustomerInstance);

      _service = KeycloakServiceImpl(_mockFactory, _configs);
    });

    test('with predefined configuration', () {});
  });
}

class MockKeycloakInstance extends Mock implements KeycloakInstance {}

class MockKeycloakResourceAccess extends Mock
    implements KeycloakResourceAccess {}

class MockKeycloakInstanceFactory extends Mock
    implements KeycloakInstanceFactory {}
