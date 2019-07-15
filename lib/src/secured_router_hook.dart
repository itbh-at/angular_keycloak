import 'dart:html' show window;
import 'dart:async' show FutureOr;

import 'package:angular/di.dart' show Injectable;
import 'package:angular_router/angular_router.dart';

import 'keycloak_service.dart';
import 'secured_router_hook_config.dart';

/// A [RouterHook] implementation that securing navigation with [KeycloakService].
///
/// Once setup, this class will perform all the path redirection/blocking base on
/// the configuration passed in.
///
/// This need to be injected along with [KeycloakService] and its config [SecuredRouterHookConfig].
/// ```
/// @GenerateInjector([
///   keycloakProviders,
///   FactoryProvider(SecuredRouterHookConfig, securedRouterHookConfigFactory),
///   ClassProvider(RouterHook, useClass: SecuredRouterHook),
///   routerProviders,
/// ])
/// final InjectorFactory injector = self.injector$Injector;
/// ...
/// runApp(ng.MyAppComponentNgFactory, createInjector: injector);
/// ```
@Injectable()
class SecuredRouterHook implements RouterHook {
  final KeycloakService _keycloakService;
  final LocationStrategy _locationStrategy;
  final SecuredRouterHookConfig _config;

  /// [SecuredRoute] are split into 2 lists.
  ///
  /// [_redirectingRoutes] is use when securing [RouterHook.navigationPath].
  /// [_blockingRoutes] is use when securing [RouterHook.canActivate].
  final _redirectingRoutes = <SecuredRoute>[];
  final _blockingRoutes = <SecuredRoute>[];

  /// The origin URL [SecuredRouterHook] has denied access to and redirected navigation.
  ///
  /// It is store paired with the new path we passed back from [navigationPath()].
  /// Later retrieved by [navigationParams] to formulate as a query parameter.
  ///
  /// This will be clear every time [navigationPath()] gets call again.
  final _directedAwayOrigins = <String, String>{};

  SecuredRouterHook(
      this._keycloakService, this._locationStrategy, this._config) {
    for (final securedRoute in _config.securedRoutes) {
      if (securedRoute.redirectPath != null) {
        _redirectingRoutes.add(securedRoute);
      } else {
        _blockingRoutes.add(securedRoute);
      }
    }
  }

  /// Redirect [path] to [SecuredRoute.redirectPath] if access is denied.
  ///
  /// The original [path] will be store and used up by [navigationParams].
  Future<String> navigationPath(String path, NavigationParams params) async {
    // Clean up the Keycloak token hash when using [HashLocationStrategy]
    if (_locationStrategy is HashLocationStrategy) {
      var andPlace = path.indexOf('&');
      if (andPlace != -1) {
        path = path.substring(0, andPlace);
      }
    }

    // Match [path] against all [_redirectingRoutes] to determine if it is secured.
    // If it is secured, Check for access.
    for (final securedRoute in _redirectingRoutes) {
      for (final securingPath in securedRoute.paths) {
        final securedPath = securingPath.toUrl();
        if (_match(path, securedPath)) {
          if (await _verifyOrInitiateKeycloakInstance(
              securedRoute.keycloakInstanceId, path)) {
            bool accessDenied = false;
            if (!_isAuthenticated(securedRoute.keycloakInstanceId)) {
              accessDenied = true;
            } else if (securedRoute.isAuthorizingRoute &&
                !_isAuthorized(securedRoute.keycloakInstanceId,
                    securedRoute.authorizedRoles)) {
              accessDenied = true;
            }

            if (accessDenied) {
              // Before we redirect user to another path, We store the current path.
              // It will be used in [navigationParams] to pass down the original path.
              final redirectedPathUrl = securedRoute.redirectPath.toUrl();
              _directedAwayOrigins[redirectedPathUrl] = path;
              return redirectedPathUrl;
            }
          }
        }
      }
    }
    return path;
  }

  /// Add [queryParameters] to pass down the directed origin URL.
  ///
  /// [navigationParams] is called right after [navigationPath].
  /// If a redirection happened in [navigationPath], we will append the origin URL
  /// to the URL as `?origin=<url>`.
  Future<NavigationParams> navigationParams(
      String path, NavigationParams params) async {
    if (_directedAwayOrigins.isNotEmpty) {
      final origin = _directedAwayOrigins[path];
      _directedAwayOrigins.clear();

      if (origin != null) {
        final newParams = NavigationParams(
            queryParameters: {'origin': origin},
            fragment: params.fragment,
            reload: params.reload,
            replace: params.replace,
            updateUrl: params.updateUrl);
        return newParams;
      }
    }
    return params;
  }

  /// Block the navigation if access is denied.
  ///
  /// This happen when [SecuredRoute.redirectPath] is not defined.
  ///
  /// When access is denied, this will block the navigation. Result in a
  /// [NavigationResult.BLOCKED_BY_GUARD] for [Router.navigate()].
  Future<bool> canActivate(Object componentInstance, RouterState oldState,
      RouterState newState) async {
    final path = newState.path;
    for (final securedRoute in _blockingRoutes) {
      for (final securingPath in securedRoute.paths) {
        final securedPath = securingPath.toUrl();
        if (_match(path, securedPath)) {
          if (await _verifyOrInitiateKeycloakInstance(
              securedRoute.keycloakInstanceId)) {
            if (!_isAuthenticated(securedRoute.keycloakInstanceId)) {
              return false;
            } else if (securedRoute.isAuthorizingRoute &&
                !_isAuthorized(securedRoute.keycloakInstanceId,
                    securedRoute.authorizedRoles)) {
              return false;
            }
          }
        }
      }
    }

    return true;
  }

  Future<bool> canDeactivate(Object componentInstance, RouterState oldState,
      RouterState newState) async {
    // Provided as a default if someone extends or mixes-in this interface.
    return true;
  }

  Future<bool> canNavigate() async {
    // Provided as a default if someone extends or mixes-in this interface.
    return true;
  }

  Future<bool> canReuse(Object componentInstance, RouterState oldState,
      RouterState newState) async {
    // Provided as a default if someone extends or mixes-in this interface.
    return false;
  }

  /// Check if [path] matches or is subroute of [securedPath]
  bool _match(String path, String securedPath) {
    if (path == securedPath) {
      return true;
    } else if (securedPath.length > path.length) {
      return false;
    } else {
      var tokens = path.split('/');
      var securedTokens = securedPath.split('/');
      for (var i = 0; i < securedTokens.length; i++) {
        if (tokens[i] != securedTokens[i]) {
          return false;
        }
      }
      return true;
    }
  }

  /// Return `true` when the [KeycloakInstance] of [instanceId] is initiated
  /// in [KeycloakService].
  ///
  /// If it's not initiated, this method will initiate it.
  FutureOr _verifyOrInitiateKeycloakInstance(String instanceId,
      [String redirectedOriginPath]) async {
    if (!_keycloakService.isInstanceInitiated(instanceId: instanceId)) {
      try {
        String redirectedOriginUrl;
        if (redirectedOriginPath != null) {
          redirectedOriginUrl =
              '${window.location.origin}/${_locationStrategy.prepareExternalUrl(redirectedOriginPath)}';
        }
        await _keycloakService.initWithProvidedConfig(
            instanceId: instanceId, redirectedOrigin: redirectedOriginUrl);
      } catch (e) {
        print('Error when initiating keycloak instance of $instanceId. $e');
        return false;
      }
    }
    return true;
  }

  bool _isAuthenticated(String instanceId) {
    return _keycloakService.isAuthenticated(instanceId: instanceId);
  }

  /// Combining for Realm roles and Client Roles. Check is all the [rolesAllowed]
  /// included in the combined list.
  bool _isAuthorized(String instanceId, List<String> rolesAllowed) {
    final realmRoles =
        _keycloakService.getRealmRoles(instanceId: instanceId).toSet();
    final resourceRoles =
        _keycloakService.getResourceRoles(instanceId: instanceId).toSet();
    final combinedRoles = realmRoles.union(resourceRoles);

    return combinedRoles.containsAll(rolesAllowed);
  }
}
