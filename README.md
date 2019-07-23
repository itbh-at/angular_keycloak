# Keycloak for AngularDart

Provide an Angular Service and a [RouterHook][routerhook] implementation for [AngularRouter][angularrouter].

## KeycloakService

An injectable class that manage [Keycloak][keycloak dart repository] instances. It provides essential functionalities with a simpler interface by encapsulating complex details such as updating token.

It is best to inject it at the root using the built-in `keycloakProviders`

```'dart'
import 'package:angular_keycloak/angular_keycloak.dart';

@GenerateInjector([keycloakProviders])
final InjectorFactory injector = self.injector$Injector;
...
runApp(ng.MyAppComponentNgFactory, createInjector: injector);
```

Advance user still can acquire the base [KeycloakInstace][keycloak dart repository: keycloakinstance] via the service.

### Single Instances

When one Keycloak instance is all the application need. There is no need to pay attention to `instanceId` which most of the service's API accept. The service is smart enough to recognize there is only one instance and all call or verification will go through it.

The usage of such use case can be study in [Example: Service Only](#example-service-only).

### Multiple Instances

`KeycloakService` supports multiple [KeycloakInstance][keycloak dart repository: keycloakinstance] configurations, but only one of them can be initialized at a time.

These multiple instance can be identify by using the `instanceId` in most of the API. Passing in `instanceId` is still optional, the purpose of passing it in is just for verification. e.g. those API will throw an exception if the initialized instance does not match the id.

### KeycloackServiceInstanceConfig

It is recommended to inject `KeycloackServiceInstanceConfig` along with the `KeycloakService` for multiple instances configuration. These are injectable class that allow user to predefine the configuration of each instance, and identify them with the `instanceId`.

The usage of such use case can be study in [Example: Multiple Instance and Secured Routing](#example).

## SecuredRouterHook

If the application is using [AngularRouter][angularrouter], `SecuredRouterHook` can be use as the [RouterHook][routerhook] to secure all the routes with `KeycloakService`. In the event of access denied, it will either redirect the path base on predefine configuration, or simply block the navigation.

It operates base on a set of predefined `SecuredRouterHookConfig`, which should be injected together.

To use it, inject it as a `RouterHook` at the root, along with `KeycloadService` and `AngularRouter`.

```'dart'
@GenerateInjector([
  keycloakProviders,
  FactoryProvider(SecuredRouterHookConfig, securedRouterHookConfigFactory),
  ClassProvider(RouterHook, useClass: SecuredRouterHook),
  routerProvidersHash, // You can use routerProviders in production
])
final InjectorFactory injector = self.injector$Injector;
```

### Securing Routes

Routes are secured by defining `SecuredRoute`(s) in `SecuredRouterHookConfig` and inject it to `SecuredRouterHook`.

There can be any number of `SecuredRoute`. Each of them define a particular set of security measure applied to the route(s). There are two type of `SecuredRoute`:

1. **`SecuredRoute.authentication()`** will only allow access when the `KeycloakInstance` in the `KeycloakService` is authenticated.
2. **`SecuredRoute.authorization`** will only allow access when the instance is authenticated and it has all the role(s) that is required.

Examples:

```'dart'
SecuredRouterHookConfig([
  SecuredRoute.authentication(
      keycloakInstanceId: 'employee',
      paths: [main_paths.RoutePaths.employee], // '/employee'
      redirectPath: main_paths.RoutePaths.employeeLogin),
  SecuredRoute.authorization(
      keycloakInstanceId: 'employee',
      paths: [employee_paths.RoutePaths.cashier], // '/employee/cashier'
      authorizedRoles: ['staff', 'supervisor'])
]);
```

The above code demonstrated a few security measure:

1. All paths starting with `/employee` need to be authenticate with `KeycloakInstance` of 'employee'.
2. Unauthenticated access will be redirected to `RoutePath`: `main_paths.RoutePaths.employeeLogin`.
3. All paths starting with `/employee/cashier` need to be has the authorized roles of 'staff' and 'supervisor', either from the Realms or the Clients.
4. Unauthorized access will simply blocked, no navigation will be done.

## Running the Examples

There are 2 examples in this package. They can be serve separately without interfering each other.

### Setup Keycloak Server

These examples assumed specific roles and clients. There are 2 json files readily made to be import into local Keycloak Server to setup the realm and client for example, namely 'customer-realm-export.json' and 'employee-realm-export.json'.

Users cannot be exported though. They still need to be created manually, and assign different client roles to those users to test authorization.

There are 2 roles in 'angulardart-demo-member' realm: 'member' and 'vip'.
There are 3 roels in 'angulardart-demo-employee' realm: 'staff', 'supervisor' and 'boss'.

'vip', 'supervisor' and 'boss' are composite roles. They contains the former roles by default.

### <a name="example-service-only"></a>Example: Service Only

This is the simplest way to get `KeycloakService` works with single instance without routing. There is no need of predefine configurations. And no need to use `instanceId` in all the `KeycloakService`'s APIs.

Run with: `webdev serve example-service-only:2700`

### <a name="example"></a>Example: Multiple Instance and Secured Routing

This is the complex example of having multiple instance and using `SecuredRouterHook` to secure Anuglar Routing.

Run with `webdev serve example:2700`

[RouterHook]:https://pub.dev/documentation/angular_router/2.0.0-alpha+23/angular_router/RouterHook-class.html
[AngularRouter]:https://pub.dev/packages/angular_router/versions/2.0.0-alpha+23
[keycloak dart repository]:https://github.com/itbh-at/keycloak
[keycloak dart repository: KeycloakInstance]:https://github.com/itbh-at/keycloak/blob/master/lib/src/keycloak_instance.dart
