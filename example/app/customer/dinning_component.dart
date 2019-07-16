import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(selector: 'dinning', directives: [
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <div class="customer container">
    <h3>Dinning area</h3>
    <p>We served the best Risotto</p>

    <div>What do you want to do next?</div>
    <ul><li>
      <div class="sub-nav">
      Visit the 
      <a [routerLink]="RoutePaths.washroom.toUrl()">Washroom</a>
      </div>
    </li></ul>

    <router-outlet [routes]="Routes.all">
    </router-outlet>
  </div>
  ''')
class DinningComponent {}
