import 'dart:html' show window;

import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/angular_keycloak.dart';

import 'route_paths.dart' as main_paths;
import 'customer/route_paths.dart' as customer_paths;
import 'employee/route_paths.dart' as employee_paths;

KeycloackServiceConfig keycloakConfigFactory(
        LocationStrategy _locationStrategy) =>
    KeycloackServiceConfig([
      KeycloackServiceInstanceConfig(
          id: 'employee',
          configFilePath: 'employee.json',
          redirectUri:
              '${window.location.origin}/${_locationStrategy.prepareExternalUrl(main_paths.RoutePaths.employee.toUrl())}',
          loadType: InitLoadType.checkSSO),
      KeycloackServiceInstanceConfig(
          id: 'customer',
          configFilePath: 'customer.json',
          redirectUri:
              '${window.location.origin}/${_locationStrategy.prepareExternalUrl(main_paths.RoutePaths.customer.toUrl())}',
          loadType: InitLoadType.checkSSO)
    ]);

SecuredRouterHookConfig securedRouterHookConfigFactory() =>
    SecuredRouterHookConfig([
      SecuredRoute.authentication(
          keycloakInstanceId: 'customer',
          paths: [main_paths.RoutePaths.customer],
          redirectPath: main_paths.RoutePaths.customerLogin),
      SecuredRoute.authorization(
          keycloakInstanceId: 'customer',
          paths: [main_paths.RoutePaths.customer],
          authorizedRoles: ['member']),
      SecuredRoute.authorization(
          keycloakInstanceId: 'customer',
          paths: [customer_paths.RoutePaths.vip],
          authorizedRoles: ['vip']),
      SecuredRoute.authentication(
          keycloakInstanceId: 'employee',
          paths: [main_paths.RoutePaths.employee],
          redirectPath: main_paths.RoutePaths.employeeLogin),
      SecuredRoute.authorization(
          keycloakInstanceId: 'employee',
          paths: [employee_paths.RoutePaths.cashier],
          authorizedRoles: ['staff', 'supervisor'],
          redirectPath: main_paths.RoutePaths.unauthorized),
      SecuredRoute.authorization(
          keycloakInstanceId: 'employee',
          paths: [employee_paths.RoutePaths.bossRoom],
          authorizedRoles: ['boss'],
          redirectPath: main_paths.RoutePaths.unauthorized)
    ]);
