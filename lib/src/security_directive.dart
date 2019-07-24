import 'package:angular/angular.dart';

import 'keycloak_service.dart';

/// Causes an element and its contents to be added at the DOM
/// based on the authorization status with [KeycloakService].
///
/// Instance ID of specific [KeycloakInstance] can be provided,
/// of leave blank for single instance usage.
///
/// /// Following example show how to show a <p> element when authenticated.
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
@Directive(selector: '[kcSecurity]')
class KcSecurity implements DoCheck {
  final KeycloakService _keycloakService;
  final TemplateRef _templateRef;
  final ViewContainerRef _viewContainer;

  String _instanceId;
  bool _checked = false;
  bool _showWhenDenied = false;
  var _readonlyRoles = <String>[];
  var _roles = <String>[];

  KcSecurity(this._keycloakService, this._templateRef, this._viewContainer);

  @Input()
  set kcSecurity(String instanceId) {
    _instanceId = instanceId.isNotEmpty ? instanceId : null;
  }

  @Input()
  set kcSecurityReadonlyRoles(List<String> roles) {
    _readonlyRoles = roles;
  }

  @Input()
  set kcSecurityRoles(List<String> roles) {
    _roles = roles;
  }

  @Input()
  set kcSecurityShowWhenDenied(bool value) {
    _showWhenDenied = value;
  }

  @override
  void ngDoCheck() {
    if (!_checked) {
      var shouldAddContent = false;
      var shouldSetReadonly = false;

      if (_isAuthenticated) {
        if (_readonlyRoles.isEmpty) {
          if (_roles.isNotEmpty) {
            shouldAddContent = _isAuthorized(_roles);
          } else {
            shouldAddContent = true;
          }
        } else if (_isAuthorized(_readonlyRoles)) {
          //TODO: We made an assumption that if you are not authorize for readonly, you can't authorize for write.
          shouldAddContent = true;
          shouldSetReadonly = _roles.isNotEmpty && !_isAuthorized(_roles);
        }
      }

      if (shouldAddContent == !_showWhenDenied) {
        final viewRef = _viewContainer.createEmbeddedView(_templateRef);
        viewRef.setLocal('readonly', shouldSetReadonly);
      } else {
        _viewContainer.clear();
      }

      _checked = true;
    }
  }

  bool get _isAuthenticated =>
      _keycloakService.isInstanceInitiated(instanceId: _instanceId) &&
      _keycloakService.isAuthenticated(instanceId: _instanceId);

  bool _isAuthorized(List<String> rolesAllowed) {
    final realmRoles =
        _keycloakService.getRealmRoles(instanceId: _instanceId).toSet();
    final resourceRoles =
        _keycloakService.getResourceRoles(instanceId: _instanceId).toSet();
    final combinedRoles = realmRoles.union(resourceRoles);

    return combinedRoles.containsAll(rolesAllowed);
  }
}
