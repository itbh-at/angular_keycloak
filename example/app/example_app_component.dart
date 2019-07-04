import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart'
    show Router, routerDirectives;
import 'package:angular_components/laminate/popup/module.dart';
import 'package:angular_components/material_button/material_button.dart';

import 'package:angular_keycloak/keycloak_service.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(
  selector: 'my-app',
  directives: [
    MaterialButtonComponent,
    routerDirectives,
  ],
  exports: [Routes, RoutePaths],
  //Blanket provider for all kind of Angular Component. VERY BAD. But too lazy to find the right one for each component.
  providers: [popupBindings],
  template: '''
  <h1>Keycloak Service Example</h1>
  <material-button (trigger)="(login)">Login</material-button>
  <a [routerLink]="RoutePaths.customer.toUrl()">Customer</a>
  <a [routerLink]="RoutePaths.employee.toUrl()">Employee</a>
  <a [routerLink]="RoutePaths.public.toUrl()">Public</a>

  <router-outlet [routes]="Routes.all"></router-outlet>
''',
)
class ExampleAppComponent {
  final KeycloakService _keycloakService;

  ExampleAppComponent(this._keycloakService);

  void login() async {
    _keycloakService.login();
  }
}
