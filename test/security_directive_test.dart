import 'dart:html';

@TestOn('browser')
import 'package:angular/angular.dart';
import 'package:angular_test/angular_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:angular_keycloak/angular_keycloak.dart';

import 'security_directive_test.template.dart' as ng_generated;

void main() {
  ng_generated.initReflector();

  MockKeycloakService _mockKeycloakService;

  tearDown(disposeAnyRunningTest);

  group('Single instance', () {
    test('when authenticated', () async {
      final fixture = await NgTestBed<SingleInstanceAuthenticationComponent>()
          .addProviders([
        ClassProvider(KeycloakService, useClass: MockKeycloakService)
      ]).create(beforeComponentCreated: (injector) {
        _mockKeycloakService =
            injector.provideType(KeycloakService) as MockKeycloakService;

        when(_mockKeycloakService.isInstanceInitiated()).thenReturn(true);
        when(_mockKeycloakService.isAuthenticated()).thenReturn(true);
      });

      final paragraph =
          fixture.rootElement.querySelector('p') as ParagraphElement;
      expect(paragraph.text, 'authenticated');
    });

    test('when denied', () async {
      final fixture = await NgTestBed<SingleInstanceAuthenticationComponent>()
          .addProviders([
        ClassProvider(KeycloakService, useClass: MockKeycloakService)
      ]).create(beforeComponentCreated: (injector) {
        _mockKeycloakService =
            injector.provideType(KeycloakService) as MockKeycloakService;

        when(_mockKeycloakService.isInstanceInitiated()).thenReturn(true);
        when(_mockKeycloakService.isAuthenticated()).thenReturn(false);
      });

      final paragraph =
          fixture.rootElement.querySelector('p') as ParagraphElement;
      expect(paragraph.text, 'denied');
    });
  });

  group('Multiple Instance', () {
    test('Only show the one authenticated', () async {
      final fixture = await NgTestBed<MultipleInstanceAuthenticationComponent>()
          .addProviders([
        ClassProvider(KeycloakService, useClass: MockKeycloakService)
      ]).create(beforeComponentCreated: (injector) {
        _mockKeycloakService =
            injector.provideType(KeycloakService) as MockKeycloakService;

        when(_mockKeycloakService.isInstanceInitiated(instanceId: 'employee'))
            .thenReturn(true);
        when(_mockKeycloakService.isAuthenticated(instanceId: 'employee'))
            .thenReturn(true);
        when(_mockKeycloakService.isInstanceInitiated(instanceId: 'customer'))
            .thenReturn(false);
      });

      final paragraph =
          fixture.rootElement.querySelector('p') as ParagraphElement;
      expect(paragraph.text, 'employee authenticated');
    });
  });

  group('Authorization', () {
    test('not seeing anything when does not has the right roles', () async {
      final fixture = await NgTestBed<RoleAuthorizationComponent>()
          .addProviders([
        ClassProvider(KeycloakService, useClass: MockKeycloakService)
      ]).create(beforeComponentCreated: (injector) {
        _mockKeycloakService =
            injector.provideType(KeycloakService) as MockKeycloakService;

        when(_mockKeycloakService.isInstanceInitiated()).thenReturn(true);
        when(_mockKeycloakService.isAuthenticated()).thenReturn(true);
        when(_mockKeycloakService.getRealmRoles()).thenReturn([]);
        when(_mockKeycloakService.getResourceRoles()).thenReturn(['member']);
      });

      final paragraph =
          fixture.rootElement.querySelector('p') as ParagraphElement;
      expect(paragraph, isNull);
    });

    test('see only element that match the role', () async {
      final fixture = await NgTestBed<RoleAuthorizationComponent>()
          .addProviders([
        ClassProvider(KeycloakService, useClass: MockKeycloakService)
      ]).create(beforeComponentCreated: (injector) {
        _mockKeycloakService =
            injector.provideType(KeycloakService) as MockKeycloakService;

        when(_mockKeycloakService.isInstanceInitiated()).thenReturn(true);
        when(_mockKeycloakService.isAuthenticated()).thenReturn(true);
        when(_mockKeycloakService.getRealmRoles()).thenReturn([]);
        when(_mockKeycloakService.getResourceRoles()).thenReturn(['boss']);
      });

      final paragraph =
          fixture.rootElement.querySelector('p') as ParagraphElement;
      expect(paragraph.text, 'the boss');
    });

    test('has full access when having the full-role', () async {
      final fixture = await NgTestBed<RoleAuthorizationComponent>()
          .addProviders([
        ClassProvider(KeycloakService, useClass: MockKeycloakService)
      ]).create(beforeComponentCreated: (injector) {
        _mockKeycloakService =
            injector.provideType(KeycloakService) as MockKeycloakService;

        when(_mockKeycloakService.isInstanceInitiated()).thenReturn(true);
        when(_mockKeycloakService.isAuthenticated()).thenReturn(true);
        when(_mockKeycloakService.getRealmRoles()).thenReturn([]);
        when(_mockKeycloakService.getResourceRoles())
            .thenReturn(['reader', 'writer']);
      });

      final paragraph =
          fixture.rootElement.querySelector('p') as ParagraphElement;
      expect(paragraph.text, 'can read; can write');
    });

    test('has readonly flagged when having the readonly-role', () async {
      final fixture = await NgTestBed<RoleAuthorizationComponent>()
          .addProviders([
        ClassProvider(KeycloakService, useClass: MockKeycloakService)
      ]).create(beforeComponentCreated: (injector) {
        _mockKeycloakService =
            injector.provideType(KeycloakService) as MockKeycloakService;

        when(_mockKeycloakService.isInstanceInitiated()).thenReturn(true);
        when(_mockKeycloakService.isAuthenticated()).thenReturn(true);
        when(_mockKeycloakService.getRealmRoles()).thenReturn([]);
        when(_mockKeycloakService.getResourceRoles()).thenReturn(['reader']);
      });

      final paragraph =
          fixture.rootElement.querySelector('p') as ParagraphElement;
      expect(paragraph.text, 'can read; cannot write');
    });
  });
}

@Component(selector: 'test-security', directives: [KcSecurity], template: '''
  <p *kcSecurity>authenticated</p>
  <p *kcSecurity="showWhenDenied: true">denied</p>
  ''')
class SingleInstanceAuthenticationComponent {}

@Component(selector: 'test-security', directives: [KcSecurity], template: '''
  <p *kcSecurity="'employee'">employee authenticated</p>
  <p *kcSecurity="'customer'">customer authenticated</p>
  ''')
class MultipleInstanceAuthenticationComponent {}

@Component(selector: 'test-security', directives: [KcSecurity], template: '''
  <p *kcSecurity="roles:['boss']">the boss</p>
  <p *kcSecurity="roles:['reader', 'writer']; 
                  readonlyRoles:['reader']; 
                  let ro=readonly">
    can read; {{ro ? 'cannot' : 'can'}} write
  </p>
  ''')
class RoleAuthorizationComponent {}

@Injectable()
class MockKeycloakService extends Mock implements KeycloakService {}
