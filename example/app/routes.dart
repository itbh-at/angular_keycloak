import 'package:angular_router/angular_router.dart' show RouteDefinition;

import 'customer/customer_component.template.dart' as customer_template;
import 'employee/employee_component.template.dart' as employee_template;
import 'public/public_component.template.dart' as public_template;
import 'customer_login_component.template.dart' as customer_login_template;
import 'employee_login_component.template.dart' as employee_login_template;
import 'unauthorized_component.template.dart' as unauthorized_template;

import 'route_paths.dart';
export 'route_paths.dart';

class Routes {
  static final customer = RouteDefinition(
      routePath: RoutePaths.customer,
      component: customer_template.CustomerComponentNgFactory);

  static final customerLogin = RouteDefinition(
      routePath: RoutePaths.customerLogin,
      component: customer_login_template.CustomerLoginComponentNgFactory);

  static final employee = RouteDefinition(
      routePath: RoutePaths.employee,
      component: employee_template.EmployeeComponentNgFactory);

  static final employeeLogin = RouteDefinition(
      routePath: RoutePaths.employeeLogin,
      component: employee_login_template.EmployeeLoginComponentNgFactory);

  static final public = RouteDefinition(
      routePath: RoutePaths.public,
      component: public_template.PublicComponentNgFactory);

  static final unauthorized = RouteDefinition(
      routePath: RoutePaths.unauthorized,
      component: unauthorized_template.UnauthorizedComponentNgFactory);

  static final all = [
    customer,
    customerLogin,
    employee,
    employeeLogin,
    public,
    unauthorized
  ];
}
