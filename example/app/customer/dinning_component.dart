import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(selector: 'dinning', directives: [
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <h2>Dinning area</h2>
  <p>Customer only</p>

  <div class="sub-nav">
  <a [routerLink]="RoutePaths.washroom.toUrl()">Washroom</a>
  </div>
  <router-outlet [routes]="Routes.all">
  </router-outlet>
  ''')
class DinningComponent {}
