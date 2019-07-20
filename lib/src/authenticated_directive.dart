import 'dart:html';

import 'package:angular/angular.dart';

import 'keycloak_service.dart';

@Directive(
  selector: '[authenticated]',
)
class AuthenticatedDirective implements OnInit {
  final KeycloakService _keycloakService;
  final TemplateRef _templateRef;
  final ViewContainerRef _viewContainer;

  var showIfAuthenticate = true;

  AuthenticatedDirective(
      this._keycloakService, this._templateRef, this._viewContainer);

  @override
  void ngOnInit() {
    final show = (_keycloakService.isInstanceInitiated() &&
            _keycloakService.isAuthenticated()) ==
        showIfAuthenticate;
    if (show) {
      _viewContainer.createEmbeddedView(_templateRef);
    } else {
      _viewContainer.clear();
    }
  }
}

@Directive(
  selector: '[not-authenticated]',
)
class NotAuthenticatedDirective extends AuthenticatedDirective {
  NotAuthenticatedDirective(KeycloakService keycloakService,
      TemplateRef templateRef, ViewContainerRef viewContainer)
      : super(keycloakService, templateRef, viewContainer) {
    showIfAuthenticate = false;
  }
}
