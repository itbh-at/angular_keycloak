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

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_keycloak/secured_router_hook.dart';
import 'package:angular_keycloak/keycloak_service.dart';

import 'app/example_app_component.template.dart' as ng;
import 'app/providers.dart';
import 'main.template.dart' as self;

@GenerateInjector([
  FactoryProvider(KeycloackServiceConfig, keycloakConfigFactory),
  FactoryProvider(SecuredRouterHookConfig, hookSettingFactory),
  ClassProvider(KeycloakService),
  ClassProvider(RouterHook, useClass: SecuredRouterHook),
  routerProvidersHash, // You can use routerProviders in production
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.ExampleAppComponentNgFactory, createInjector: injector);
}
