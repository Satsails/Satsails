class AccountType {
  final String value;

  const AccountType._(this.value);

  static const standard = AccountType._('2of2');
  static const amp = AccountType._('2of2_no_recovery');
  static const twoOfThree = AccountType._('2of3');
  static const legacy = AccountType._('p2pkh');
  static const segwitWrapped = AccountType._('p2sh-p2wpkh');
  static const segWit = AccountType._('p2wpkh');
  static const taproot = AccountType._('p2tr');
  static const lightning = AccountType._('lightning');

  @override
  String toString() {
    return value;
  }
}