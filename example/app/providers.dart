import 'dart:html' show window;

import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/keycloak_service.dart';
import 'package:angular_keycloak/secured_router_hook.dart';

import 'route_paths.dart' as main_paths;
import 'customer/route_paths.dart' as customer_paths;
import 'employee/route_paths.dart' as employee_paths;

KeycloackServiceConfig keycloakConfigFactory(
        LocationStrategy _locationStrategy) =>
    KeycloackServiceConfig()
      ..instanceConfigs.add(KeycloackServiceInstanceConfig()
        ..id = 'employee'
        ..configFilePath = 'employee.json'
        ..redirectUri =
            '${window.location.origin}/${_locationStrategy.prepareExternalUrl(main_paths.RoutePaths.employee.toUrl())}'
        ..loadType = InitLoadType.checkSSO)
      ..instanceConfigs.add(KeycloackServiceInstanceConfig()
        ..id = 'customer'
        ..configFilePath = 'customer.json'
        ..redirectUri =
            '${window.location.origin}/${_locationStrategy.prepareExternalUrl(main_paths.RoutePaths.customer.toUrl())}'
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
      authorizedRoles: ['vip']))
  ..settings.add(SecuredRoute.authentication(
      keycloakInstanceId: 'employee',
      paths: [main_paths.RoutePaths.employee],
      redirectPath: main_paths.RoutePaths.employeeLogin))
  ..settings.add(SecuredRoute.authorization(
      keycloakInstanceId: 'employee',
      paths: [employee_paths.RoutePaths.cashier],
      authorizedRoles: ['staff', 'supervisor'],
      redirectPath: main_paths.RoutePaths.unauthorized))
  ..settings.add(SecuredRoute.authorization(
      keycloakInstanceId: 'employee',
      paths: [employee_paths.RoutePaths.bossRoom],
      authorizedRoles: ['boss'],
      redirectPath: main_paths.RoutePaths.unauthorized));
