import 'package:angular/angular.dart' show Optional;
import 'package:keycloak/keycloak.dart';

enum InitLoadType { standard, loginRequired, checkSSO }

enum InitFlowType { standard, implicit, hybrid }

class KeycloackServiceInstanceConfig {
  final String id;
  final String configFilePath;
  final String redirectUri;
  final InitLoadType loadType;
  final InitFlowType flowType;

  const KeycloackServiceInstanceConfig(
      {this.id,
      this.configFilePath,
      this.redirectUri,
      this.loadType = InitLoadType.standard,
      this.flowType = InitFlowType.standard});
}

class KeycloackServiceConfig {
  final instanceConfigs = List<KeycloackServiceInstanceConfig>();
}

class KeycloakService {
  final KeycloackServiceConfig _config;
  final _instances = <String, KeycloakInstance>{};

  KeycloakService(@Optional() this._config);

  bool isInstanceInitiated({String instanceId}) => instanceId == null
      ? _instances.isNotEmpty
      : _instances.containsKey(instanceId);

  bool isAuthenticated({String instanceId}) =>
      getInstance(instanceId).authenticated;

  List<String> getRealmRoles({String instanceId}) =>
      getInstance(instanceId).realmAccess.roles;

  List<String> getResourceRoles({String instanceId, String clientId}) {
    clientId = clientId ?? getInstance(instanceId).clientId;
    return getInstance(instanceId).resourceAccess[clientId].roles;
  }

  Future initWithId({String instanceId, String redirectedOrigin}) async {
    if (_config == null) {
      throw Exception(
          'Must have KeycloackServiceConfig defined to use initWithId');
    }

    final instanceConfig =
        _config.instanceConfigs.firstWhere((config) => config.id == instanceId);
    return init(instanceConfig, redirectedOrigin);
  }

  Future<String> init(
      [KeycloackServiceInstanceConfig config =
          const KeycloackServiceInstanceConfig(),
      String redirectedOrigin]) async {
    // Create the instance and store it by id
    final instance = KeycloakInstance(config.configFilePath);
    final chosenId = config.id ?? instance.hashCode.toString();
    _instances[chosenId] = instance;

    // Initialize the instance
    final initOption = KeycloakInitOptions();
    switch (config.loadType) {
      case InitLoadType.loginRequired:
        initOption.onLoad = 'login-required';
        break;
      case InitLoadType.checkSSO:
        initOption.onLoad = 'check-sso';
        break;
      default:
        break;
    }

    switch (config.flowType) {
      case InitFlowType.implicit:
        initOption.flow = 'implicit';
        break;
      case InitFlowType.hybrid:
        initOption.flow = 'hybrid';
        break;
      default:
        break;
    }

    if (redirectedOrigin != null) {
      initOption.redirectUri = redirectedOrigin;
    } else if (config.redirectUri != null) {
      initOption.redirectUri = config.redirectUri;
    }

    await instance.init(initOption);
    return chosenId;
  }

  void login({String instanceId, String redirectUri}) {
    getInstance(instanceId)
        .login(KeycloakLoginOptions()..redirectUri = redirectUri);
  }

  void logout({String instanceId}) {
    getInstance(instanceId).logout();
  }

  Future<bool> refreshToken({String instanceId, num minValidity = 30}) async {
    return getInstance(instanceId).updateToken(minValidity);
  }

  Future<KeycloakProfile> getUserProfile({String instanceId}) async {
    await refreshToken(instanceId: instanceId, minValidity: 55);
    final profile = await getInstance(instanceId).loadUserProfile();
    return profile;
  }

  KeycloakInstance getInstance([String id]) {
    assert(_instances.isNotEmpty,
        'Trying to get Keycloak instance of $id but none has registered yet');
    if (id == null) {
      return _instances.values.first;
    }

    assert(_instances.containsKey(id),
        'Trying to get Keycloak instance of $id but it is not registered with service');
    return _instances[id];
  }
}
