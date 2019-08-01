@TestOn('browser')
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_router/testing.dart';
import 'package:angular_test/angular_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:angular_keycloak/angular_keycloak.dart';

import 'secured_router_hook_test.template.dart' as ng;

void main() {
  Router _router;
  Location _location;
  MockKeycloakService _mockKeycloakService;

  setUp(() async {
    final testBed = NgTestBed.forComponent(ng.TestAppComponentNgFactory)
        .addInjector(createInjector);
    final testFixture =
        await testBed.create(beforeComponentCreated: (injector) {
      _router = injector.provideType(Router);
      _mockKeycloakService =
          injector.provideType(KeycloakService) as MockKeycloakService;
      _location = injector.provideType(Location);
    });
  });

  tearDown(() => disposeAnyRunningTest());

  test(
      'initiating the keycloak instance when first time navigating to secured path',
      () async {
    when(_mockKeycloakService.isInstanceInitiated(
            instanceId: anyNamed('instanceId')))
        .thenReturn(false);
    when(_mockKeycloakService.isAuthenticated(
            instanceId: anyNamed('instanceId')))
        .thenReturn(false);

    await _router.navigate(RoutePaths.customer.toUrl());

    final capturedInstanceId = verify(
            _mockKeycloakService.initWithProvidedConfig(
                instanceId: captureAnyNamed('instanceId'),
                redirectedOrigin: anyNamed('redirectedOrigin')))
        .captured[0];
    expect(capturedInstanceId, 'customer');
  });

  test('redirect to SecuredRoute.redirectPath when not authenticated',
      () async {
    when(_mockKeycloakService.isInstanceInitiated(
            instanceId: anyNamed('instanceId')))
        .thenReturn(true);
    when(_mockKeycloakService.isAuthenticated(
            instanceId: anyNamed('instanceId')))
        .thenReturn(false);

    final navigationResult =
        await _router.navigate(RoutePaths.customer.toUrl());

    expect(navigationResult, NavigationResult.SUCCESS);
    expect(_location.path(), RoutePaths.customerLogin.toUrl());
  });

  test('block when SecuredRoute.redirectPath is undefined and not authorized',
      () async {
    when(_mockKeycloakService.isInstanceInitiated(
            instanceId: anyNamed('instanceId')))
        .thenReturn(true);
    when(_mockKeycloakService.isAuthenticated(
            instanceId: anyNamed('instanceId')))
        .thenReturn(true);
    when(_mockKeycloakService.getRealmRoles(instanceId: anyNamed('instanceId')))
        .thenReturn([]);
    when(_mockKeycloakService.getResourceRoles(
            instanceId: anyNamed('instanceId')))
        .thenReturn(['member']);

    final navigationResult = await _router.navigate(RoutePaths.vip.toUrl());

    expect(navigationResult, NavigationResult.BLOCKED_BY_GUARD);
  });

  test('proceed with path when authenticated', () async {
    when(_mockKeycloakService.isInstanceInitiated(
            instanceId: anyNamed('instanceId')))
        .thenReturn(true);
    when(_mockKeycloakService.isAuthenticated(
            instanceId: anyNamed('instanceId')))
        .thenReturn(true);
    when(_mockKeycloakService.getRealmRoles(instanceId: anyNamed('instanceId')))
        .thenReturn([]);
    when(_mockKeycloakService.getResourceRoles(
            instanceId: anyNamed('instanceId')))
        .thenReturn(['member']);

    final navigationResult =
        await _router.navigate(RoutePaths.customer.toUrl());

    expect(navigationResult, NavigationResult.SUCCESS);
    expect(_location.path(), RoutePaths.customer.toUrl());
  });

  test('proceed with role-secured path when authorized', () async {
    when(_mockKeycloakService.isInstanceInitiated(
            instanceId: anyNamed('instanceId')))
        .thenReturn(true);
    when(_mockKeycloakService.isAuthenticated(
            instanceId: anyNamed('instanceId')))
        .thenReturn(true);
    when(_mockKeycloakService.getRealmRoles(instanceId: anyNamed('instanceId')))
        .thenReturn([]);
    when(_mockKeycloakService.getResourceRoles(
            instanceId: anyNamed('instanceId')))
        .thenReturn(['member', 'vip']);

    final navigationResult = await _router.navigate(RoutePaths.vip.toUrl());

    expect(navigationResult, NavigationResult.SUCCESS);
    expect(_location.path(), RoutePaths.vip.toUrl());
  });
}

class RoutePaths {
  static final customerLogin = RoutePath(path: 'customer-login');
  static final customer = RoutePath(path: 'customer');
  static final vip = RoutePath(path: 'vip', parent: customer);

  static final employeeLogin = RoutePath(path: 'employee-login');
  static final employee = RoutePath(path: 'employee');
  static final kitchen = RoutePath(path: 'kitchen', parent: employee);
  static final cashier = RoutePath(path: 'cashier', parent: kitchen);
  static final bossRoom = RoutePath(path: 'boss-room', parent: cashier);

  static final unauthorized = RoutePath(path: 'unauthorized');
}

@GenerateInjector([
  FactoryProvider(KeycloackServiceConfig, keycloakConfigFactory),
  FactoryProvider(SecuredRouterHookConfig, securedRouterHookConfigFactory),
  ClassProvider(KeycloakService, useClass: MockKeycloakService),
  routerProvidersTest,
  ClassProvider(RouterHook, useClass: SecuredRouterHook),
])
final createInjector = ng.createInjector$Injector;

@Component(
  selector: 'test-app',
  directives: [RouterOutlet],
  template: '<router-outlet [routes]="routes"></router-outlet>',
)
class TestAppComponent {
  final Router router;
  static final routes = [
    RouteDefinition(
        routePath: RoutePaths.customerLogin,
        component: ng.CustomerLoginComponentNgFactory),
    RouteDefinition(
        routePath: RoutePaths.customer,
        component: ng.CustomerComponentNgFactory)
  ];

  TestAppComponent(this.router);
}

@Component(selector: 'customer-login', template: '<h1>customer login</h1>')
class CustomerLoginComponent {}

@Component(selector: 'customer', directives: [RouterOutlet], template: '''
    <h1>customer</h1>
    <router-outlet [routes]="routes"></router-outlet>
    ''')
class CustomerComponent {
  static final routes = [
    RouteDefinition(
        routePath: RoutePaths.vip, component: ng.VipComponentNgFactory),
  ];
}

@Component(selector: 'vip', template: '<h1>vip</h1>')
class VipComponent {}

KeycloackServiceConfig keycloakConfigFactory(
        LocationStrategy _locationStrategy) =>
    KeycloackServiceConfig([
      KeycloackServiceInstanceConfig(
          id: 'employee', configFilePath: 'employee.json'),
      KeycloackServiceInstanceConfig(
          id: 'customer', configFilePath: 'customer.json')
    ]);

SecuredRouterHookConfig securedRouterHookConfigFactory() =>
    SecuredRouterHookConfig([
      SecuredRoute.authentication(
          keycloakInstanceId: 'customer',
          paths: [RoutePaths.customer],
          redirectPath: RoutePaths.customerLogin),
      SecuredRoute.authorization(
          keycloakInstanceId: 'customer',
          paths: [RoutePaths.customer],
          authorizedRoles: ['member']),
      SecuredRoute.authorization(
          keycloakInstanceId: 'customer',
          paths: [RoutePaths.vip],
          authorizedRoles: ['vip']),
      SecuredRoute.authentication(
          keycloakInstanceId: 'employee',
          paths: [RoutePaths.employee],
          redirectPath: RoutePaths.employeeLogin),
      SecuredRoute.authorization(
          keycloakInstanceId: 'employee',
          paths: [RoutePaths.cashier],
          authorizedRoles: ['staff', 'supervisor'],
          redirectPath: RoutePaths.unauthorized),
      SecuredRoute.authorization(
          keycloakInstanceId: 'employee',
          paths: [RoutePaths.bossRoom],
          authorizedRoles: ['boss'],
          redirectPath: RoutePaths.unauthorized)
    ]);

class MockKeycloakService extends Mock implements KeycloakService {}
