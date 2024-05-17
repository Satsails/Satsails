enum PaymentType {
  Bitcoin,
  Liquid,
  Lightning,
  Unknown
}

class AddressAndAmount {
  final String address;
  final int? amount;
  final PaymentType type;
  final String? assetId;

  AddressAndAmount(this.address, this.amount, this.assetId, {this.type = PaymentType.Unknown});
}