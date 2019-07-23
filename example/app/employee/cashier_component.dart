import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(selector: 'cashier', directives: [
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <div class="employee container">
    <h4>The Cash Machine</h4>
    <p>Money money money.</p>

    <div>What do you want to do next?</div>
    <ul><li>
      <div class="sub-nav">
      Be the 
      <a [routerLink]="RoutePaths.bossRoom.toUrl()">Boss</a>
      </div>
    </li></ul>
    
    <router-outlet [routes]="Routes.fromCashier">
    </router-outlet>
  </div>
  ''')
class CashierComponent {}
