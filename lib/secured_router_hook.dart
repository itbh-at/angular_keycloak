import 'package:angular/di.dart';
import 'package:angular_keycloak/keycloak_service.dart';
import 'package:angular_router/angular_router.dart';

class SecureRouteSetting {
  String keycloakInstanceId;
  final paths = List<RoutePath>();
  final roles = Set<String>();
  RoutePath redirectPath;
}

class SecuredRouterHookSetting {
  final settings = List<SecureRouteSetting>();
}

@Injectable()
class SecuredRouterHook implements RouterHook {
  final KeycloakService _keycloakService;
  final LocationStrategy _locationStrategy;
  final SecuredRouterHookSetting _setting;

  SecuredRouterHook(
      this._keycloakService, this._locationStrategy, this._setting);

  Future<String> navigationPath(String path, NavigationParams params) async {
    print('secruing path $path');
    if (_locationStrategy is HashLocationStrategy) {
      var andPlace = path.indexOf('&');
      if (andPlace != -1) {
        path = path.substring(0, andPlace);
      }
    }
    for (final setting in _setting.settings) {
      for (final securingPath in setting.paths) {
        final url = securingPath.toUrl();
        print('url is $url');
        if (url == path) {
          final authorized = await _keycloakService.authenticateAndAuthorize(
              id: setting.keycloakInstanceId, roles: setting.roles);
          if (authorized) {
            print('authenticated for ${setting.keycloakInstanceId}');
          } else {
            print('not authendticated for ${setting.keycloakInstanceId}');
            return setting.redirectPath.toUrl();
          }
        }
      }
    }
    print(
        'secured path $path, keycloak is ${_keycloakService.isAuthenticated()}');
    return path;
  }

  Future<NavigationParams> navigationParams(
      String path, NavigationParams params) async {
    // Provided as a default if someone extends or mixes-in this interface.
    return params;
  }

  Future<bool> canActivate(Object componentInstance, RouterState oldState,
      RouterState newState) async {
    // Provided as a default if someone extends or mixes-in this interface.
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
}
