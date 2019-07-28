import 'package:keycloak/keycloak.dart';

import 'keycloak_service_config.dart';

/// Throw when Keycloak APIs are accessed while instance is
/// not initialized.
class UninitializedException implements Exception {
  final String _msg;
  const UninitializedException(this._msg);
  String toString() => 'UninitializedException: $_msg';
}

/// Angular Service of Keycloak. Inject it at the root.
///
/// ```
/// @GenerateInjector([keycloakProviders])
/// final InjectorFactory injector = self.injector$Injector;
/// ```
///
/// Multiple [KeycloakInstance] can be configured using [KeycloackServiceConfig].
/// But only one [KeycloakInstance] can be initiated at any point of time.
///
/// Most of the method has optional `instanceId` argument to help
/// verify did the correct [KeycloakInstance] is being initiated. If a `instanceId`
/// passed in and doesn't match the initiated instance, an exception will throw.
///
/// Not passing in any `instanceId` usually mean use the default initiated instance.
///
/// For simple use case of using only one [KeycloakInstance], user can safely skip
/// passing in any `instanceId` for all the methods. [KeycloakService.init] can use directly
/// during app's `ngOnInit`
abstract class KeycloakService {
  /// Return `true` only if the instance has gone through [KeycloakInstance.init()].
  ///
  /// This is useful when having multiple instance configurations. To verify did
  /// the exact [instanceId] instance get initiated.
  ///
  /// Also useful if [KeycloakInstance.init()] is not called at the very beginning of the application.
  /// e.g. Only initiated [KeycloakInstance] when user visit certain URL.
  bool isInstanceInitiated({String instanceId});

  /// Initialize a new instance from injected [KeycloackServiceConfig].
  ///
  /// This should be call when redirecting back from a Keycloak authentication
  /// session, when the URL contains the hash for the token. In the case of multiple
  /// instances, the correct [instanceId] need to be supplied.
  ///
  /// This will throw an exception if there is no injected config.
  ///
  /// [redirectedOrigin] was the URL the application tried to navigated to
  /// before this method get called, which often navigate the browser away to
  /// Keycloak authentication service and back.
  ///
  /// In order for the application to navigate back to the original URL, this
  /// need to be suplied. Otherwise it will navigate to where [KeycloackServiceInstanceConfig]
  /// defined.
  Future initWithProvidedConfig({String instanceId, String redirectedOrigin});

  /// Initialize manually.
  ///
  /// Use this if not opting for [SecuredRouterHook] or mulitple [KeycloakInstance].
  ///
  /// Skip defining [config] if using all default option, e.g. with `keycloak.json` at root.
  Future<String> init(
      [KeycloackServiceInstanceConfig config =
          const KeycloackServiceInstanceConfig(),
      String redirectedOrigin]);

  /// Return `true` if the instance is authenticated with Keycloak.
  bool isAuthenticated({String instanceId});

  List<String> getRealmRoles({String instanceId});

  /// Return the authorized client's roles.
  ///
  /// If [clientId] is omitted, it will retrieve one from the initiated instance.
  List<String> getResourceRoles({String instanceId, String clientId});

  /// Return the user information.
  ///
  /// This method will call [KeycloakInstance.updateToken()] if
  /// [KeycloackServiceInstanceConfig.autoUpdate] is true.
  Future<KeycloakProfile> getUserProfile({String instanceId});

  /// Return the token to get authorization when accessing other services.
  ///
  /// This method will call [KeycloakInstance.updateToken()] if
  /// [KeycloackServiceInstanceConfig.autoUpdate] is true.
  Future<String> getToken({String instanceId});

  /// Login with the instance.
  ///
  /// [redirectUri] will pass down to [KeycloakInstance.login()], for URL redirect
  /// back to, after authentication.
  ///
  /// Navigating back to this [redirectUri] should trigger the application
  /// to call [KeycloakService.initWithProvidedConfig] or [initWithProvidedConfig.init].
  void login({String instanceId, String redirectUri});

  void logout({String instanceId});

  /// Manually update the token. This was the default way Keycloak recommended.
  Future<bool> updateToken({String instanceId, num minValidity = 30});

  /// Return the [KeycloakInstance ]. Only for advance usage.
  KeycloakInstance getInstance([String instanceId]);
}
