/// Three behaviour when initializing a Keycloak instance
enum InitLoadType { standard, loginRequired, checkSSO }

/// Three type of flow when initializing a Keycloak instance
/// Read more at https://www.keycloak.org/docs/latest/securing_apps/index.html#_javascript_implicit_flow
enum InitFlowType { standard, implicit, hybrid }

/// Configuration of one [KeycloakInstance] in the [KeycloakService].
class KeycloackServiceInstanceConfig {
  /// Unique identifier for [KeycloakInstance] spawned from this config.
  /// It is useful when to check the status of the instance, e.g. initiated or not.
  final String id;

  /// Leave blank if there is a 'keycloak.json' at the root folder,
  /// Otherwise, keycloak will look for the config file at this path.
  final String configFilePath;

  /// Specific URL to visit if the initializing of the instance navigated away,
  /// e.g. using a [InitLoadType.loginRequired] or [InitLoadType.checkSSO].
  final String redirectUri;

  /// Default to [InitLoadType.standard]
  final InitLoadType loadType;

  /// Default to [InitFlowType.standard]
  final InitFlowType flowType;

  /// Should [KeycloakService] try to update the token automatically.
  ///
  /// If this is set to true, the service will make a call to [KeycloakIntance.updateToken()]
  /// before returning the token via [KeycloakService.getToken] and
  /// calling [KeycloakService.getUserProfile].
  ///
  /// If this is false, [KeycloakService.updateToken] need to be call manually.
  ///
  /// If [InitFlowType.implicit] was used, this has no effect as refresh token
  /// is not acquired.
  ///
  /// Default to `true`.
  final bool autoUpdate;

  /// A timing a token should have before expiringly when calling [KeycloakService.updateToken].
  ///
  /// If token will be expired before this time, it will be refreshed. Otherwise,
  /// it will stay the same even after calling [KeycloakService.updateToken].
  ///
  /// Default to `30 seconds`.
  final int autoUpdateMinValidity;

  const KeycloackServiceInstanceConfig(
      {this.id,
      this.configFilePath,
      this.redirectUri,
      this.loadType = InitLoadType.standard,
      this.flowType = InitFlowType.standard,
      this.autoUpdate = true,
      this.autoUpdateMinValidity = 30});
}

/// To be injected along with [KeycloakService] to predefine all the
/// instance configurations.
///
/// ```
/// import 'dart:html' show window;
/// import 'package:angular_keycloak/angular_keycloak.dart';
///
/// KeycloackServiceConfig keycloakConfigFactory() =>
///   KeycloackServiceConfig([
///     KeycloackServiceInstanceConfig(
///         id: 'employee',
///         configFilePath: 'employee.json',
///         redirectUri: '${window.location.origin}/employee',
///         loadType: InitLoadType.checkSSO),
///     KeycloackServiceInstanceConfig(
///         id: 'customer',
///         configFilePath: 'customer.json',
///         redirectUri: '${window.location.origin}/customer',
///         loadType: InitLoadType.checkSSO)
///   ]);
///
/// @GenerateInjector([
///  FactoryProvider(KeycloackServiceConfig, keycloakConfigFactory),
///  keycloakProviders
/// ])
/// final InjectorFactory injector = self.injector$Injector;
/// ```
class KeycloackServiceConfig {
  final List<KeycloackServiceInstanceConfig> instanceConfigs;

  const KeycloackServiceConfig(this.instanceConfigs);
}
