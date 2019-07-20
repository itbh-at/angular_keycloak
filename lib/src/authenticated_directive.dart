import 'package:angular/angular.dart';

import 'keycloak_service.dart';

@Directive(
  selector: '[authenticated]',
)
class AuthenticatedDirective implements DoCheck {
  final KeycloakService _keycloakService;
  final TemplateRef _templateRef;
  final ViewContainerRef _viewContainer;

  String _instanceId;
  bool _hasView = false;
  bool showIfAuthenticate = true;

  @Input('authenticated')
  set instanceId(String instanceId) {
    _instanceId = instanceId.isNotEmpty ? instanceId : null;
  }

  AuthenticatedDirective(
      this._keycloakService, this._templateRef, this._viewContainer);

  @override
  void ngDoCheck() {
    if (!_hasView) {
      final show =
          (_keycloakService.isInstanceInitiated(instanceId: _instanceId) &&
                  _keycloakService.isAuthenticated(instanceId: _instanceId)) ==
              showIfAuthenticate;
      if (show) {
        _viewContainer.createEmbeddedView(_templateRef);
      } else {
        _viewContainer.clear();
      }
      _hasView = true;
    }
  }
}

@Directive(
  selector: '[notAuthenticated]',
)
class NotAuthenticatedDirective extends AuthenticatedDirective {
  NotAuthenticatedDirective(KeycloakService keycloakService,
      TemplateRef templateRef, ViewContainerRef viewContainer)
      : super(keycloakService, templateRef, viewContainer) {
    showIfAuthenticate = false;
  }

  @Input('notAuthenticated')
  set instanceId_(String instanceId) {
    super.instanceId = instanceId;
  }
}
