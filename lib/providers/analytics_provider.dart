import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/coinos_ln_model.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/datetime_range_model.dart';
import 'package:lwk/lwk.dart' as lwk;

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

final bitcoinBalanceOverPeriod = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  final transactions = ref.read(transactionNotifierProvider).bitcoinTransactions;
  final Map<DateTime, num> balancePerDay = {};

  transactions.sort((a, b) {
    if (a.btcDetails.confirmationTime == null && b.btcDetails.confirmationTime  == null) {
      return 0;
    } else if (a.btcDetails.confirmationTime  == null) {
      return -1;
    } else if (b.btcDetails.confirmationTime  == null) {
      return 1;
    } else {
      return a.btcDetails.confirmationTime !.timestamp.compareTo(b.btcDetails.confirmationTime !.timestamp);
    }
  });

  num cumulativeBalance = 0;

  for (BitcoinTransaction transaction in transactions) {
    if (transaction.btcDetails.confirmationTime  == null || transaction.btcDetails.confirmationTime !.timestamp == 0) {
      continue;
    }

    final DateTime date = transaction.btcDetails.confirmationTime  == null || transaction.btcDetails.confirmationTime !.timestamp == 0
        ? normalizeDate(DateTime.now())
        : normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.btcDetails.confirmationTime!.timestamp.toInt() * 1000));
    var netAmount = transaction.btcDetails.received - transaction.btcDetails.sent;

    cumulativeBalance += netAmount.toInt();
    balancePerDay[date] = cumulativeBalance;
  }

  return balancePerDay;
});

final bitcoinBalanceOverPeriodByDayProvider = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  final balanceOverPeriod = ref.read(bitcoinBalanceOverPeriod);
  final selectedDays = ref.watch(selectedDaysDateArrayProvider);

  final Map<DateTime, num> balancePerDay = {};
  num lastKnownBalance = 0;

  if (balanceOverPeriod.isEmpty) {
    return balancePerDay;
  }

  // Get the first day in the balance period and set it to 0 balance one day before
  DateTime firstDay = balanceOverPeriod.keys.first.subtract(const Duration(days: 1));
  balancePerDay[normalizeDate(firstDay)] = 0;

  // Iterate through the balance over period to fill in the days
  for (var entry in balanceOverPeriod.entries) {
    DateTime balanceDate = entry.key;
    num balanceValue = entry.value;

    // Fill the days between the last known balance date and this balance date with the last known balance
    while (firstDay.isBefore(balanceDate)) {
      balancePerDay[normalizeDate(firstDay)] = lastKnownBalance;
      firstDay = firstDay.add(const Duration(days: 1));
    }

    // Update the last known balance with the current balance value
    lastKnownBalance = balanceValue;
    balancePerDay[normalizeDate(balanceDate)] = lastKnownBalance;
  }

  // Continue filling until the current date with the last known balance
  DateTime today = normalizeDate(DateTime.now());
  while (firstDay.isBefore(today) || firstDay.isAtSameMomentAs(today)) {
    balancePerDay[normalizeDate(firstDay)] = lastKnownBalance;
    firstDay = firstDay.add(const Duration(days: 1));
  }

  // Filter the result to only include selected days
  final Map<DateTime, num> selectedBalancePerDay = {};
  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);
    if (balancePerDay.containsKey(normalizedDay)) {
      selectedBalancePerDay[normalizedDay] = balancePerDay[normalizedDay]!;
    }
  }

  return selectedBalancePerDay;
});


final bitcoinBalanceInFormatByDayProvider = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  final balanceByDay = ref.read(bitcoinBalanceOverPeriodByDayProvider);
  final btcFormat = ref.watch(settingsProvider).btcFormat;

  final Map<DateTime, num> balanceInFormatByDay = {};

  for (DateTime day in balanceByDay.keys) {
    balanceInFormatByDay[day] = btcInDenominationNum(balanceByDay[day]!, btcFormat);
  }

  return Map.fromEntries(balanceInFormatByDay.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
});

final liquidBalanceOverPeriod = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final transactions = ref.read(transactionNotifierProvider).liquidTransactions;
  final Map<DateTime, num> balancePerDay = {};

  transactions.sort((a, b) {
    if (a.timestamp == null && b.timestamp == null) {
      return 0;
    } else {
      return a.timestamp.compareTo(b.timestamp);
    }

  });

  num cumulativeBalance = 0;

  for (LiquidTransaction transaction in transactions) {
    if (transaction.timestamp == 0) {
      continue;
    }

    final DateTime date = normalizeDate(transaction.timestamp);
    final hasSentAsset = transaction.lwkDetails.balances.any((element) => element.assetId == asset && element.value < 0);
    final hasReceivedAsset = transaction.lwkDetails.balances.any((element) => element.assetId == asset && element.value > 0);
    if (hasSentAsset || hasReceivedAsset) {
      final sentValue = transaction.lwkDetails.balances.firstWhere((element) => element.assetId == asset && element.value < 0, orElse: () => lwk.Balance(assetId: asset, value: 0)).value;
      final receivedValue = transaction.lwkDetails.balances.firstWhere((element) => element.assetId == asset && element.value > 0, orElse: () => lwk.Balance(assetId: asset, value: 0)).value;
      final netAmount = receivedValue + sentValue;

      cumulativeBalance += netAmount;
      balancePerDay[date] = cumulativeBalance;
    }
  }

  return balancePerDay;
});

final liquidBalanceOverPeriodByDayProvider = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final balanceOverPeriod = ref.read(liquidBalanceOverPeriod(asset));
  final selectedDays = ref.watch(selectedDaysDateArrayProvider);

  final Map<DateTime, num> balancePerDay = {};
  num lastKnownBalance = 0;

  if (balanceOverPeriod.isEmpty) {
    return balancePerDay;
  }

  // Get the first day in the balance period and set it to 0 balance one day before
  DateTime firstDay = balanceOverPeriod.keys.first.subtract(const Duration(days: 1));
  balancePerDay[normalizeDate(firstDay)] = 0;

  // Iterate through the balance over period to fill in the days
  for (var entry in balanceOverPeriod.entries) {
    DateTime balanceDate = entry.key;
    num balanceValue = entry.value;

    // Fill the days between the last known balance date and this balance date with the last known balance
    while (firstDay.isBefore(balanceDate)) {
      balancePerDay[normalizeDate(firstDay)] = lastKnownBalance;
      firstDay = firstDay.add(const Duration(days: 1));
    }

    // Update the last known balance with the current balance value
    lastKnownBalance = balanceValue;
    balancePerDay[normalizeDate(balanceDate)] = lastKnownBalance;
  }

  // Continue filling until the current date with the last known balance
  DateTime today = normalizeDate(DateTime.now());
  while (firstDay.isBefore(today) || firstDay.isAtSameMomentAs(today)) {
    balancePerDay[normalizeDate(firstDay)] = lastKnownBalance;
    firstDay = firstDay.add(const Duration(days: 1));
  }

  // Filter the result to only include selected days
  final Map<DateTime, num> selectedBalancePerDay = {};
  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);
    if (balancePerDay.containsKey(normalizedDay)) {
      selectedBalancePerDay[normalizedDay] = balancePerDay[normalizedDay]!;
    }
  }

  return selectedBalancePerDay;
});

final liquidBalancePerDayInFormatProvider = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final balanceByDay = ref.read(liquidBalanceOverPeriodByDayProvider(asset));
  final isBtc = asset == AssetMapper.reverseMapTicker(AssetId.LBTC);
  final btcFormat = ref.read(settingsProvider).btcFormat;

  final Map<DateTime, num> balanceInFormatByDay = {};

  for (DateTime day in balanceByDay.keys) {
    balanceInFormatByDay[day] = btcInDenominationNum(balanceByDay[day]!, btcFormat, isBtc);
  }

  return balanceInFormatByDay;
});

// Provider to compute cumulative Lightning balance over time
final lightningBalanceOverPeriod = FutureProvider.autoDispose<Map<DateTime, num>>((ref) async {
  final transactions = await ref.read(getTransactionsProvider.future).then(
        (value) => value as List<CoinosPayment>?,
  );

  final Map<DateTime, num> balancePerDay = {};

  if (transactions == null || transactions.isEmpty) {
    return balancePerDay;
  }

  // Sort transactions by created date
  transactions.sort((a, b) {
    if (a.created == null && b.created == null) {
      return 0;
    } else if (a.created == null) {
      return -1;
    } else if (b.created == null) {
      return 1;
    } else {
      return a.created!.compareTo(b.created!);
    }
  });

  num cumulativeBalance = 0;

  for (CoinosPayment transaction in transactions) {
    if (transaction.created == null) {
      continue;
    }

    final DateTime date = normalizeDate(transaction.created!);

    num amount = transaction.amount ?? 0;

    cumulativeBalance += amount;

    balancePerDay[date] = cumulativeBalance;
  }

  return balancePerDay;
});

// Provider to map the cumulative balance over selected days
final lightningBalanceOverPeriodByDayProvider = FutureProvider.autoDispose<Map<DateTime, num>>((ref) async {
  final balanceOverPeriod = await ref.read(lightningBalanceOverPeriod.future);
  final selectedDays = ref.watch(selectedDaysDateArrayProvider);

  final Map<DateTime, num> balancePerDay = {};
  num lastKnownBalance = 0;

  if (balanceOverPeriod.isEmpty) {
    return balancePerDay;
  }

  // Get the first day in the balance period and set it to 0 balance one day before
  DateTime firstDay = balanceOverPeriod.keys.first.subtract(const Duration(days: 2));
  balancePerDay[normalizeDate(firstDay)] = 0;

  // Create a sorted list of dates
  List<DateTime> sortedDates = balanceOverPeriod.keys.toList()..sort();

  int dateIndex = 0;

  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);

    // Update lastKnownBalance if the transaction date matches or is before the current day
    while (dateIndex < sortedDates.length && !sortedDates[dateIndex].isAfter(normalizedDay)) {
      lastKnownBalance = balanceOverPeriod[sortedDates[dateIndex]]!;
      dateIndex++;
    }

    balancePerDay[normalizedDay] = lastKnownBalance;
  }

  return balancePerDay;
});