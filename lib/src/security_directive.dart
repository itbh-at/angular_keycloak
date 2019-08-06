import 'package:angular/angular.dart';

import 'keycloak_service.dart';

/// Causes an element and its contents to be added at the DOM
/// based on the authentication and authorization status with [KeycloakService].
///
/// Instance ID of specific [KeycloakInstance] can be provided in the
/// [Microsyntax](https://angulardart.dev/guide/structural-directives#microsyntax).
/// Or leave blank for single instance usage.
///
/// Following example show how to display a <p> element when authenticated.
///
/// ```'html'
/// <p *kcSecurity>Welcome!</p>
/// ```
///
/// Following example show how to display a <div> element when authenticated
/// with a specific instance.
///
/// ```'html
/// <div *kcSecurity="getInstanceId">User Only</div>
/// ```
///
/// Roles are `<String>[]` to be provided via the `roles`. When roles were defined
/// the content will be shown if only user is autenticated and authorized.
/// i.e. having the correct roles assigned to user's Keycloak profile.
///
/// Following example show how to display a <div> element when authenticated
/// and authorized with the role of 'vip'.
///
/// ```'html'
/// <div *kcSecurity="roles: ['vip']">
///   VIP will see this, other will not.
/// </div>
/// ```
///
/// Readonly roles are `<String>[]` to be provided via `readonlyRoles`.
///
/// When readonly roles are provided, a local variable can be acquire
/// with `let value=readonly`. `readonly` will be true if the user's authorization
/// has roles in the `readonlyRoles` but not in the actual `roles`.
///
/// Following example show how to display a <div> element when authenticated
/// and authorized with the role of 'supervisor' or 'boss'. If user has only 'supervisor'
/// role, `ro` will be true. And in this example, the <input> will become a readonly
/// text input.
///
/// ```'html'
/// <div *kcSecurity="readonlyRoles: ['supervisor'];
///                   roles: ['boss'];
///                   let ro = readonly">
///   <input [readonly]="ro" type="text" />
/// </div>
/// ```
///
/// All the examples above show how to show the content when access is granted.
/// The opposite, i.e. when access is denied, `showWhenDenied` can flag as true.
/// In that case, the content will be shown when authentication or authorization failed.
///
/// Following example show how to display the login button when unauthenticated
///
/// ```'html`
/// <material-button  *kcSecurity="showWhenDenied: true">
///   Login
/// </material-button>
/// ```
///
/// Following example show how to display a warning when user is not authorized.
///
/// ```'html'
/// <div *kcSecurity="roles: ['vip']; showWhenDenied: true">
///   You are not authorized to enter the VIP room.
/// </div>
/// ```
///
/// Please refer the the `example-directive/app/example_app_component.html`
/// for more html examples.
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
    // It seems that @Input never pass in a `null` String, even given one.
    // It will always became an empty String.
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
        } else if (_isAuthorized(_readonlyRoles) || _isAuthorized(_roles)) {
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
