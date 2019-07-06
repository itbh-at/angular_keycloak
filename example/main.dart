import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/secured_router_hook.dart';
import 'package:angular_keycloak/keycloak_service.dart';

import 'app/example_app_component.template.dart' as ng;
import 'main.template.dart' as self;

import 'app/route_paths.dart' as main_paths;
import 'app/customer/route_paths.dart' as customer_paths;
import 'app/employee/route_paths.dart' as employee_paths;

KeycloackServiceConfig keycloakConfigFactory() => KeycloackServiceConfig()
  ..instanceConfigs.add(KeycloackServiceInstanceConfig()
    ..id = 'employee'
    ..configFilePath = 'employee.json'
    ..redirectRoutePath = main_paths.RoutePaths.employee
    ..loadType = InitLoadType.checkSSO)
  ..instanceConfigs.add(KeycloackServiceInstanceConfig()
    ..id = 'customer'
    ..configFilePath = 'customer.json'
    ..redirectRoutePath = main_paths.RoutePaths.customer
    ..loadType = InitLoadType.checkSSO);

SecuredRouterHookSetting hookSettingFactory() => SecuredRouterHookSetting()
  ..settings.add(SecureRouteSetting()
    ..keycloakInstanceId = 'customer'
    ..redirectPath = main_paths.RoutePaths.customerLogin
    ..roles.add('member')
    ..paths.add(main_paths.RoutePaths.customer))
  ..settings.add(SecureRouteSetting()
    ..keycloakInstanceId = 'customer'
    ..redirectPath = main_paths.RoutePaths.public
    ..roles.add('vip')
    ..paths.add(customer_paths.RoutePaths.vip))
  ..settings.add(SecureRouteSetting()
    ..keycloakInstanceId = 'employee'
    ..redirectPath = main_paths.RoutePaths.employeeLogin
    ..roles.add('staff')
    ..paths.add(main_paths.RoutePaths.employee))
  ..settings.add(SecureRouteSetting()
    ..keycloakInstanceId = 'employee'
    ..redirectPath = main_paths.RoutePaths.public
    ..roles.add('staff')
    ..roles.add('supervisor')
    ..paths.add(employee_paths.RoutePaths.cashier))
  ..settings.add(SecureRouteSetting()
    ..keycloakInstanceId = 'employee'
    ..redirectPath = main_paths.RoutePaths.public
    ..roles.add('boss')
    ..paths.add(employee_paths.RoutePaths.bossRoom));

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
