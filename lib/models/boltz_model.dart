class BoltzReceive {
  String mnemonic;
  String index;
  int outAmount;
  String network;
  String electrumUrl;
  String boltzUrl;
  bool isLiquid;

  BoltzReceive({
    required this.mnemonic,
    required this.index,
    required this.outAmount,
    required this.network,
    required this.electrumUrl,
    required this.boltzUrl,
    required this.isLiquid,
  });
}