class NetworkSecurityCase {
  final String network;

  const NetworkSecurityCase._(this.network);

  static const bitcoinMS = NetworkSecurityCase._('mainnet');
  static const bitcoinSS = NetworkSecurityCase._('electrum-mainnet');
  static const liquidMS = NetworkSecurityCase._('liquid');
  static const liquidSS = NetworkSecurityCase._('electrum-liquid');
  static const testnetMS = NetworkSecurityCase._('testnet');
  static const testnetSS = NetworkSecurityCase._('electrum-testnet');
  static const testnetLiquidMS = NetworkSecurityCase._('testnet-liquid');
  static const testnetLiquidSS = NetworkSecurityCase._('electrum-testnet-liquid');
  static const lightning = NetworkSecurityCase._('lightning-mainnet');
  static const testnetLightning = NetworkSecurityCase._('lightning-testnet');
}