import 'package:angular_router/angular_router.dart' show RoutePath;

class SecuredRoute {
  final String keycloakInstanceId;
  final List<RoutePath> paths;
  final List<String> authorizedRoles;
  final RoutePath redirectPath;
  final bool authenticatingSetting;

  const SecuredRoute.authentication(
      {this.keycloakInstanceId, this.paths, this.redirectPath})
      : authenticatingSetting = true,
        authorizedRoles = null;
  const SecuredRoute.authorization(
      {this.keycloakInstanceId,
      this.paths,
      this.authorizedRoles,
      this.redirectPath})
      : authenticatingSetting = false;
}

class SecuredRouterHookConfig {
  final List<SecuredRoute> securedRoutes;

  const SecuredRouterHookConfig(this.securedRoutes);
}
