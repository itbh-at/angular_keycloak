import 'package:angular_keycloak/keycloak_service.dart';
import 'package:angular_keycloak/secured_router_hook.dart';

import 'route_paths.dart' as main_paths;
import 'customer/route_paths.dart' as customer_paths;
import 'employee/route_paths.dart' as employee_paths;

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

SecuredRouterHookConfig hookSettingFactory() => SecuredRouterHookConfig()
  ..settings.add(SecuredRoute.authentication(
      keycloakInstanceId: 'customer',
      paths: [main_paths.RoutePaths.customer],
      redirectPath: main_paths.RoutePaths.customerLogin))
  ..settings.add(SecuredRoute.authorization(
      keycloakInstanceId: 'customer',
      paths: [main_paths.RoutePaths.customer],
      authorizedRoles: ['member']))
  ..settings.add(SecuredRoute.authorization(
      keycloakInstanceId: 'customer',
      paths: [customer_paths.RoutePaths.vip],
      authorizedRoles: ['vip'],
      redirectPath: main_paths.RoutePaths.public))
  ..settings.add(SecuredRoute.authentication(
      keycloakInstanceId: 'employee',
      paths: [main_paths.RoutePaths.employee],
      redirectPath: main_paths.RoutePaths.employeeLogin))
  ..settings.add(SecuredRoute.authorization(
      keycloakInstanceId: 'employee',
      paths: [employee_paths.RoutePaths.cashier],
      authorizedRoles: ['staff', 'supervisor'],
      redirectPath: main_paths.RoutePaths.public))
  ..settings.add(SecuredRoute.authorization(
      keycloakInstanceId: 'employee',
      paths: [employee_paths.RoutePaths.bossRoom],
      authorizedRoles: ['boss'],
      redirectPath: main_paths.RoutePaths.public));
