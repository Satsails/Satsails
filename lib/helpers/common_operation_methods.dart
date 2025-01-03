import 'package:Satsails/providers/conversion_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk_dart/lwk_dart.dart' as lwk;

String confirmationStatus(bdk.TransactionDetails transaction, WidgetRef ref) {
  if (transaction.confirmationTime == null || transaction.confirmationTime!.height == 0) {
    return 'Unconfirmed'.i18n(ref);
  } else if (transaction.confirmationTime != null) {
    return 'Confirmed'.i18n(ref);
  } else {
    return 'Unknown'.i18n(ref);
  }
}

String transactionTypeString(bdk.TransactionDetails transaction, WidgetRef ref) {
  if (transaction.sent - transaction.received > 0) {
    return 'Sent'.i18n(ref);
  } else {
    return 'Received'.i18n(ref);
  }
}

Icon transactionTypeIcon(bdk.TransactionDetails transaction) {
  if (transaction.sent - transaction.received > 0) {
    return const Icon(Icons.arrow_upward, color: Colors.red);
  } else {
    return const Icon(Icons.arrow_downward, color: Colors.green);
  }
}

String transactionAmountInFiat(bdk.TransactionDetails transaction, WidgetRef ref) {
  final sent = ref.watch(conversionToFiatProvider(transaction.sent));
  final received = ref.watch(conversionToFiatProvider(transaction.received));
  final currency = ref.watch(settingsProvider).currency;

  if (transaction.received == 0 && transaction.sent > 0) {
    return '${(double.parse(sent) / 100000000).toStringAsFixed(2)} $currency';
  } else if (transaction.received > 0 && transaction.sent == 0) {
    return '${(double.parse(received) / 100000000).toStringAsFixed(2)} $currency';
  } else {
    double total = (double.parse(received) - double.parse(sent)).abs() / 100000000;
    return '${total.toStringAsFixed(2)} $currency';
  }
}

String transactionAmount(bdk.TransactionDetails transaction, WidgetRef ref) {
  if (transaction.received == 0 && transaction.sent > 0) {
    return ref.watch(conversionProvider(transaction.sent));
  } else if (transaction.received > 0 && transaction.sent == 0) {
    return ref.watch(conversionProvider(transaction.received));
  } else {
    int total = (transaction.received - transaction.sent).abs();
    return ref.watch(conversionProvider(total));
  }
}

Icon transactionTypeLiquidIcon(String kind) {
  switch (kind) {
    case 'incoming':
      return const Icon(Icons.arrow_downward, color: Colors.green);
    case 'outgoing':
      return const Icon(Icons.arrow_upward, color: Colors.red);
    case 'burn':
      return const Icon(Icons.local_fire_department, color: Colors.redAccent);
    case 'redeposit':
      return const Icon(Icons.subdirectory_arrow_left, color: Colors.green);
    case 'issuance':
      return const Icon(Icons.add_circle, color: Colors.greenAccent);
    case 'reissuance':
      return const Icon(Icons.add_circle, color: Colors.green);
    default:
      return const Icon(Icons.swap_calls, color: Colors.orange);
  }
}

Icon confirmationStatusIcon(lwk.Tx transaction) {
  return transaction.outputs.isNotEmpty && transaction.outputs[0].height != null || transaction.inputs.isNotEmpty && transaction.inputs[0].height != null
      ? const Icon(Icons.check_circle_outlined, color: Colors.green)
      : const Icon(Icons.access_alarm_outlined, color: Colors.red);
}


String liquidTransactionType(lwk.Tx transaction, WidgetRef ref) {
  switch (transaction.kind) {
    case 'incoming':
      return 'Received'.i18n(ref);
    case 'outgoing':
      return 'Sent'.i18n(ref);
    case 'burn':
      return 'Burn'.i18n(ref);
    case 'redeposit':
      return 'Redeposit'.i18n(ref);
    case 'issuance':
      return 'Issuance'.i18n(ref);
    case 'reissuance':
      return 'Reissuance'.i18n(ref);
    default:
      return 'Fiat Swap'.i18n(ref);
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
    ref.read(transactionSearchProvider).amount = output.value;
    ref.read(transactionSearchProvider).assetId = output.asset;
    ref.read(transactionSearchProvider).unblindedUrl = transaction.unblindedUrl;
  } else {
    final inputs = transaction.inputs[0];
    final input = inputs.unblinded;
    ref.read(transactionSearchProvider).amountBlinder = input.valueBf;
    ref.read(transactionSearchProvider).assetBlinder = input.assetBf;
    ref.read(transactionSearchProvider).amount = input.value;
    ref.read(transactionSearchProvider).assetId = input.asset;
    ref.read(transactionSearchProvider).unblindedUrl = transaction.unblindedUrl;
  }
}

Icon subTransactionIcon(int value) {
  if (value > 0) {
    return const Icon(Icons.arrow_downward, color: Colors.green);
  } else if (value < 0) {
    return const Icon(Icons.arrow_upward, color: Colors.red);
  } else {
    return const Icon(Icons.device_unknown_outlined, color: Colors.grey);
  }
}
