import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(selector: 'kitchen', directives: [
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <div class="employee container">
    <h3>Kitchen</h3>
    <p>10 risotto orders pending!</p>

    <div>What do you want to do next?</div>
    <ul><li>
      <div class="sub-nav">
      Open up the 
      <a [routerLink]="RoutePaths.cashier.toUrl()">Cashier</a>
      </div>
    </li></ul>

    <router-outlet [routes]="Routes.fromKitchen">
    </router-outlet>
  </div>
  ''')
class KitchenComponent {}
