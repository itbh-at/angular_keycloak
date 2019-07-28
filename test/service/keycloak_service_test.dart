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

    group('Update token', () {
      setUp(() {
        when(_mockFactory.create()).thenReturn(_mockInstance);
      });

      test('automatic when get token, with default config', () async {
        await _service.init();
        await _service.getToken();

        verify(_mockInstance.updateToken(any));
      });

      test('automatic when get profile, with custom min validity', () async {
        await _service
            .init(KeycloackServiceInstanceConfig(autoUpdateMinValidity: 1234));
        await _service.getUserProfile();

        verify(_mockInstance.updateToken(1234));
      });

      test('turned off when configured.', () async {
        await _service.init(KeycloackServiceInstanceConfig(autoUpdate: false));
        await _service.getUserProfile();

        verifyNever(_mockInstance.updateToken(any));
      });

      test('turned off when using implicit flow', () async {
        await _service.init(
            KeycloackServiceInstanceConfig(flowType: InitFlowType.implicit));
        await _service.getUserProfile();

        verifyNever(_mockInstance.updateToken(any));
      });
    });
  });

  group('Multiple instances', () {
    final _employeeInstanceId = 'employee';
    final _customerInstanceId = 'customer';
    final _configs = KeycloackServiceConfig([
      KeycloackServiceInstanceConfig(
          id: _employeeInstanceId,
          configFilePath: 'employee.json',
          redirectUri: 'www.testing.com/employee',
          loadType: InitLoadType.checkSSO),
      KeycloackServiceInstanceConfig(
          id: _customerInstanceId,
          configFilePath: 'customer.json',
          redirectUri: 'www.testing.com/customer',
          loadType: InitLoadType.loginRequired)
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

    test('init with id', () async {
      await _service.initWithProvidedConfig(instanceId: _employeeInstanceId);

      verifyNever(_mockCustomerInstance.init(any));
      final captured = verify(_mockEmployeeInstance.init(captureAny))
          .captured[0] as KeycloakInitOptions;
      expect(captured.redirectUri, 'www.testing.com/employee');
      expect(captured.onLoad, 'check-sso');

      expect(_service.isInstanceInitiated(instanceId: _employeeInstanceId),
          isTrue);
      expect(_service.isInstanceInitiated(instanceId: _customerInstanceId),
          isFalse);
    });

    test(
        'Accessing with instance Id or without, result the same for active instance',
        () async {
      final testingToken = 'testing-token';

      await _service.initWithProvidedConfig(instanceId: _employeeInstanceId);
      when(_mockEmployeeInstance.token).thenReturn(testingToken);

      expect(await _service.getToken(), testingToken);
      expect(await _service.getToken(instanceId: _employeeInstanceId),
          testingToken);

      verify(_mockEmployeeInstance.token).called(2);
    });

    test('error when accesing API of the uniniatialized instance', () async {
      await _service.initWithProvidedConfig(instanceId: _customerInstanceId);
      when(_mockCustomerInstance.authenticated).thenReturn(true);

      expect(_service.isAuthenticated(instanceId: _customerInstanceId), isTrue);

      // Wrap the actual call into a function with no argument,
      // as per required to test `throwsA`.
      expect(() => _service.isAuthenticated(instanceId: _employeeInstanceId),
          throwsA(TypeMatcher<UninitializedException>()));
    });
  });
}

class MockKeycloakInstance extends Mock implements KeycloakInstance {}

class MockKeycloakResourceAccess extends Mock
    implements KeycloakResourceAccess {}

class MockKeycloakInstanceFactory extends Mock
    implements KeycloakInstanceFactory {}
