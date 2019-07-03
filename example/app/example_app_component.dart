import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart'
    show Router, routerDirectives;
import 'package:angular_components/laminate/popup/module.dart';
import 'package:angular_components/material_button/material_button.dart';

import 'package:angular_keycloak/keycloak_service.dart';

import 'routes.dart';

@Component(
  selector: 'my-app',
  directives: [
    MaterialButtonComponent,
    routerDirectives,
  ],
  exports: [Routes],
  //Blanket provider for all kind of Angular Component. VERY BAD. But too lazy to find the right one for each component.
  providers: [popupBindings],
  template: '''
    <h1>Keycloak Service Example</h1>
    <router-outlet [routes]="Routes.all"></router-outlet>
    <material-button (trigger)="login">Login</material-button>
  ''',
)
class ExampleAppComponent implements OnInit {
  final KeycloakService _keycloakService;

  ExampleAppComponent(this._keycloakService);

  @override
  void ngOnInit() async {
    await _keycloakService.registerInstance(
        loadType: InitLoadType.loginRequired);

    print('keycloack is ${_keycloakService.isAuthenticated()}');
  }

  void login() async {
    _keycloakService.login();
  }
}
