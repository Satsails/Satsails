import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/boltz_model.dart';
import 'package:Satsails/providers/conversion_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:boltz/boltz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lwk/lwk.dart' as lwk;

String confirmationStatus(bdk.TransactionDetails transaction, WidgetRef ref) {
  if (transaction.confirmationTime == null || transaction.confirmationTime!.height == 0) {
    return 'Unconfirmed'.i18n;
  } else if (transaction.confirmationTime != null) {
    return 'Confirmed'.i18n;
  } else {
    return 'Unknown'.i18n;
  }
}

String transactionTypeString(bdk.TransactionDetails transaction, WidgetRef ref) {
  if (transaction.sent.toInt() - transaction.received.toInt() > 0) {
    return 'Sent'.i18n;
  } else {
    return 'Received'.i18n;
  }
}

Widget transactionTypeIcon(bdk.TransactionDetails transaction) {
  // Helper function to create a circular icon with a dark gray background
  Widget circularIcon(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF333333), // Dark gray background
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 24, // Consistent icon size
        ),
      ),
    );
  }

  // Determine if the transaction is a send or receive
  if (transaction.sent.toInt() - transaction.received.toInt() > 0) {
    return circularIcon(Icons.arrow_upward, Colors.red); // Send
  } else {
    return circularIcon(Icons.arrow_downward, Colors.green); // Receive
  }
}

String transactionAmountInFiat(bdk.TransactionDetails transaction, WidgetRef ref) {
  final sent = ref.watch(conversionToFiatProvider(transaction.sent.toInt()));
  final received = ref.watch(conversionToFiatProvider(transaction.received.toInt()));
  final currency = ref.watch(settingsProvider).currency;

  if (transaction.received.toInt() == 0 && transaction.sent.toInt() > 0) {
    return '${(double.parse(sent) / 100000000).toStringAsFixed(2)} $currency';
  } else if (transaction.received.toInt() > 0 && transaction.sent.toInt() == 0) {
    return '${(double.parse(received) / 100000000).toStringAsFixed(2)} $currency';
  } else {
    double total = (double.parse(received) - double.parse(sent)).abs() / 100000000;
    return '${total.toStringAsFixed(2)} $currency';
  }
}

String boltzTransactionAmountInFiat(LbtcBoltz transaction, WidgetRef ref) {
  final currency = ref.watch(settingsProvider).currency;
  final swapType = transaction.swap.kind;
  final amountSatoshis = transaction.swap.outAmount;

  final amountBtc = amountSatoshis;

  final isReceiving = swapType == SwapType.reverse;
  final fiatAmount = ref.watch(conversionToFiatProvider(amountBtc));

  final formattedFiat = (double.parse(fiatAmount) / 100000000).toStringAsFixed(2);
  final sign = isReceiving ? '+' : '-';

  return '$sign $formattedFiat $currency';
}

String transactionAmount(bdk.TransactionDetails transaction, WidgetRef ref) {
  if (transaction.received.toInt() == 0 && transaction.sent.toInt() > 0) {
    return ref.watch(conversionProvider(transaction.sent.toInt()));
  } else if (transaction.received.toInt() > 0 && transaction.sent.toInt() == 0) {
    return ref.watch(conversionProvider(transaction.received.toInt()));
  } else {
    int total = (transaction.received.toInt() - transaction.sent.toInt()).abs();
    return ref.watch(conversionProvider(total));
  }
}

Widget pegTransactionTypeIcon() {
  Widget circularIcon(IconData icon, Color color) {
    return Container(
      width: 40,  // Responsive width
      height: 40, // Responsive height, same as width for a circle
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF333333), // Dark gray background
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 24.w, // Responsive icon size
        ),
      ),
    );
  }
  return circularIcon(Icons.swap_horiz_outlined, Colors.orange); // Peg Out: outgoing
}

Widget eulenTransactionTypeIcon() {
  Widget circularIcon(IconData icon, Color color) {
    return Container(
      width: 40,  // Responsive width
      height: 40, // Responsive height, same as width for a circle
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF333333), // Dark gray background
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 24.w, // Responsive icon size
        ),
      ),
    );
  }
  return circularIcon(Icons.pix, Colors.green); // Peg Out: outgoing
}

Widget transactionTypeLiquidIcon(String kind) {
  // Helper function to create a circular icon with a dark gray background
  Widget circularIcon(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF333333), // Dark gray background as per image
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 24, // Consistent icon size within the circle
        ),
      ),
    );
  }

  // Switch case to map transaction types to their icons
  switch (kind) {
    case 'incoming':
      return circularIcon(Icons.arrow_downward, Colors.green);
    case 'outgoing':
      return circularIcon(Icons.arrow_upward, Colors.red);
    case 'burn':
      return circularIcon(Icons.local_fire_department, Colors.redAccent);
    case 'redeposit':
      return circularIcon(Icons.subdirectory_arrow_left, Colors.green);
    case 'issuance':
      return circularIcon(Icons.add_circle, Colors.greenAccent);
    case 'reissuance':
      return circularIcon(Icons.add_circle, Colors.green);
    default:
      return circularIcon(Icons.swap_horiz_outlined, Colors.orange);
  }
}

Icon confirmationStatusIcon(lwk.Tx transaction) {
  return transaction.outputs.isNotEmpty && transaction.outputs[0].height != null || transaction.inputs.isNotEmpty && transaction.inputs[0].height != null
      ? const Icon(Icons.check_circle_outlined, color: Colors.green)
      : const Icon(Icons.access_alarm_outlined, color: Colors.red);
}


String liquidTransactionType(lwk.Tx transaction) {
  switch (transaction.kind) {
    case 'incoming':
      return 'Received'.i18n;
    case 'outgoing':
      return 'Sent'.i18n;
    case 'burn':
      return 'Burn'.i18n;
    case 'redeposit':
      return 'Redeposit'.i18n;
    case 'issuance':
      return 'Issuance'.i18n;
    case 'reissuance':
      return 'Reissuance'.i18n;
    default:
      return 'Fiat Swap'.i18n;
  }
}

String timestampToDateTime(int? timestamp) {
  if (timestamp == 0 || timestamp == null) {
    return 'Unconfirmed';
  }
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
}


void setTransactionSearchProvider(lwk.Tx transaction, WidgetRef ref) {
  ref.read(transactionSearchProvider).isLiquid = true;
  ref.read(transactionSearchProvider).txid = transaction.txid;

  if (transaction.kind == 'incoming') {
    final outputs = transaction.outputs[0];
    final output = outputs.unblinded;
    ref.read(transactionSearchProvider).amountBlinder = output.valueBf;
    ref.read(transactionSearchProvider).assetBlinder = output.assetBf;
    ref.read(transactionSearchProvider).amount = output.value.toInt();
    ref.read(transactionSearchProvider).assetId = output.asset;
    ref.read(transactionSearchProvider).unblindedUrl = transaction.unblindedUrl;
  } else {
    final inputs = transaction.inputs[0];
    final input = inputs.unblinded;
    ref.read(transactionSearchProvider).amountBlinder = input.valueBf;
    ref.read(transactionSearchProvider).assetBlinder = input.assetBf;
    ref.read(transactionSearchProvider).amount = input.value.toInt();
    ref.read(transactionSearchProvider).assetId = input.asset;
    ref.read(transactionSearchProvider).unblindedUrl = transaction.unblindedUrl;
  }
}

Widget subTransactionIndicator(int value, {bool showIcon = true}) {
  if (showIcon) {
    // Return icons based on the value, same as the original behavior
    if (value > 0) {
      return const Icon(Icons.arrow_downward, color: Colors.green);
    } else if (value < 0) {
      return const Icon(Icons.arrow_upward, color: Colors.red);
    } else {
      return const Icon(Icons.device_unknown_outlined, color: Colors.grey);
    }
  } else {
    // Return text instead of icons
    String text;
    Color color;
    if (value > 0) {
      text = "Received";
      color = Colors.green;
    } else if (value < 0) {
      text = "Sent";
      color = Colors.red;
    } else {
      text = "Unknown";
      color = Colors.grey;
    }
    return Text(
      text,
      style: TextStyle(color: color),
    );
  }
}

String liquidTransactionAmountInFiat(dynamic transaction, WidgetRef ref) {
  if (AssetMapper.mapAsset(transaction.assetId) == AssetId.LBTC) {
    final currency = ref.watch(settingsProvider).currency;
    final value = ref.watch(conversionToFiatProvider(transaction.value));
    return currencyFormat(double.parse(value) / 100000000, currency);
  }
  return '';
}

String valueOfLiquidSubTransaction(AssetId asset, int value, WidgetRef ref) {
  switch (asset) {
    case AssetId.USD:
    case AssetId.EUR:
    case AssetId.BRL:
      return (value / 100000000).toStringAsFixed(2);
    case AssetId.LBTC:
      return ref.watch(conversionProvider(value));
    default:
      return (value / 100000000).toStringAsFixed(2);
  }
}

Widget sideshiftTransactionTypeIcon() {
  /// Helper function to create a styled circular icon container.
  Widget circularIcon(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF333333), // Dark gray background
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 24.w, // Responsive icon size
        ),
      ),
    );
  }

  return circularIcon(Icons.swap_horiz, Colors.orange);
}

  Widget boltzTransactionTypeIcon() {
  Widget circularIcon(IconData icon, Color color) {
    return Container(
      width: 40, // Responsive width, matching pegTransactionTypeIcon
      height: 40, // Responsive height, same as width for a circle
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF333333), // Dark gray background, matching pegTransactionTypeIcon
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 24.w, // Responsive icon size, matching pegTransactionTypeIcon
        ),
      ),
    );
  }
  return circularIcon(Icons.swap_horiz, Colors.orange);
}
