import 'js_interop/keycloak.dart';
import 'js_interop/promise.dart';

class KeycloakService {
  KeycloakInstance<Promise> _keycloakInstance;

  bool get isAuthenticated => _keycloakInstance.authenticated;

  String get authServerUrl => _keycloakInstance.authServerUrl;
  String get clientId => _keycloakInstance.clientId;
  String get realm => _keycloakInstance.realm;

  KeycloakService([config]) {
    _keycloakInstance = Keycloak(config);
  }

  Future init() async {
    return promiseToFuture(
        _keycloakInstance.init(KeycloakInitOptions(promiseType: 'native')));
  }

  Future login([KeycloakLoginOptions options]) async {
    return promiseToFuture(_keycloakInstance.login(options));
  }

  Future logout() async {
    return promiseToFuture(_keycloakInstance.logout());
  }
}
