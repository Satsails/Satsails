import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/adapters/transaction_adapters.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/datetime_range_model.dart';

DateTimeSelect getCurrentMonthDateRange() {
  final DateTime now = DateTime.now();
  final DateTime startOfMonth = DateTime(now.year, now.month, 1);
  final DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
  return DateTimeSelect(
    start: startOfMonth,
    end: endOfMonth.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
  );
}

final dateTimeSelectProvider = StateNotifierProvider.autoDispose<DateTimeSelectProvider, DateTimeSelect>((ref) {
  return DateTimeSelectProvider(getCurrentMonthDateRange());
});

final selectedDaysDateArrayProvider = StateProvider.autoDispose<List<int>>((ref) {
  final DateTimeSelect dateTimeSelect = ref.watch(dateTimeSelectProvider);
  final DateTime start = DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.start * 1000);
  final DateTime end = DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.end * 1000);
  final List<int> selectedDays = [];
  for (int i = 0; i <= end.difference(start).inDays; i++) {
    selectedDays.add(start.add(Duration(days: i)).day);
  }
  return selectedDays;
});

final moreThanOneMonthProvider = StateProvider.autoDispose<bool>((ref) {
  final DateTimeSelect dateTimeSelect = ref.watch(dateTimeSelectProvider);
  final DateTime start = DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.start * 1000);
  final DateTime end = DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.end * 1000);
  return end.difference(start).inDays >= 31;
});

final oneDayProvider = StateProvider.autoDispose<bool>((ref) {
  final DateTimeSelect dateTimeSelect = ref.watch(dateTimeSelectProvider);
  final DateTime start = DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.start * 1000);
  final DateTime end = DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.end * 1000);
  return end.difference(start).inDays == 0;
});


final bitcoinFeeSpentPerDayProvider = StateProvider.autoDispose<Map<int, num>>((ref) {
  final List<int> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(bitcoinTransactionsByDate);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<int, num> valueSpentPerDay = {};

  for (int day in selectedDays) {
    valueSpentPerDay[day] = 0;
  }

  for (TransactionDetails transaction in transactions) {
    if (transaction.sent > 0) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.confirmationTime!.timestamp * 1000);
      final int day = date.day;
      if (selectedDays.contains(day)) {
        valueSpentPerDay[day] = valueSpentPerDay[day]! + btcInDenominationNum(transaction.fee!, btcFormat);
      }
    }
  }

  num cumulativeFee = 0;
  for (int day in selectedDays) {
    cumulativeFee += valueSpentPerDay[day]!;
    valueSpentPerDay[day] = cumulativeFee;
  }

  return valueSpentPerDay;
});

final bitcoinIncomePerDayProvider = StateProvider.autoDispose<Map<int, num>>((ref) {
  final List<int> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(bitcoinTransactionsByDate);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<int, num> valueIncomePerDay = {};

  for (int day in selectedDays) {
    valueIncomePerDay[day] = 0;
  }

  for (TransactionDetails transaction in transactions) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.confirmationTime!.timestamp * 1000);
    final int day = date.day;
    if (selectedDays.contains(day)) {
      valueIncomePerDay[day] = valueIncomePerDay[day]! + btcInDenominationNum(transaction.received, btcFormat);
    }
  }

  num cumulativeIncome = 0;
  for (int day in selectedDays) {
    cumulativeIncome += valueIncomePerDay[day]!;
    valueIncomePerDay[day] = cumulativeIncome;
  }

  return valueIncomePerDay;
});

final bitcoinSpentPerDayProvider = StateProvider.autoDispose<Map<int, num>>((ref) {
  final List<int> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(bitcoinTransactionsByDate);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<int, num> valueSpentPerDay = {};

  for (int day in selectedDays) {
    valueSpentPerDay[day] = 0;
  }

  for (TransactionDetails transaction in transactions) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.confirmationTime!.timestamp * 1000);
    final int day = date.day;
    if (selectedDays.contains(day)) {
      valueSpentPerDay[day] = valueSpentPerDay[day]! + btcInDenominationNum(transaction.sent, btcFormat);
    }
  }

  num cumulativeSpent = 0;
  for (int day in selectedDays) {
    cumulativeSpent += valueSpentPerDay[day]!;
    valueSpentPerDay[day] = cumulativeSpent;
  }

  return valueSpentPerDay;
});

final bitcoinBalanceOverPeriodByDayProvider = StateProvider.autoDispose<Map<int, num>>((ref) {
  final List<int> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(transactionNotifierProvider).bitcoinTransactions;
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<int, num> balancePerDay = {};

  for (int day in selectedDays) {
    balancePerDay[day] = 0;
  }

  transactions.sort((a, b) => a.confirmationTime!.timestamp.compareTo(b.confirmationTime!.timestamp));

  for (TransactionDetails transaction in transactions) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.confirmationTime!.timestamp * 1000);
    final int day = date.day;

    final netAmount = transaction.received - transaction.sent;

    if (selectedDays.contains(day)) {
      balancePerDay[day] = balancePerDay[day]! + btcInDenominationNum(netAmount, btcFormat);
    }
  }

  return balancePerDay;
});



final liquidFeePerDayProvider = StateProvider.autoDispose.family<Map<int, num>, String>((ref, asset) {
  final List<int> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(liquidTransactionsByDate);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<int, num> valueSpentPerDay = {};

  for (int day in selectedDays) {
    valueSpentPerDay[day] = 0;
  }

  for (Tx transaction in transactions) {
    if (transaction.timestamp != 0 && transaction.timestamp != null) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.timestamp! * 1000);
      final int day = date.day;
      final hasSentFromAsset = transaction.balances.any((element) => element.assetId == asset && element.value < 0);
      if (selectedDays.contains(day) && hasSentFromAsset) {
        valueSpentPerDay[day] = valueSpentPerDay[day]! + btcInDenominationNum(transaction.fee, btcFormat).abs();
      }
    }
  }

  num cumulativeFee = 0;
  for (int day in selectedDays) {
    cumulativeFee += valueSpentPerDay[day]!;
    valueSpentPerDay[day] = cumulativeFee;
  }

  return valueSpentPerDay;
});

final liquidIncomePerDayProvider = StateProvider.autoDispose.family<Map<int, num>, String>((ref, asset) {
  final List<int> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(liquidTransactionsByDate);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<int, num> valueIncomePerDay = {};

  for (int day in selectedDays) {
    valueIncomePerDay[day] = 0;
  }

  for (Tx transaction in transactions) {
    if (transaction.timestamp != 0 && transaction.timestamp != null) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.timestamp! * 1000);
      final int day = date.day;
      final hasReceivedAsset = transaction.balances.any((element) => element.assetId == asset && element.value > 0);
      final assetIsBtc = asset ==  AssetMapper.reverseMapTicker(AssetId.LBTC);
      if (selectedDays.contains(day) && hasReceivedAsset) {
        valueIncomePerDay[day] = valueIncomePerDay[day]! + btcInDenominationNum(transaction.balances.firstWhere((element) => element.assetId == asset).value, btcFormat, assetIsBtc);
      }
    }
  }

  num cumulativeIncome = 0;
  for (int day in selectedDays) {
    cumulativeIncome += valueIncomePerDay[day]!;
    valueIncomePerDay[day] = cumulativeIncome;
  }

  return valueIncomePerDay;
});

final liquidSpentPerDayProvider = StateProvider.autoDispose.family<Map<int, num>, String>((ref, asset) {
  final List<int> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(liquidTransactionsByDate);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<int, num> valueSpentPerDay = {};

  for (int day in selectedDays) {
    valueSpentPerDay[day] = 0;
  }

  for (Tx transaction in transactions) {
    if (transaction.timestamp != 0 && transaction.timestamp != null) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.timestamp! * 1000);
      final int day = date.day;
      final hasSentAsset = transaction.balances.any((element) => element.assetId == asset && element.value < 0);
      final assetIsBtc = asset ==  AssetMapper.reverseMapTicker(AssetId.LBTC);
      if (selectedDays.contains(day) && hasSentAsset) {
        valueSpentPerDay[day] = valueSpentPerDay[day]! + btcInDenominationNum(transaction.balances.firstWhere((element) => element.assetId == asset).value, btcFormat, assetIsBtc).abs();
      }
    }
  }

  num cumulativeSpent = 0;
  for (int day in selectedDays) {
    cumulativeSpent += valueSpentPerDay[day]!;
    valueSpentPerDay[day] = cumulativeSpent;
  }

  return valueSpentPerDay;
});
final liquidBalanceOverPeriodByDayProvider = StateProvider.autoDispose.family<Map<int, num>, String>((ref, asset) {
  final List<int> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(transactionNotifierProvider).liquidTransactions;
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<int, num> balancePerDay = {};

  for (int day in selectedDays) {
    balancePerDay[day] = 0;
  }

  transactions.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

  for (Tx transaction in transactions) {
    if (transaction.timestamp != 0 && transaction.timestamp != null) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.timestamp! * 1000);
      final int day = date.day;

      final hasAsset = transaction.balances.any((element) => element.assetId == asset);
      if (selectedDays.contains(day) && hasAsset) {
        final sentValue = transaction.balances.firstWhere((element) => element.assetId == asset && element.value < 0, orElse: () => Balance(assetId: asset, value: 0)).value;
        final receivedValue = transaction.balances.firstWhere((element) => element.assetId == asset && element.value > 0, orElse: () => Balance(assetId: asset, value: 0)).value;
        final netAmount = receivedValue - sentValue;
        balancePerDay[day] = balancePerDay[day]! + btcInDenominationNum(netAmount, btcFormat);
      }
    }
  }

  return balancePerDay;
});


