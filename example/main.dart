import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/angular_keycloak.dart';

import 'app/example_app_component.template.dart' as ng;
import 'app/providers.dart';
import 'main.template.dart' as self;

@GenerateInjector([
  FactoryProvider(KeycloackServiceConfig, keycloakConfigFactory),
  FactoryProvider(SecuredRouterHookConfig, securedRouterHookConfigFactory),
  keycloakProviders,
  ClassProvider(RouterHook, useClass: SecuredRouterHook),
  routerProvidersHash, // You can use routerProviders in production
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.ExampleAppComponentNgFactory, createInjector: injector);
}
