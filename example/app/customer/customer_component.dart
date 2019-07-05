import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(selector: 'customer', directives: [
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <h1>Customer Area</h1>
  <p>Only customer can come here.</p>

  <div class="sub-nav">
  <a [routerLink]="RoutePaths.dinning.toUrl()">Dinning</a>
  <a [routerLink]="RoutePaths.vip.toUrl()">VIP Room</a>
  </div>
  <router-outlet [routes]="Routes.all"></router-outlet>
  ''')
class CustomerComponent {}
