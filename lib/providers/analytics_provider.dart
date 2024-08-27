import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/adapters/transaction_adapters.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/datetime_range_model.dart';

DateTimeSelect getCurrentMonthDateRange() {
  final DateTime now = DateTime.now();
  final startDate = now.subtract(const Duration(days: 30));
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
      final DateTime date = transaction.confirmationTime == null || transaction.confirmationTime!.timestamp == 0
          ? normalizeDate(DateTime.now())
          : normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.confirmationTime!.timestamp * 1000));
        valueSpentPerDay[date] = valueSpentPerDay[date]! + transaction.fee!;
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
    final DateTime date = transaction.confirmationTime == null || transaction.confirmationTime!.timestamp == 0
        ? normalizeDate(DateTime.now())
        : normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.confirmationTime!.timestamp * 1000));
      valueIncomePerDay[date] = valueIncomePerDay[date]! + transaction.received;
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
    final DateTime date = transaction.confirmationTime == null || transaction.confirmationTime!.timestamp == 0
        ? normalizeDate(DateTime.now())
        : normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.confirmationTime!.timestamp * 1000));
      valueSpentPerDay[date] = valueSpentPerDay[date]! + transaction.sent;
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

  transactions.sort((a, b) {
    if (a.confirmationTime == null && b.confirmationTime == null) {
      return 0;
    } else if (a.confirmationTime == null) {
      return -1;
    } else if (b.confirmationTime == null) {
      return 1;
    } else {
      return a.confirmationTime!.timestamp.compareTo(b.confirmationTime!.timestamp);
    }
  });

  num cumulativeBalance = 0;

  for (TransactionDetails transaction in transactions) {
    if (transaction.confirmationTime == null || transaction.confirmationTime!.timestamp == 0) {
      continue;
    }

    final DateTime date = transaction.confirmationTime == null || transaction.confirmationTime!.timestamp == 0
        ? normalizeDate(DateTime.now())
        : normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.confirmationTime!.timestamp * 1000));
    var netAmount = transaction.received - transaction.sent;

    cumulativeBalance += netAmount;
    balancePerDay[date] = cumulativeBalance;
  }

  return balancePerDay;
});

final bitcoinBalanceOverPeriodByDayProvider = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  // Set a historical range of 5 years before the selected start date.
  final DateTimeSelect dateTimeSelect = ref.watch(dateTimeSelectProvider);
  final DateTime historicalStart = normalizeDate(
    DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.start * 1000).subtract(const Duration(days: 365 * 5)),
  );
  final DateTime start = normalizeDate(DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.start * 1000));
  final DateTime end = normalizeDate(DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.end * 1000));

  final balanceOverPeriod = ref.watch(bitcoinBalanceOverPeriod);
  final selectedDays = ref.watch(selectedDaysDateArrayProvider);

  final Map<DateTime, num> balancePerDay = {};
  num lastKnownBalance = 0;

  if (balanceOverPeriod.isEmpty || selectedDays.isEmpty) {
    return balancePerDay; // Return an empty map if there's no data.
  }

  // Only process balances for the days present in selectedDays
  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);

    if (normalizedDay.isBefore(balanceOverPeriod.keys.first)) {
      // If the day is before the first transaction, the balance is 0.
      balancePerDay[normalizedDay] = 0;
    } else if (balanceOverPeriod.containsKey(normalizedDay)) {
      // If there is an exact match in balanceOverPeriod, use that balance.
      lastKnownBalance = balanceOverPeriod[normalizedDay]!;
      balancePerDay[normalizedDay] = lastKnownBalance;
    } else if (normalizedDay.isAfter(balanceOverPeriod.keys.last)) {
      // If the day is after the last known transaction, use the last known balance.
      balancePerDay[normalizedDay] = lastKnownBalance;
    } else {
      // If the day falls between known transactions, continue the last known balance.
      balancePerDay[normalizedDay] = lastKnownBalance;
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
      if (hasSentFromAsset) {
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
      if (hasReceivedAsset) {
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
      if (hasSentAsset) {
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

final liquidBalanceOverPeriod = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final transactions = ref.watch(transactionNotifierProvider).liquidTransactions;
  final Map<DateTime, num> balancePerDay = {};

  transactions.sort((a, b) {
    if (a.timestamp == null && b.timestamp == null) {
      return 0;
    } else if (a.timestamp == null) {
      return -1;
    } else if (b.timestamp == null) {
      return 1;
    } else {
      return a.timestamp!.compareTo(b.timestamp!);
    }
  });

  num cumulativeBalance = 0;

  for (Tx transaction in transactions) {
    if (transaction.timestamp == 0) {
      continue;
    }

    final DateTime date = normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000));
    final hasSentAsset = transaction.balances.any((element) => element.assetId == asset && element.value < 0);
    final hasReceivedAsset = transaction.balances.any((element) => element.assetId == asset && element.value > 0);
    if (hasSentAsset || hasReceivedAsset) {
      final sentValue = transaction.balances.firstWhere((element) => element.assetId == asset && element.value < 0, orElse: () => Balance(assetId: asset, value: 0)).value;
      final receivedValue = transaction.balances.firstWhere((element) => element.assetId == asset && element.value > 0, orElse: () => Balance(assetId: asset, value: 0)).value;
      final netAmount = receivedValue + sentValue;

      cumulativeBalance += netAmount;
      balancePerDay[date] = cumulativeBalance;
    }
  }

  return balancePerDay;
});

final liquidBalanceOverPeriodByDayProvider = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final DateTimeSelect dateTimeSelect = ref.watch(dateTimeSelectProvider);
  final DateTime start = normalizeDate(DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.start * 1000));
  final DateTime end = normalizeDate(DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.end * 1000));
  final Map<DateTime, num> balancePerDay = {};
  final balanceOverPeriod = ref.watch(liquidBalanceOverPeriod(asset));

  final selectedDays = ref.watch(selectedDaysDateArrayProvider);

  num lastKnownBalance = 0;

  if (balanceOverPeriod.isEmpty || selectedDays.isEmpty) {
    return balancePerDay;
  }

  if (selectedDays.any((day) => day.isBefore(balanceOverPeriod.keys.first))) {
    for (DateTime day in selectedDays.where((day) => day.isBefore(balanceOverPeriod.keys.first))) {
      balancePerDay[normalizeDate(day)] = 0;
    }
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
        balancePerDay[normalizedDay] = 0;
      } else if (normalizedDay.isAfter(balanceOverPeriod.keys.last)) {
        balancePerDay[normalizedDay] = balanceOverPeriod[balanceOverPeriod.keys.last]!;
      } else {
        balancePerDay[normalizedDay] = lastKnownBalance;
      }
    } else {
      lastKnownBalance = balancePerDay[normalizedDay]!;
    }
  }

  final orderedBalances = Map.fromEntries(balancePerDay.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));

  return orderedBalances;
});


final liquidBalancePerDayInBTCFormatProvider = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final balanceByDay = ref.watch(liquidBalanceOverPeriodByDayProvider(asset));
  final isBtc = asset == AssetMapper.reverseMapTicker(AssetId.LBTC);

  final Map<DateTime, num> balanceInFormatByDay = {};

  for (DateTime day in balanceByDay.keys) {
    balanceInFormatByDay[day] = btcInDenominationNum(balanceByDay[day]!, 'BTC', isBtc);
  }

  return balanceInFormatByDay;
});

final liquidBalancePerDayInFormatProvider = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final balanceByDay = ref.watch(liquidBalanceOverPeriodByDayProvider(asset));
  final isBtc = asset == AssetMapper.reverseMapTicker(AssetId.LBTC);
  final btcFormat = ref.watch(settingsProvider).btcFormat;

  final Map<DateTime, num> balanceInFormatByDay = {};

  for (DateTime day in balanceByDay.keys) {
    balanceInFormatByDay[day] = btcInDenominationNum(balanceByDay[day]!, btcFormat, isBtc);
  }

  return balanceInFormatByDay;
});


