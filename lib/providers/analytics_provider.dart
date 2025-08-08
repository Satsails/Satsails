import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/transactions_model.dart';
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
  final DateTime start = DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.start * 1000).toLocal();
  final DateTime currentDay = DateTime.now().toLocal();
  final DateTime end = DateTime.fromMillisecondsSinceEpoch(dateTimeSelect.end * 1000).toLocal();

  // Use current day as end if it's after the provided end
  final effectiveEnd = currentDay.isAfter(end) ? currentDay : end;

  final List<DateTime> selectedDays = [];
  for (int i = 0; i <= effectiveEnd.difference(start).inDays; i++) {
    selectedDays.add(start.add(Duration(days: i)));
  }
  return selectedDays;
});


DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

final bitcoinBalanceOverPeriod = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  final transactionsAsync = ref.watch(transactionNotifierProvider);
  if (!transactionsAsync.hasValue) {
    return {};
  }

  final transactionData = transactionsAsync.value!;
  final transactions = transactionData.bitcoinTransactions;
  final Map<DateTime, num> balancePerDay = {};

  transactions.sort((a, b) {
    if (a.btcDetails.confirmationTime == null && b.btcDetails.confirmationTime  == null) {
      return 0;
    } else if (a.btcDetails.confirmationTime  == null) {
      return -1;
    } else if (b.btcDetails.confirmationTime  == null) {
      return 1;
    } else {
      return a.btcDetails.confirmationTime!.timestamp.compareTo(b.btcDetails.confirmationTime!.timestamp);
    }
  });

  num cumulativeBalance = 0;
  for (BitcoinTransaction transaction in transactions) {
    if (transaction.btcDetails.confirmationTime  == null || transaction.btcDetails.confirmationTime!.timestamp == 0) {
      continue;
    }

    final DateTime date = transaction.btcDetails.confirmationTime  == null || transaction.btcDetails.confirmationTime!.timestamp == 0
        ? normalizeDate(DateTime.now())
        : normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.btcDetails.confirmationTime!.timestamp.toInt() * 1000));
    var netAmount = transaction.btcDetails.received - transaction.btcDetails.sent;

    cumulativeBalance += netAmount.toInt();
    balancePerDay[date] = cumulativeBalance;
  }

  return balancePerDay;
});

final bitcoinBalanceOverPeriodByDayProvider = StateProvider.autoDispose<Map<DateTime, num>>((ref) {
  final balanceOverPeriod = ref.watch(bitcoinBalanceOverPeriod);
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
  final balanceByDay = ref.watch(bitcoinBalanceOverPeriodByDayProvider);
  final btcFormat = ref.watch(settingsProvider).btcFormat;

  final Map<DateTime, num> balanceInFormatByDay = {};

  for (DateTime day in balanceByDay.keys) {
    balanceInFormatByDay[day] = btcInDenominationNum(balanceByDay[day]!, btcFormat);
  }

  return Map.fromEntries(balanceInFormatByDay.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
});

final liquidBalanceOverPeriod = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final transactionsAsync = ref.watch(transactionNotifierProvider);
  if (!transactionsAsync.hasValue) {
    return {};
  }

  final transactions = transactionsAsync.value!.liquidTransactions;
  final balancePerDay = <DateTime, num>{};

  transactions.sort((a, b) {
    if (a.timestamp == null && b.timestamp == null) return 0;
    if (a.timestamp == null) return -1;
    if (b.timestamp == null) return 1;
    return a.timestamp.compareTo(b.timestamp);
  });

  num cumulativeBalance = 0;
  for (final transaction in transactions) {
    if (transaction.timestamp == null || transaction.timestamp.millisecondsSinceEpoch == 0) {
      continue;
    }

    num netAmount = 0;
    for (final balance in transaction.lwkDetails.balances) {
      if (balance.assetId == asset) {
        netAmount += balance.value;
      }
    }

    if (netAmount != 0) {
      final date = normalizeDate(transaction.timestamp);
      cumulativeBalance += netAmount;
      balancePerDay[date] = cumulativeBalance;
    }
  }
  return balancePerDay;
});

final liquidBalanceOverPeriodByDayProvider = StateProvider.autoDispose.family<Map<DateTime, num>, String>((ref, asset) {
  final balanceOverPeriod = ref.watch(liquidBalanceOverPeriod(asset));
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
  final balanceByDay = ref.watch(liquidBalanceOverPeriodByDayProvider(asset));
  final isBtc = asset == AssetMapper.reverseMapTicker(AssetId.LBTC);
  final btcFormat = ref.read(settingsProvider).btcFormat;

  final Map<DateTime, num> balanceInFormatByDay = {};

  for (DateTime day in balanceByDay.keys) {
    balanceInFormatByDay[day] = btcInDenominationNum(balanceByDay[day]!, btcFormat, isBtc);
  }

  return balanceInFormatByDay;
});