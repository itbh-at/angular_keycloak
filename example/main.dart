import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/angular_keycloak.dart';

import 'app/example_app_component.template.dart' as ng;
import 'app/providers.dart';
import 'main.template.dart' as self;

/// Example of using [KeycloakService] with  Multiple configs and [SecuredRouterHook].
///
/// We inject the configs with [FactoryProvider], and defined them in `app/providers.dart`.

@GenerateInjector([
  FactoryProvider(KeycloackServiceConfig, keycloakConfigFactory),
  FactoryProvider(SecuredRouterHookConfig, securedRouterHookConfigFactory),
  keycloakProviders,
  ClassProvider(RouterHook, useClass: SecuredRouterHook),
  ValueProvider.forToken(appBaseHref, '/'),
  routerProviders, // You can use routerProviders in production
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.ExampleAppComponentNgFactory, createInjector: injector);
}
