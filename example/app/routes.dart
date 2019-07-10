// This file is part of AngularKeycloak
//
// AngularKeycloak is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published by the
// Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

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
