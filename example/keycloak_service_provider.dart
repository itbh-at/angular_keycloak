import 'package:angular/angular.dart';
import 'package:keycloak_dart/keycloak.dart';

KeycloakService keycloakServiceFactory() {
  //return KeycloakService('keycloak_beta.json');
  KeycloakService.parameters({
    "realm": "demo",
    "auth-server-url": "http://localhost:8080/auth",
    "resource": "angulardart_alpha",
  });
}

const keycloakServiceProvider =
    FactoryProvider(KeycloakService, keycloakServiceFactory);
