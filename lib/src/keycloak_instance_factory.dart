import 'package:keycloak/keycloak.dart';

class KeycloakInstanceFactory {
  KeycloakInstance create([String config]) {
    return KeycloakInstance(config);
  }
}
