import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:keycloak/keycloak.dart';

enum InitLoadType { standard, loginRequired, checkSSO }

enum InitFlowType { standart, implicit, hybrid }

class KeycloackServiceInstanceConfig {
  String id;
  String configFilePath;
  RoutePath redirectRoutePath;
  InitLoadType loadType = InitLoadType.standard;
  InitFlowType flowType = InitFlowType.standart;
}

class KeycloackServiceConfig {
  final instanceConfigs = List<KeycloackServiceInstanceConfig>();
}

class KeycloakService {
  final KeycloackServiceConfig _config;
  final Location _location;
  final _instances = <String, KeycloakInstance>{};

  KeycloakService(@Optional() this._config, @Optional() this._location);

  bool isInstanceInitiated({String instanceId}) => instanceId == null
      ? _instances.isNotEmpty
      : _instances.containsKey(instanceId);

  bool isAuthenticated({String id}) => _getInstance(id).authenticated;

  List<String> getRealmRoles({String id}) => _getInstance(id).realmAccess.roles;

  List<String> getResourceRoles({String id, String clientId}) {
    clientId = clientId ?? _getInstance(id).clientId;
    return _getInstance(id).resourceAccess[clientId].roles;
  }

  Future initInstance({String instanceId}) async {
    if (_config == null) {
      throw Exception(
          'Must have KeycloackServiceConfig defined to use initInstance');
    }

    final instanceConfig =
        _config.instanceConfigs.firstWhere((config) => config.id == instanceId);
    return registerInstance(instanceConfig);
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

    if (config.redirectRoutePath != null) {
      //TODO: actual way to get full redirection path
      initOption.redirectUri =
          'http://localhost:2700/${_location.prepareExternalUrl(config.redirectRoutePath.toUrl())}';
    }

    await instance.init(initOption);
    return chosenId;
  }

  void login({String id, String redirectUri}) {
    var realUrl =
        'http://localhost:2700/${_location.prepareExternalUrl(redirectUri)}';
    print('login redirecting to $realUrl');
    _getInstance(id).login(KeycloakLoginOptions()..redirectUri = realUrl);
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
