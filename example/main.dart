import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/secured_router_hook.dart';
import 'package:angular_keycloak/keycloak_service.dart';

import 'app/example_app_component.template.dart' as ng;
import 'main.template.dart' as self;

@GenerateInjector([
  ClassProvider(KeycloakService),
  ClassProvider(RouterHook, useClass: SecuredRouterHook),
  routerProviders, // You can use routerProviders in production
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.ExampleAppComponentNgFactory, createInjector: injector);
}
