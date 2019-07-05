import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(selector: 'kitchen', directives: [
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <h2>Kitchen</h2>
  <p>Staff only</p>

  <div class="sub-nav">
  <a [routerLink]="RoutePaths.cashier.toUrl()">Cashier</a>
  </div>
  <router-outlet [routes]="Routes.all">
  </router-outlet>
  ''')
class KitchenComponent extends Component {}
