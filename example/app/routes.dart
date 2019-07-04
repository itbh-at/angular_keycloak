import 'package:angular_router/angular_router.dart' show RouteDefinition;

import 'customer/dinning_component.template.dart' as dinning_template;
import 'public/about_component.template.dart' as about_template;

import 'route_paths.dart';
export 'route_paths.dart';

class Routes {
  static final about = RouteDefinition(
      routePath: RoutePaths.about,
      component: about_template.AboutComponentNgFactory);

  static final dinning = RouteDefinition(
      routePath: RoutePaths.dinning,
      component: dinning_template.DinningComponentNgFactory);

  static final all = [about, dinning];
}
