import 'package:keycloak/keycloak.dart';

enum InitLoadType { standard, loginRequired, checkSSO }

enum InitFlowType { standart, implicit, hybrid }

class KeycloackServiceInstanceConfig {
  String id;
  String configFilePath;
  InitLoadType loadType = InitLoadType.standard;
  InitFlowType flowType = InitFlowType.standart;
}

class KeycloackServiceConfig {
  final instanceConfigs = List<KeycloackServiceInstanceConfig>();
}

class KeycloakService {
  final _instances = <String, KeycloakInstance>{};
  final KeycloackServiceConfig _config;

  KeycloakService(this._config);

  bool isAuthenticated({String id}) => _getInstance(id).authenticated;

  List<String> getRealmRoles({String id}) => _getInstance(id).realmAccess.roles;

  List<String> getResourceRoles({String id, String clientId}) {
    clientId = clientId ?? _getInstance(id).clientId;
    return _getInstance(id).resourceAccess[clientId].roles;
  }

  //TODO: Map init?
  Future<String> registerInstance(KeycloackServiceInstanceConfig config) async {
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

    await instance.init(initOption);

    return chosenId;
  }

  void login({String id}) {
    _getInstance(id).login();
  }

  void verifyInstance() async {
    if (_instances.isNotEmpty) {
      return;
    }

    for (final instanceConfig in _config.instanceConfigs) {
      await registerInstance(instanceConfig);
    }
  }

  KeycloakInstance _getInstance([String id]) {
    assert(_instances.isNotEmpty,
        'Trying to get Keycloak instance of $id but none has registered yet');
    if (id == null) {
      //TODO: We want to ensure the first created instnace is the one being return
      return _instances.values.first;
    }

    assert(_instances.containsKey(id),
        'Trying to get Keycloak instance of $id but it is not registered with service');
    return _instances[id];
  }
}
