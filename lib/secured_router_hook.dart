// This file is part of AngularKeycloak
//
// AngularKeycloak is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published by the
// Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

import 'dart:html' show window;
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

  final _directedAwayOrigins = <String, String>{};

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
              setting.keycloakInstanceId, path)) {
            if (!_isAuthenticated(setting.keycloakInstanceId)) {
              final redirectedPathUrl = setting.redirectPath.toUrl();
              _directedAwayOrigins[redirectedPathUrl] = path;
              return redirectedPathUrl;
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

  FutureOr _verifyOrInitiateKeycloakInstance(String instanceId,
      [String redirectedOriginPath]) async {
    if (!_keycloakService.isInstanceInitiated(instanceId: instanceId)) {
      try {
        String redirectedOriginUrl;
        if (redirectedOriginPath != null) {
          redirectedOriginUrl =
              '${window.location.origin}/${_locationStrategy.prepareExternalUrl(redirectedOriginPath)}';
        }
        await _keycloakService.initWithId(
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
