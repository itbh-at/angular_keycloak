import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart' show routerDirectives;
import 'package:angular_components/laminate/popup/module.dart';

import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(
  selector: 'my-app',
  directives: [
    routerDirectives,
  ],
  exports: [Routes, RoutePaths],
  providers: [popupBindings],
  template: '''
  <div class="main">
    <h1>Keycloak Service Example</h1>
    <a [routerLink]="RoutePaths.customer.toUrl()">Customer</a>
    <a [routerLink]="RoutePaths.employee.toUrl()">Employee</a>
    <a [routerLink]="RoutePaths.public.toUrl()">Public</a>

    <router-outlet [routes]="Routes.all"></router-outlet>
  </div>
''',
)
class ExampleAppComponent {}
