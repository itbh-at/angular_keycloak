import 'package:keycloak/keycloak.dart';

import 'keycloak_service_config.dart';

abstract class KeycloakService {
  bool isInstanceInitiated({String instanceId});

  void _verifyInitialization(String instanceId);

  Future initWithProvidedConfig({String instanceId, String redirectedOrigin});

  Future<String> init(
      [KeycloackServiceInstanceConfig config =
          const KeycloackServiceInstanceConfig(),
      String redirectedOrigin]);

  bool isAuthenticated({String instanceId});

  List<String> getRealmRoles({String instanceId});

  List<String> getResourceRoles({String instanceId, String clientId});

  Future<KeycloakProfile> getUserProfile({String instanceId});

  Future<String> getToken({String instanceId});

  void login({String instanceId, String redirectUri});

  void logout({String instanceId});

  Future<bool> refreshToken({String instanceId, num minValidity = 30});

  KeycloakInstance getInstance([String instanceId]);
}
