import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/adapters/transaction_adapters.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/datetime_range_model.dart';

DateTimeSelect getCurrentMonthDateRange() {
  final DateTime now = DateTime.now();
  final startDate = now.subtract(Duration(days: 30));
  return DateTimeSelect(
    start: startDate,
    end: now.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
  );
}

final dateTimeSelectProvider = StateNotifierProvider.autoDispose<DateTimeSelectProvider, DateTimeSelect>((ref) {
  return DateTimeSelectProvider(getCurrentMonthDateRange());
});

final selectedDaysDateArrayProvider = StateProvider.autoDispose<List<DateTime>>((ref) {
  final DateTimeSelect dateTimeSelect = ref.watch(dateTimeSelectProvider);
  final DateTime start = DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.start * 1000);
  final DateTime end = DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.end * 1000);
  final List<DateTime> selectedDays = [];
  for (int i = 0; i <= end.difference(start).inDays; i++) {
    selectedDays.add(DateTime(start.year, start.month, start.day).add(Duration(days: i)));
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

DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

final bitcoinFeeSpentPerDayProvider = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  final List<DateTime> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(bitcoinTransactionsByDate);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<DateTime, num> valueSpentPerDay = {};

  for (DateTime day in selectedDays) {
    valueSpentPerDay[normalizeDate(day)] = 0;
  }

  for (TransactionDetails transaction in transactions) {
    if (transaction.sent > 0) {
      final DateTime date = normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.confirmationTime!.timestamp * 1000));
      if (selectedDays.contains(date)) {
        valueSpentPerDay[date] = valueSpentPerDay[date]! + transaction.fee!;
      }
    }
  }

  num cumulativeFee = 0;
  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);
    cumulativeFee += valueSpentPerDay[normalizedDay]!;
    valueSpentPerDay[normalizedDay] = btcInDenominationNum(cumulativeFee, btcFormat);
  }

  return valueSpentPerDay;
});

final bitcoinIncomePerDayProvider = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  final List<DateTime> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(bitcoinTransactionsByDate);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<DateTime, num> valueIncomePerDay = {};

  for (DateTime day in selectedDays) {
    valueIncomePerDay[normalizeDate(day)] = 0;
  }

  for (TransactionDetails transaction in transactions) {
    final DateTime date = normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.confirmationTime!.timestamp * 1000));
    if (selectedDays.contains(date)) {
      valueIncomePerDay[date] = valueIncomePerDay[date]! + transaction.received;
    }
  }

  num cumulativeIncome = 0;
  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);
    cumulativeIncome += valueIncomePerDay[normalizedDay]!;
    valueIncomePerDay[normalizedDay] = btcInDenominationNum(cumulativeIncome, btcFormat);
  }

  return valueIncomePerDay;
});

final bitcoinSpentPerDayProvider = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  final List<DateTime> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(bitcoinTransactionsByDate);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<DateTime, num> valueSpentPerDay = {};

  for (DateTime day in selectedDays) {
    valueSpentPerDay[normalizeDate(day)] = 0;
  }

  for (TransactionDetails transaction in transactions) {
    final DateTime date = normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.confirmationTime!.timestamp * 1000));
    if (selectedDays.contains(date)) {
      valueSpentPerDay[date] = valueSpentPerDay[date]! + transaction.sent;
    }
  }

  num cumulativeSpent = 0;
  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);
    cumulativeSpent += valueSpentPerDay[normalizedDay]!;
    valueSpentPerDay[normalizedDay] = btcInDenominationNum(cumulativeSpent, btcFormat);
  }

  return valueSpentPerDay;
});

final bitcoinBalanceOverPeriod = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  final transactions = ref.watch(transactionNotifierProvider).bitcoinTransactions;
  final Map<DateTime, num> balancePerDay = {};

  transactions.sort((a, b) => a.confirmationTime!.timestamp.compareTo(b.confirmationTime!.timestamp));

  num cumulativeBalance = 0;

  for (TransactionDetails transaction in transactions) {
    if (transaction.confirmationTime == null) {
      continue;
    }

    final DateTime date = normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.confirmationTime!.timestamp * 1000));
    var netAmount = transaction.received - transaction.sent;

    cumulativeBalance += netAmount;
    balancePerDay[date] = cumulativeBalance;
  }

  return balancePerDay;
});

final bitcoinBalanceOverPeriodByDayProvider = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  final DateTimeSelect dateTimeSelect = ref.watch(dateTimeSelectProvider);
  final DateTime start = normalizeDate(DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.start * 1000));
  final DateTime end = normalizeDate(DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.end * 1000));
  final balanceOverPeriod = ref.watch(bitcoinBalanceOverPeriod);
  final selectedDays = ref.watch(selectedDaysDateArrayProvider);

  final Map<DateTime, num> balancePerDay = {};
  num lastKnownBalance = 0;

  if (balanceOverPeriod.isEmpty || selectedDays.isEmpty) {
    return balancePerDay; // Return empty map if there's no data
  }

  for (var entry in balanceOverPeriod.entries) {
    final balanceDate = entry.key;
    if (balanceDate.isAfter(start) && balanceDate.isBefore(end.add(const Duration(days: 1)))) {
      lastKnownBalance = entry.value;
      balancePerDay[balanceDate] = lastKnownBalance;
    }
  }

  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);
    if (!balancePerDay.containsKey(normalizedDay)) {
      if (normalizedDay.isBefore(balanceOverPeriod.keys.first)) {
        balancePerDay[normalizedDay] = balanceOverPeriod[balanceOverPeriod.keys.first]!;
      } else if (normalizedDay.isAfter(balanceOverPeriod.keys.last)) {
        balancePerDay[normalizedDay] = balanceOverPeriod[balanceOverPeriod.keys.last]!;
      } else {
        balancePerDay[normalizedDay] = lastKnownBalance;
      }
    } else {
      lastKnownBalance = balancePerDay[normalizedDay]!;
    }
  }
  if (balancePerDay.keys.last.isBefore(selectedDays.last)) {
    for (DateTime day = balancePerDay.keys.last.add(const Duration(days: 1)); day.isBefore(selectedDays.last.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
      balancePerDay[day] = lastKnownBalance;
    }
  }

  return balancePerDay;
});

final bitcoinBalanceInFormatByDayProvider = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  final balanceByDay = ref.watch(bitcoinBalanceOverPeriodByDayProvider);
  final btcFormat = ref.watch(settingsProvider).btcFormat;

  final Map<DateTime, num> balanceInFormatByDay = {};

  for (DateTime day in balanceByDay.keys) {
    balanceInFormatByDay[day] = btcInDenominationNum(balanceByDay[day]!, btcFormat);
  }

  return Map.fromEntries(balanceInFormatByDay.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
});

final bitcoinBalanceInBtcByDayProvider = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  final balanceByDay = ref.watch(bitcoinBalanceOverPeriodByDayProvider);

  final Map<DateTime, num> balanceInBtcByDay = {};

  for (DateTime day in balanceByDay.keys) {
    balanceInBtcByDay[day] = btcInDenominationNum(balanceByDay[day]!, 'BTC');
  }

  return balanceInBtcByDay;
});

final liquidFeePerDayProvider = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final List<DateTime> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(liquidTransactionsByDate);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<DateTime, num> valueSpentPerDay = {};

  for (DateTime day in selectedDays) {
    valueSpentPerDay[normalizeDate(day)] = 0;
  }

  for (Tx transaction in transactions) {
    if (transaction.timestamp != 0) {
      final DateTime date = normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000));
      final hasSentFromAsset = transaction.balances.any((element) => element.assetId == asset && element.value < 0);
      if (selectedDays.contains(date) && hasSentFromAsset) {
        valueSpentPerDay[date] = valueSpentPerDay[date]! + transaction.fee.abs();
      }
    }
  }

  num cumulativeFee = 0;
  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);
    cumulativeFee += valueSpentPerDay[normalizedDay]!;
    valueSpentPerDay[normalizedDay] = btcInDenominationNum(cumulativeFee, btcFormat);
  }

  return valueSpentPerDay;
});

final liquidIncomePerDayProvider = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final List<DateTime> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(liquidTransactionsByDate);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<DateTime, num> valueIncomePerDay = {};

  for (DateTime day in selectedDays) {
    valueIncomePerDay[normalizeDate(day)] = 0;
  }

  for (Tx transaction in transactions) {
    if (transaction.timestamp != 0) {
      final DateTime date = normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000));
      final hasReceivedAsset = transaction.balances.any((element) => element.assetId == asset && element.value > 0);
      final assetIsBtc = asset == AssetMapper.reverseMapTicker(AssetId.LBTC);
      if (selectedDays.contains(date) && hasReceivedAsset) {
        valueIncomePerDay[date] = btcInDenominationNum(valueIncomePerDay[date]! + transaction.balances.firstWhere((element) => element.assetId == asset).value, btcFormat, assetIsBtc);
      }
    }
  }

  num cumulativeIncome = 0;
  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);
    cumulativeIncome += valueIncomePerDay[normalizedDay]!;
    valueIncomePerDay[normalizedDay] = cumulativeIncome;
  }

  return valueIncomePerDay;
});

final liquidSpentPerDayProvider = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final List<DateTime> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(liquidTransactionsByDate);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<DateTime, num> valueSpentPerDay = {};

  for (DateTime day in selectedDays) {
    valueSpentPerDay[normalizeDate(day)] = 0;
  }

  for (Tx transaction in transactions) {
    if (transaction.timestamp != 0) {
      final DateTime date = normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000));
      final hasSentAsset = transaction.balances.any((element) => element.assetId == asset && element.value < 0);
      final assetIsBtc = asset == AssetMapper.reverseMapTicker(AssetId.LBTC);
      if (selectedDays.contains(date) && hasSentAsset) {
        valueSpentPerDay[date] = btcInDenominationNum(valueSpentPerDay[date]! + transaction.balances.firstWhere((element) => element.assetId == asset).value.abs(), btcFormat, assetIsBtc);
      }
    }
  }

  num cumulativeSpent = 0;
  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);
    cumulativeSpent += valueSpentPerDay[normalizedDay]!;
    valueSpentPerDay[normalizedDay] = cumulativeSpent;
  }

  return valueSpentPerDay;
});

final liquidBalanceOverPeriodByDayProvider = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final List<DateTime> selectedDays = ref.watch(selectedDaysDateArrayProvider);
  final transactions = ref.watch(transactionNotifierProvider).liquidTransactions;
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final Map<DateTime, num> balancePerDay = {};

  for (DateTime day in selectedDays) {
    balancePerDay[normalizeDate(day)] = 0;
  }

  transactions.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

  for (Tx transaction in transactions) {
    if (transaction.timestamp != 0) {
      final DateTime date = normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000));

      final hasAsset = transaction.balances.any((element) => element.assetId == asset);
      if (selectedDays.contains(date) && hasAsset) {
        final sentValue = transaction.balances.firstWhere((element) => element.assetId == asset && element.value < 0, orElse: () => Balance(assetId: asset, value: 0)).value;
        final receivedValue = transaction.balances.firstWhere((element) => element.assetId == asset && element.value > 0, orElse: () => Balance(assetId: asset, value: 0)).value;
        final netAmount = receivedValue - sentValue;
        final assetIsBtc = asset == AssetMapper.reverseMapTicker(AssetId.LBTC);
        balancePerDay[date] = balancePerDay[date]! + btcInDenominationNum(netAmount, btcFormat, assetIsBtc);
      }
    }
  }

  return balancePerDay;
});
