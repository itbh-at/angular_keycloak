import 'package:keycloak/keycloak.dart';

enum InitLoadType { standard, loginRequired, checkSSO }

enum InitFlowType { standart, implicit, hybrid }

class KeycloakService {
  final _instances = <String, KeycloakInstance>{};

  bool isAuthenticated({String id}) => _getInstance(id).authenticated;

  List<String> getRealmRoles({String id}) => _getInstance(id).realmAccess.roles;

  List<String> getResourceRoles({String id, String clientId}) {
    clientId = clientId ?? _getInstance(id).clientId;
    return _getInstance(id).resourceAccess[clientId].roles;
  }

  //TODO: Map init?
  Future<String> registerInstance(
      {String id,
      String configFilePath,
      InitLoadType loadType = InitLoadType.standard,
      InitFlowType flowType = InitFlowType.standart}) async {
    // Create the instance and store it by id
    final instance = KeycloakInstance(configFilePath);
    final chosenId = id ?? instance.hashCode.toString();
    _instances[chosenId] = instance;

    // Initialize the instance
    final initOption = KeycloakInitOptions();
    switch (loadType) {
      case InitLoadType.loginRequired:
        initOption.onLoad = 'login-required';
        break;
      case InitLoadType.checkSSO:
        initOption.onLoad = 'check-sso';
        break;
      default:
        break;
    }

    switch (flowType) {
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
