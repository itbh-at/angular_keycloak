import 'dart:html' show window;
import 'dart:async' show FutureOr;

import 'package:angular/di.dart' show Injectable;
import 'package:angular_router/angular_router.dart';

import 'keycloak_service_impl.dart';
import 'secured_route.dart';

export 'secured_route.dart';

@Injectable()
class SecuredRouterHook implements RouterHook {
  final KeycloakService _keycloakService;
  final LocationStrategy _locationStrategy;
  final SecuredRouterHookConfig _config;

  final _redirectingRoutes = <SecuredRoute>[];
  final _blockingRoutes = <SecuredRoute>[];

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

  Future<String> navigationPath(String path, NavigationParams params) async {
    if (_locationStrategy is HashLocationStrategy) {
      var andPlace = path.indexOf('&');
      if (andPlace != -1) {
        path = path.substring(0, andPlace);
      }
    }
    for (final securedRoute in _redirectingRoutes) {
      for (final securingPath in securedRoute.paths) {
        final securedPath = securingPath.toUrl();
        if (_match(path, securedPath)) {
          if (await _verifyOrInitiateKeycloakInstance(
              securedRoute.keycloakInstanceId, path)) {
            if (!_isAuthenticated(securedRoute.keycloakInstanceId)) {
              final redirectedPathUrl = securedRoute.redirectPath.toUrl();
              _directedAwayOrigins[redirectedPathUrl] = path;
              return redirectedPathUrl;
            } else if (!securedRoute.authenticatingSetting &&
                !_isAuthorized(securedRoute.keycloakInstanceId,
                    securedRoute.authorizedRoles)) {
              return securedRoute.redirectPath.toUrl();
            }
          }
        }
      }
    }
    return path;
  }

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
            } else if (!securedRoute.authenticatingSetting &&
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

  bool _isAuthorized(String instanceId, List<String> rolesAllowed) {
    final realmRoles =
        _keycloakService.getRealmRoles(instanceId: instanceId).toSet();
    final resourceRoles =
        _keycloakService.getResourceRoles(instanceId: instanceId).toSet();
    final combinedRoles = realmRoles.union(resourceRoles);

    return combinedRoles.containsAll(rolesAllowed);
  }
}
