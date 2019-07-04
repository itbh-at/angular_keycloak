import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(selector: 'public', directives: [
  routerDirectives,
], exports: [
  Routes,
  RoutePaths
], template: '''
  <h1>Public Area</h1>
  <p>Anyone can come here.</p>

  <div class="sub-nav">
  <a [routerLink]="RoutePaths.door.toUrl()">Door</a>
  <a [routerLink]="RoutePaths.window.toUrl()">Window</a>
  </div>
  <router-outlet [routes]="Routes.all"></router-outlet>
  ''')
class PublicComponent extends Component {}
