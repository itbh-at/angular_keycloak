import 'package:angular/angular.dart';

import 'keycloak_service.dart';

@Directive(
  selector: '[authorized]',
)
class AuthorizedDirective implements DoCheck {
  final KeycloakService _keycloakService;
  final TemplateRef _templateRef;
  final ViewContainerRef _viewContainer;

  String _instanceId;
  List<String> _readOnlyRoles;
  List<String> _writeRoles;
  bool _checked = false;

  AuthorizedDirective(
      this._keycloakService, this._templateRef, this._viewContainer);

  @Input()
  set authorized(String instanceId) {
    print('setting instanceId $instanceId');
    _instanceId = instanceId.isNotEmpty ? instanceId : null;
  }

  @Input()
  set authorizedRead(List<String> roles) {
    print('setting read roles $roles');
    _readOnlyRoles = roles;
  }

  @Input()
  set authorizedWrite(List<String> roles) {
    print('setting write roles $roles');
    _writeRoles = roles;
  }

  @override
  void ngDoCheck() {
    if (!_checked) {
      if (_isAuthorized(_readOnlyRoles)) {
        final viewRef = _viewContainer.createEmbeddedView(_templateRef);
        viewRef.setLocal('canWrite', _isAuthorized(_writeRoles));
      } else {
        _viewContainer.clear();
      }
      _checked = true;
    }
  }

  bool _isAuthorized(List<String> rolesAllowed) {
    final realmRoles =
        _keycloakService.getRealmRoles(instanceId: _instanceId).toSet();
    final resourceRoles =
        _keycloakService.getResourceRoles(instanceId: _instanceId).toSet();
    final combinedRoles = realmRoles.union(resourceRoles);

    return combinedRoles.containsAll(rolesAllowed);
  }
}
