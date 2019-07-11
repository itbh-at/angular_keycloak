import 'package:angular/angular.dart';

import 'keycloak_service.dart';
import 'keycloak_service_impl.dart';

const keycloakProviders = [
  ClassProvider(KeycloakService, useClass: KeycloakServiceImpl),
];

const keycloakModule = Module(provide: keycloakProviders);
