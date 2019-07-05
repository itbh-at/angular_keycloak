import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(selector: 'employee', directives: [
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <h1>Employee Area</h1>
  <p>Only employee can come here.</p>

  <div class="sub-nav">
  <a [routerLink]="RoutePaths.kitchen.toUrl()">Kitchen</a>
  </div>
  <router-outlet [routes]="Routes.all">
  </router-outlet>
  ''')
class EmployeeComponent {}
