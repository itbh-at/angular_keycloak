import 'package:angular_router/angular_router.dart' show RouteDefinition;

import 'public/about_component.template.dart' as about_template;

import 'route_paths.dart';

class Routes {
  static final about = RouteDefinition(
      routePath: RoutePaths.about,
      component: about_template.AboutComponentNgFactory,
      useAsDefault: true);

  static final all = [about];
}
