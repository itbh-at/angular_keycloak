import 'package:angular_router/angular_router.dart' show RouteDefinition;

import 'customer/customer_component.template.dart' as customer_template;
import 'employee/employee_component.template.dart' as employee_template;
import 'public/public_component.template.dart' as public_template;

import 'route_paths.dart';
export 'route_paths.dart';

class Routes {
  static final customer = RouteDefinition(
      routePath: RoutePaths.customer,
      component: customer_template.CustomerComponentNgFactory);

  static final employee = RouteDefinition(
      routePath: RoutePaths.employee,
      component: employee_template.EmployeeComponentNgFactory);

  static final public = RouteDefinition(
      routePath: RoutePaths.public,
      component: public_template.PublicComponentNgFactory);

  static final all = [customer, employee, public];
}
