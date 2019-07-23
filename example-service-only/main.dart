import 'package:angular/angular.dart';

import 'package:angular_keycloak/angular_keycloak.dart';

import 'app/example_app_component.template.dart' as ng;
import 'main.template.dart' as self;

/// Example for using Single Instance [KeycloakService]
///
/// All default setup, including loading 'keycloak.json' from the root.
/// Notice that `instanceId` is skipped in all method call. Since we using
/// only single instance, it is not needed as all.
///
/// [KeycloakService.init()] is called in the [ExampleAppComponent.ngOnInit()].
/// This will ensure it is the first thing getting call when the application startup.
/// When there is a token in the URL hash, it will be parse immediately.

@GenerateInjector([keycloakProviders])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.ExampleAppComponentNgFactory, createInjector: injector);
}
