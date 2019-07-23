import 'package:angular/angular.dart';

import 'keycloak_service.dart';

/// Causes an element and its contents to be added at the DOM
/// based on the authorization status with [KeycloakService].
///
/// Instance ID of specific [KeycloakInstance] can be provided,
/// of leave blank for single instance usage.
///
/// Roles are `<String>[]` to be provided via the `roles`.
/// Unauthorized, i.e. does not has the correct roles, will not add
/// the content to DOM.
///
/// ```'html'
/// <div *authorized="roles: ['vip']"></div>
/// ```
///
/// Readonly roles are `<String>[]` will be via `readonlyRoles`.
///
/// When readonly roles are provided, a local variable can be acquire
/// with `let ro=readonly`. It will be true if the user's authorization
/// has roles in the `readonlyRoles` but not in the actual `roles`.
///
/// ```'html'
/// <div *authorized="readonlyRoles: ['supervisor'];
///                   roles: ['boss'];
///                   let ro = readonly">
///   <input [readonly]="ro" type="text" />
/// </div>
/// ```
@Directive(
  selector: '[authorized]',
)
class AuthorizedDirective implements DoCheck {
  final KeycloakService _keycloakService;
  final TemplateRef _templateRef;
  final ViewContainerRef _viewContainer;

  String _instanceId;
  List<String> _readonlyRoles;
  List<String> _roles;
  bool _checked = false;

  AuthorizedDirective(
      this._keycloakService, this._templateRef, this._viewContainer);

  @Input()
  set authorized(String instanceId) {
    _instanceId = instanceId.isNotEmpty ? instanceId : null;
  }

  @Input()
  set authorizedReadonlyRoles(List<String> roles) {
    _readonlyRoles = roles;
  }

  @Input()
  set authorizedRoles(List<String> roles) {
    _roles = roles;
  }

  @override
  void ngDoCheck() {
    if (!_checked) {
      if (_isAuthorized(_readonlyRoles)) {
        final viewRef = _viewContainer.createEmbeddedView(_templateRef);
        viewRef.setLocal('readonly', !_isAuthorized(_roles));
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
