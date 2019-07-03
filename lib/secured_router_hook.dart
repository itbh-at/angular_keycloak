import 'package:angular/di.dart';
import 'package:angular_keycloak/keycloak_service.dart';
import 'package:angular_router/angular_router.dart';

@Injectable()
class SecuredRouterHook implements RouterHook {
  final KeycloakService _keycloakService;

  SecuredRouterHook(this._keycloakService);

  Future<String> navigationPath(String path, NavigationParams params) async {
    print('secruing path $path');
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
