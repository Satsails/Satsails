class BitcoinExpenses {
  final int sent;
  final int received;
  final int fee;

  BitcoinExpenses({required this.sent, required this.received, required this.fee});

  int get total => sent + received + fee;
  int get balance => received - sent - fee;

  BitcoinExpensesDouble convertToDenomination(String denomination) {
    double sentConverted, receivedConverted, feeConverted;

    switch (denomination) {
      case 'sats':
        sentConverted = sent.toDouble();
        receivedConverted = received.toDouble();
        feeConverted = fee.toDouble();
        break;
      case 'BTC':
        sentConverted = sent / 100000000.0;
        receivedConverted = received / 100000000.0;
        feeConverted = fee / 100000000.0;
        break;
      default:
        throw Exception('Invalid denomination');
    }

    return BitcoinExpensesDouble(
      sent: sentConverted,
      received: receivedConverted,
      fee: feeConverted,
    );
  }
}

class BitcoinExpensesDouble {
  final double sent;
  final double received;
  final double fee;

  BitcoinExpensesDouble({required this.sent, required this.received, required this.fee});

  double get total => sent + received + fee;
  double get balance => received - sent - fee;
}

class LiquidExpenses {
  final int bitcoinSent;
  final int bitcoinReceived;
  final int brlSent;
  final int brlReceived;
  final int usdSent;
  final int usdReceived;
  final int euroSent;
  final int euroReceived;
  final int fee;

  LiquidExpenses({
    required this.bitcoinSent,
    required this.bitcoinReceived,
    required this.brlSent,
    required this.brlReceived,
    required this.usdSent,
    required this.usdReceived,
    required this.euroSent,
    required this.euroReceived,
    required this.fee,
  });

  int get totalBitcoin => bitcoinSent + bitcoinReceived + fee;

  int get totalBrl => brlSent + brlReceived;

  int get totalUsd => usdSent + usdReceived;

  int get totalEuro => euroSent + euroReceived;


  LiquidExpensesDouble convertToDenomination(String denomination) {
    double bitcoinSentConverted, bitcoinReceivedConverted, feeConverted;

    switch (denomination) {
      case 'sats':
        bitcoinSentConverted = bitcoinSent.toDouble();
        bitcoinReceivedConverted = bitcoinReceived.toDouble();
        feeConverted = fee.toDouble();
        break;
      case 'BTC':
        bitcoinSentConverted = bitcoinSent / 100000000.0;
        bitcoinReceivedConverted = bitcoinReceived / 100000000.0;
        feeConverted = fee / 100000000.0;
        break;
      default:
        throw Exception('Invalid denomination');
    }

    return LiquidExpensesDouble(
      bitcoinSent: bitcoinSentConverted,
      bitcoinReceived: bitcoinReceivedConverted,
      fee: feeConverted,
    );
  }

}

class LiquidExpensesDouble {
  final double bitcoinSent;
  final double bitcoinReceived;
  final double fee;

  LiquidExpensesDouble({
    required this.bitcoinSent,
    required this.bitcoinReceived,
    required this.fee,
  });

  double get totalBitcoin => bitcoinSent + bitcoinReceived + fee;
}

