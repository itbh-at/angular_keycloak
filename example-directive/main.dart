import 'package:angular/angular.dart';

import 'package:angular_keycloak/angular_keycloak.dart';

import 'app/example_app_component.template.dart' as ng;
import 'main.template.dart' as self;

/// Example for using the [kcSecurity] structural directive.
///
/// Most of the important bits of this example is at the
/// `app/example_app_component.html` file.

@GenerateInjector([keycloakProviders])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.ExampleAppComponentNgFactory, createInjector: injector);
}
