import 'package:angular_router/angular_router.dart' show RoutePath;

/// Configuration to secure a list of [paths].
///
/// The basic security is make sure the [KeycloakInstance] by [keycloakInstanceId]
/// in the [KeycloakService] is authenticated before letting the navigation to
/// these [paths] pass.
///
/// Another type of security is making sure the authenticated [KeycloakInstance] has
/// the correct authorization. i.e. having the correct [authorizedRoles].
class SecuredRoute {
  /// Secure this route for a particular instance.
  final String keycloakInstanceId;

  /// Define the list of [RoutePath] to be secured.
  ///
  /// All subroutes will be secured. Example:
  /// - `/customer`
  /// - `/customer/dining`
  /// - `/customer/dining/washroom`
  /// Will all be secured by the path `/customer`. There's no need to define all
  /// possible sub routes.
  final List<RoutePath> paths;

  /// A list of `String` to match the roles defined in Keycloak server setting.
  ///
  /// Not contaning any of the roles after combining [KeycloakService.getRealmRoles]
  /// and [KeycloakService.getResourceRoles] will not be authorize, and denied access.
  final List<String> authorizedRoles;

  /// Redirect the navigation to [redirectPath] if access is denied.
  /// E.g. navigate the user to the login page.
  ///
  /// If this is not defined, i.e. `null`. The navigation will simply blocked.
  /// Blocking is useful if [Router.navigate()] was use directly.
  final RoutePath redirectPath;

  /// `true` if this route is securing by authorization.
  ///
  /// Used by [SecuredRouterHook].
  final bool isAuthorizingRoute;

  /// A [SecuredRoute] that allows only authenticated access.
  const SecuredRoute.authentication(
      {this.keycloakInstanceId, this.paths, this.redirectPath})
      : isAuthorizingRoute = false,
        authorizedRoles = null;

  /// A [SecuredRoute] that allows only authoerized access.
  const SecuredRoute.authorization(
      {this.keycloakInstanceId,
      this.paths,
      this.authorizedRoles,
      this.redirectPath})
      : isAuthorizingRoute = true;
}

/// To be injected along with [SecuredRouterHook] and [KeycloakService] to
/// predefine all the [SecuredRoute] configurations.
///
/// ```
/// SecuredRouterHookConfig securedRouterHookConfigFactory() =>
///    SecuredRouterHookConfig([
///      SecuredRoute.authentication(
///          keycloakInstanceId: 'customer',
///          paths: [main_paths.RoutePaths.customer],
///          redirectPath: main_paths.RoutePaths.customerLogin),
///      SecuredRoute.authorization(
///          keycloakInstanceId: 'customer',
///          paths: [main_paths.RoutePaths.customer],
///          authorizedRoles: ['member']),
///      SecuredRoute.authorization(
///          keycloakInstanceId: 'customer',
///          paths: [customer_paths.RoutePaths.vip],
///          authorizedRoles: ['vip']),
///      SecuredRoute.authentication(
///          keycloakInstanceId: 'employee',
///          paths: [main_paths.RoutePaths.employee],
///          redirectPath: main_paths.RoutePaths.employeeLogin),
///      SecuredRoute.authorization(
///          keycloakInstanceId: 'employee',
///          paths: [employee_paths.RoutePaths.cashier],
///          authorizedRoles: ['staff', 'supervisor'],
///          redirectPath: main_paths.RoutePaths.unauthorized),
///      SecuredRoute.authorization(
///          keycloakInstanceId: 'employee',
///          paths: [employee_paths.RoutePaths.bossRoom],
///          authorizedRoles: ['boss'],
///          redirectPath: main_paths.RoutePaths.unauthorized)
///    ]);
///
/// @GenerateInjector([
///   FactoryProvider(KeycloackServiceConfig, keycloakConfigFactory),
///   FactoryProvider(SecuredRouterHookConfig, securedRouterHookConfigFactory),
///   keycloakProviders,
///   ClassProvider(RouterHook, useClass: SecuredRouterHook),
///   routerProvidersHash, // You can use routerProviders in production
/// ])
/// final InjectorFactory injector = self.injector$Injector;
/// ```
class SecuredRouterHookConfig {
  final List<SecuredRoute> securedRoutes;

  const SecuredRouterHookConfig(this.securedRoutes);
}
