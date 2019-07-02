import 'package:angular/angular.dart';
import 'package:angular_components/laminate/popup/module.dart';
import 'package:angular_components/material_button/material_button.dart';

import 'package:angular_keycloak/keycloak_service.dart';

@Component(
  selector: 'my-app',
  directives: [MaterialButtonComponent],
  //Blanket provider for all kind of Angular Component. VERY BAD. But too lazy to find the right one for each component.
  providers: [popupBindings, ClassProvider(KeycloakService)],
  template: '''
    <h1>Keycloak Service Example</h1>
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
}
