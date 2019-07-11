import 'package:angular/angular.dart' show Injectable, Optional;
import 'package:keycloak/keycloak.dart';

import 'keycloak_service.dart';
import 'keycloak_service_config.dart';

@Injectable()
class KeycloakServiceImpl extends KeycloakService {
  final _config = Map<String, KeycloackServiceInstanceConfig>();

  KeycloakInstance _initiatedInstance;
  String _initiatedInstanceId;
  bool _autoUpdateToken = false;
  int _autoUpdateMinValidity = 30;

  KeycloakServiceImpl(@Optional() KeycloackServiceConfig config) {
    if (config != null) {
      _config.addEntries(config.instanceConfigs.map(
          (instanceConfig) => MapEntry(instanceConfig.id, instanceConfig)));
    }
  }

  @override
  bool isInstanceInitiated({String instanceId}) {
    if (_initiatedInstance == null) {
      return false;
    } else if (instanceId != null && instanceId != _initiatedInstanceId) {
      return false;
    }
    return true;
  }

  void _verifyInitialization(String instanceId) {
    if (!isInstanceInitiated(instanceId: instanceId)) {
      throw Exception('Keycloak instance $instanceId is not initiated.');
    }
  }

  @override
  Future initWithProvidedConfig(
      {String instanceId, String redirectedOrigin}) async {
    if (_config == null) {
      throw Exception(
          'Must have KeycloackServiceConfig defined to use initWithId');
    }
    if (!_config.containsKey(instanceId)) {
      throw Exception(
          'Must have $instanceId KeycloakServiceInstanceConfig defined to use initWithId');
    }

    return init(_config[instanceId], redirectedOrigin);
  }

  @override
  Future<String> init(
      [KeycloackServiceInstanceConfig config =
          const KeycloackServiceInstanceConfig(),
      String redirectedOrigin]) async {
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

    final instance = KeycloakInstance(config.configFilePath);
    await instance.init(initOption);

    _initiatedInstance = instance;
    _initiatedInstanceId = config.id ?? _initiatedInstance.hashCode.toString();
    _autoUpdateToken =
        config.autoUpdate && config.flowType != InitFlowType.implicit;
    _autoUpdateMinValidity = config.autoUpdateMinValidity;

    return _initiatedInstanceId;
  }

  @override
  bool isAuthenticated({String instanceId}) {
    _verifyInitialization(instanceId);
    return _initiatedInstance.authenticated;
  }

  @override
  List<String> getRealmRoles({String instanceId}) {
    _verifyInitialization(instanceId);
    return _initiatedInstance.realmAccess.roles;
  }

  @override
  List<String> getResourceRoles({String instanceId, String clientId}) {
    _verifyInitialization(instanceId);

    clientId = clientId ?? _initiatedInstance.clientId;
    return _initiatedInstance.resourceAccess[clientId].roles;
  }

  @override
  Future<KeycloakProfile> getUserProfile({String instanceId}) async {
    _verifyInitialization(instanceId);

    if (_autoUpdateToken) {
      await _initiatedInstance.updateToken(_autoUpdateMinValidity);
    }

    final profile = await _initiatedInstance.loadUserProfile();
    return profile;
  }

  @override
  Future<String> getToken({String instanceId}) async {
    _verifyInitialization(instanceId);

    if (_autoUpdateToken) {
      await _initiatedInstance.updateToken(_autoUpdateMinValidity);
    }

    return _initiatedInstance.token;
  }

  @override
  void login({String instanceId, String redirectUri}) {
    _verifyInitialization(instanceId);
    _initiatedInstance.login(KeycloakLoginOptions()..redirectUri = redirectUri);
  }

  @override
  void logout({String instanceId}) {
    _verifyInitialization(instanceId);
    _initiatedInstance.logout();
  }

  @override
  Future<bool> refreshToken({String instanceId, num minValidity = 30}) async {
    _verifyInitialization(instanceId);
    return _initiatedInstance.updateToken(minValidity);
  }

  @override
  KeycloakInstance getInstance([String instanceId]) {
    _verifyInitialization(instanceId);
    return _initiatedInstance;
  }
}
