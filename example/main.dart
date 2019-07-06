import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/secured_router_hook.dart';
import 'package:angular_keycloak/keycloak_service.dart';

import 'app/example_app_component.template.dart' as ng;
import 'main.template.dart' as self;

import 'app/route_paths.dart';

KeycloackServiceConfig keycloakConfigFactory() => KeycloackServiceConfig()
  ..instanceConfigs.add(KeycloackServiceInstanceConfig()
    ..id = 'employee'
    ..configFilePath = 'employee.json'
    ..redirectRoutePath = RoutePaths.employee
    ..loadType = InitLoadType.checkSSO)
  ..instanceConfigs.add(KeycloackServiceInstanceConfig()
    ..id = 'customer'
    ..configFilePath = 'customer.json'
    ..redirectRoutePath = RoutePaths.customer
    ..loadType = InitLoadType.checkSSO);

SecuredRouterHookSetting hookSettingFactory() => SecuredRouterHookSetting()
  ..settings.add(SecureRouteSetting()
    ..keycloakInstanceId = 'customer'
    ..redirectPath = RoutePaths.customerLogin
    ..paths.add(RoutePaths.customer))
  ..settings.add(SecureRouteSetting()
    ..keycloakInstanceId = 'employee'
    ..redirectPath = RoutePaths.employeeLogin
    ..paths.add(RoutePaths.employee));

@GenerateInjector([
  FactoryProvider(KeycloackServiceConfig, keycloakConfigFactory),
  FactoryProvider(SecuredRouterHookSetting, hookSettingFactory),
  ClassProvider(KeycloakService),
  ClassProvider(RouterHook, useClass: SecuredRouterHook),
  routerProvidersHash, // You can use routerProviders in production
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.ExampleAppComponentNgFactory, createInjector: injector);
}
