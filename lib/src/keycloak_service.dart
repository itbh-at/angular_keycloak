import 'js_interop/keycloak.dart';
import 'js_interop/promise.dart';

class KeycloakService {
  KeycloakInstance<Promise> _keycloakInstance;

  KeycloakService([config]) {
    _keycloakInstance = Keycloak(config);
  }

  Future init() async {
    await promiseToFuture(
        _keycloakInstance.init(KeycloakInitOptions(promiseType: 'native')));

    print('authenticated? ${_keycloakInstance.authenticated}');
    print('loginRequired? ${_keycloakInstance.loginRequired}');
    print('realm? ${_keycloakInstance.realm}');
    return;
  }

  Future login([KeycloakLoginOptions options]) async {
    return promiseToFuture(_keycloakInstance.login(options));
  }
}
