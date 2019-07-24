import 'package:angular/angular.dart';

import 'keycloak_instance_factory.dart';
import 'keycloak_service.dart';
import 'keycloak_service_impl.dart';

/// The main [KeycloakService] providers.
///
/// The [keycloakProviders] should be added to the app's root injector.
/// ```
/// @GenerateInjector([keycloakProviders])
/// final InjectorFactory injector = self.injector$Injector;
/// ...
/// runApp(ng.MyAppComponentNgFactory, createInjector: injector);
/// ```
const keycloakProviders = [
  ClassProvider(KeycloakInstanceFactory),
  ClassProvider(KeycloakService, useClass: KeycloakServiceImpl),
];
