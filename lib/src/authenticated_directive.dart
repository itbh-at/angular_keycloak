import 'package:angular/angular.dart';

import 'keycloak_service.dart';

/// Causes an element and its contents to be conditionally added/removed from
/// the DOM based on the authentication status with [KeycloakService].
///
/// Instance ID of specific [KeycloakInstance] can be provided,
/// of leave blank for single instance usage.
///
/// Following example show how to show a <p> element when authenticated.
///
/// ```'html'
/// <p *authenticated>Welcome!</p>
/// ```
///
/// Following example show how to show a <div> element when authenticated
/// with a specific instance via a getter function.
///
/// ```'html
/// <div *authenticated="getInstanceId">User Only</div>
/// ```
@Directive(
  selector: '[authenticated]',
)
class AuthenticatedDirective implements DoCheck {
  final KeycloakService _keycloakService;
  final TemplateRef _templateRef;
  final ViewContainerRef _viewContainer;

  String _instanceId;
  bool _checked = false;
  bool showIfAuthenticate = true;

  @Input('authenticated')
  set instanceId(String instanceId) {
    // It seems that @Input never pass in a `null` String, even given one.
    // It will always became an empty String.
    _instanceId = instanceId.isNotEmpty ? instanceId : null;
  }

  AuthenticatedDirective(
      this._keycloakService, this._templateRef, this._viewContainer);

  @override
  void ngDoCheck() {
    if (!_checked) {
      final show =
          (_keycloakService.isInstanceInitiated(instanceId: _instanceId) &&
                  _keycloakService.isAuthenticated(instanceId: _instanceId)) ==
              showIfAuthenticate;
      if (show) {
        _viewContainer.createEmbeddedView(_templateRef);
      } else {
        _viewContainer.clear();
      }
      _checked = true;
    }
  }
}

/// The opposite of [AuthenticatedDirective], this hide the element when
/// [KeycloakService] is not authenticated.
@Directive(
  selector: '[notAuthenticated]',
)
class NotAuthenticatedDirective extends AuthenticatedDirective {
  NotAuthenticatedDirective(KeycloakService keycloakService,
      TemplateRef templateRef, ViewContainerRef viewContainer)
      : super(keycloakService, templateRef, viewContainer) {
    showIfAuthenticate = false;
  }

  @Input()
  set notAuthenticated(String instanceId) {
    super.instanceId = instanceId;
  }
}
