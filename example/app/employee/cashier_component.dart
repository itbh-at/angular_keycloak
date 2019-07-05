import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(selector: 'cashier', directives: [
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <h2>The Cash Machine</h2>
  <p>Supervisor only</p>

  <div class="sub-nav">
  <a [routerLink]="RoutePaths.bossRoom.toUrl()">Boss Room</a>
  </div>
  <router-outlet [routes]="Routes.all">
  </router-outlet>
  ''')
class CashierComponent extends Component {}
