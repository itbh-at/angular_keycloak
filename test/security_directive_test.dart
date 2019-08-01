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
      final fixture = await NgTestBed<TestSecurityAuthenticationComponent>()
          .addProviders([
        ClassProvider(KeycloakService, useClass: MockKeycloakService)
      ]).create(beforeComponentCreated: (injector) {
        _mockKeycloakService =
            injector.provideType(KeycloakService) as MockKeycloakService;

        when(_mockKeycloakService.isInstanceInitiated(
                instanceId: anyNamed('instanceId')))
            .thenReturn(true);
        when(_mockKeycloakService.isAuthenticated(
                instanceId: anyNamed('instanceId')))
            .thenReturn(true);
      });

      final text = fixture.rootElement.querySelector('p') as ParagraphElement;
      expect(text.text, 'authenticated');
    });

    test('when denied', () async {
      final fixture = await NgTestBed<TestSecurityAuthenticationComponent>()
          .addProviders([
        ClassProvider(KeycloakService, useClass: MockKeycloakService)
      ]).create(beforeComponentCreated: (injector) {
        _mockKeycloakService =
            injector.provideType(KeycloakService) as MockKeycloakService;

        when(_mockKeycloakService.isInstanceInitiated(
                instanceId: anyNamed('instanceId')))
            .thenReturn(true);
        when(_mockKeycloakService.isAuthenticated(
                instanceId: anyNamed('instanceId')))
            .thenReturn(false);
      });

      final text = fixture.rootElement.querySelector('p') as ParagraphElement;
      expect(text.text, 'denied');
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

      final text = fixture.rootElement.querySelector('p') as ParagraphElement;
      expect(text.text, 'employee authenticated');
    });
  });
}

@Component(selector: 'test-security', directives: [KcSecurity], template: '''
  <p *kcSecurity>authenticated</p>
  <p *kcSecurity="showWhenDenied: true">denied</p>
  ''')
class TestSecurityAuthenticationComponent {}

@Component(selector: 'test-security', directives: [KcSecurity], template: '''
  <p *kcSecurity="'employee'">employee authenticated</p>
  <p *kcSecurity="'customer'">customer authenticated</p>
  ''')
class MultipleInstanceAuthenticationComponent {}

@Injectable()
class MockKeycloakService extends Mock implements KeycloakService {}
