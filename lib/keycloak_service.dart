import 'package:angular/angular.dart' show Optional;
import 'package:keycloak/keycloak.dart';

enum InitLoadType { standard, loginRequired, checkSSO }

enum InitFlowType { standart, implicit, hybrid }

class KeycloackServiceInstanceConfig {
  String id;
  String configFilePath;
  String redirectUri;
  InitLoadType loadType = InitLoadType.standard;
  InitFlowType flowType = InitFlowType.standart;
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

  bool isAuthenticated({String id}) => _getInstance(id).authenticated;

  List<String> getRealmRoles({String id}) => _getInstance(id).realmAccess.roles;

  List<String> getResourceRoles({String id, String clientId}) {
    clientId = clientId ?? _getInstance(id).clientId;
    return _getInstance(id).resourceAccess[clientId].roles;
  }

  Future initInstance({String instanceId, String redirectedOrigin}) async {
    if (_config == null) {
      throw Exception(
          'Must have KeycloackServiceConfig defined to use initInstance');
    }

    final instanceConfig =
        _config.instanceConfigs.firstWhere((config) => config.id == instanceId);
    return registerInstance(instanceConfig, redirectedOrigin);
  }

  //TODO: Map init?
  Future<String> registerInstance(KeycloackServiceInstanceConfig config,
      [String redirectedOrigin]) async {
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

  void login({String id, String redirectUri}) {
    _getInstance(id).login(KeycloakLoginOptions()..redirectUri = redirectUri);
  }

  void logout({String id}) {
    _getInstance(id).logout();
  }

  Future<String> getUserName({String id}) async {
    final profile = await _getInstance(id).loadUserProfile();
    return profile.username;
  }

  KeycloakInstance _getInstance([String id]) {
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
