enum InitLoadType { standard, loginRequired, checkSSO }

enum InitFlowType { standard, implicit, hybrid }

class KeycloackServiceInstanceConfig {
  final String id;
  final String configFilePath;
  final String redirectUri;
  final InitLoadType loadType;
  final InitFlowType flowType;
  final bool autoUpdate;
  final int autoUpdateMinValidity;

  const KeycloackServiceInstanceConfig(
      {this.id,
      this.configFilePath,
      this.redirectUri,
      this.loadType = InitLoadType.standard,
      this.flowType = InitFlowType.standard,
      this.autoUpdate = true,
      this.autoUpdateMinValidity = 30});
}

class KeycloackServiceConfig {
  final List<KeycloackServiceInstanceConfig> instanceConfigs;

  const KeycloackServiceConfig(this.instanceConfigs);
}
