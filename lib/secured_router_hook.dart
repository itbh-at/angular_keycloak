import 'dart:async' show FutureOr;

import 'package:angular/di.dart';
import 'package:angular_keycloak/keycloak_service.dart';
import 'package:angular_router/angular_router.dart';

class SecuredRoute {
  String keycloakInstanceId;
  List<RoutePath> paths;
  List<String> authorizedRoles;
  RoutePath redirectPath;
  bool authenticatingSetting;

  SecuredRoute.authentication(
      {this.keycloakInstanceId, this.paths, this.redirectPath})
      : authenticatingSetting = true;
  SecuredRoute.authorization(
      {this.keycloakInstanceId,
      this.paths,
      this.authorizedRoles,
      this.redirectPath})
      : authenticatingSetting = false;
}

class SecuredRouterHookConfig {
  final settings = List<SecuredRoute>();
}

@Injectable()
class SecuredRouterHook implements RouterHook {
  final KeycloakService _keycloakService;
  final LocationStrategy _locationStrategy;
  final SecuredRouterHookConfig _setting;

  final _redirectingSetting = <SecuredRoute>[];
  final _blockingSetting = <SecuredRoute>[];

  SecuredRouterHook(
      this._keycloakService, this._locationStrategy, this._setting) {
    for (final setting in _setting.settings) {
      if (setting.redirectPath != null) {
        _redirectingSetting.add(setting);
      } else {
        _blockingSetting.add(setting);
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
    for (final setting in _redirectingSetting) {
      for (final securingPath in setting.paths) {
        final securedPath = securingPath.toUrl();
        if (_match(path, securedPath)) {
          if (await _verifyOrInitiateKeycloakInstance(
              setting.keycloakInstanceId)) {
            if (!_isAuthenticated(setting.keycloakInstanceId)) {
              return setting.redirectPath.toUrl();
            } else if (!setting.authenticatingSetting &&
                !_isAuthorized(
                    setting.keycloakInstanceId, setting.authorizedRoles)) {
              return setting.redirectPath.toUrl();
            }
          }
        }
      }
    }
    return path;
  }

  Future<NavigationParams> navigationParams(
      String path, NavigationParams params) async {
    // Provided as a default if someone extends or mixes-in this interface.
    return params;
  }

  Future<bool> canActivate(Object componentInstance, RouterState oldState,
      RouterState newState) async {
    final path = newState.path;
    for (final setting in _blockingSetting) {
      for (final securingPath in setting.paths) {
        final securedPath = securingPath.toUrl();
        if (_match(path, securedPath)) {
          if (await _verifyOrInitiateKeycloakInstance(
              setting.keycloakInstanceId)) {
            if (!_isAuthenticated(setting.keycloakInstanceId)) {
              return false;
            } else if (!setting.authenticatingSetting &&
                !_isAuthorized(
                    setting.keycloakInstanceId, setting.authorizedRoles)) {
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

  FutureOr _verifyOrInitiateKeycloakInstance(String instanceId) async {
    if (!_keycloakService.isInstanceInitiated(instanceId: instanceId)) {
      try {
        await _keycloakService.initInstance(instanceId: instanceId);
      } catch (e) {
        print('Error when initiating keycloak instance of $instanceId. $e');
        return false;
      }
    }
    return true;
  }

  bool _isAuthenticated(String instanceId) {
    return _keycloakService.isAuthenticated(id: instanceId);
  }

  bool _isAuthorized(String instanceId, List<String> rolesAllowed) {
    final realmRoles = _keycloakService.getRealmRoles(id: instanceId).toSet();
    final resourceRoles =
        _keycloakService.getResourceRoles(id: instanceId).toSet();
    final combinedRoles = realmRoles.union(resourceRoles);

    return combinedRoles.containsAll(rolesAllowed);
  }
}
