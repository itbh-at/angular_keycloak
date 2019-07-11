import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart' show routerDirectives;
import 'package:angular_components/laminate/popup/module.dart';

import 'package:angular_keycloak/angular_keycloak.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(
  selector: 'my-app',
  directives: [
    routerDirectives,
  ],
  exports: [Routes, RoutePaths],
  //Blanket provider for all kind of Angular Component. VERY BAD. But too lazy to find the right one for each component.
  providers: [popupBindings],
  template: '''
  <h1>Keycloak Service Example</h1>
  <a [routerLink]="RoutePaths.customer.toUrl()">Customer</a>
  <a [routerLink]="RoutePaths.employee.toUrl()">Employee</a>
  <a [routerLink]="RoutePaths.public.toUrl()">Public</a>

  <router-outlet [routes]="Routes.all"></router-outlet>
''',
)
class ExampleAppComponent {
  final KeycloakService _keycloakService;

  ExampleAppComponent(this._keycloakService);

  void logoutCustomer() async {
    _keycloakService.logout(instanceId: 'customer');
  }
}
