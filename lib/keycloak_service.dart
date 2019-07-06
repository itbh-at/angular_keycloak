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

  KeycloakService(this._config, this._location);

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

    if (config.redirectRoutePath != null) {
      initOption.redirectUri =
          'http://localhost:2700/${_location.prepareExternalUrl(config.redirectRoutePath.toUrl())}';
    }

    var t = await instance.init(initOption);
    print('initing int $chosenId $t');

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

  Future<bool> authenticateAndAuthorize({String id, Set<String> roles}) async {
    //TODO: Handle no id
    if (!_instances.containsKey(id)) {
      final instanceConfig =
          _config.instanceConfigs.firstWhere((config) => config.id == id);
      try {
        await registerInstance(instanceConfig);
      } catch (e) {
        print('register error $e');
        return false;
      }
    }
    final instance = _getInstance(id);
    if (instance.authenticated == false) {
      return false;
    } else if (roles.isNotEmpty) {
      final resourceRoles =
          instance.resourceAccess[instance.clientId].roles.toSet();
      return resourceRoles.containsAll(roles);
    }
    return true;
  }

  void verifyInstance() async {
    if (_instances.isNotEmpty) {
      return;
    }

    for (final instanceConfig in _config.instanceConfigs) {
      print('doing instance');

      try {
        await registerInstance(instanceConfig);
      } catch (e) {
        print('register error');
        continue;
      }
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
