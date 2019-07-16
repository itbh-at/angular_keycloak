import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(selector: 'public', directives: [
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <div class="public container">
    <h2>Public Area</h2>
    <p>Anyone can come here.</p>

    <div>What do you want to do next?</div>
    <ul>
      <li>
        <div class="sub-nav">
          Stand in front of the 
          <a [routerLink]="RoutePaths.door.toUrl()">Door</a>
        </div>
      </li>

      <li>
        <div class="sub-nav">
          Look at the 
          <a [routerLink]="RoutePaths.window.toUrl()">Window</a>
        </div>
    </li>
    </ul>
    <router-outlet [routes]="Routes.all"></router-outlet>
  </div>
  ''')
class PublicComponent {}
