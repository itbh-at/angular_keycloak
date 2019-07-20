import 'package:angular/angular.dart';

import 'package:angular_keycloak/angular_keycloak.dart';

import 'app/example_app_component.template.dart' as ng;
import 'main.template.dart' as self;

//TODO Description

@GenerateInjector([keycloakProviders])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.ExampleAppComponentNgFactory, createInjector: injector);
}
