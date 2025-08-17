import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final assetAllocationProvider = FutureProvider<Map<String, double>>((ref) async {
  final balance = ref.watch(balanceNotifierProvider);
  final rates = ref.watch(currencyNotifierProvider);
  final selectedCurrency = ref.watch(settingsProvider).currency;

  // This function can remain async if other rates are fetched async in the future
  double getBtcRate() {
    switch (selectedCurrency) {
      case 'EUR': return rates.btcToEur;
      case 'BRL': return rates.btcToBrl;
      case 'GBP': return rates.btcToGbp;
      case 'CHF': return rates.btcToChf;
      case 'USD':
      default:
        return rates.btcToUsd;
    }
  }

  double convertToSelectedCurrency(double amount, String fromCurrency) {
    if (fromCurrency == selectedCurrency) return amount;

    double amountInUsd;
    switch (fromCurrency) {
      case 'EUR': amountInUsd = amount * rates.eurToUsd; break;
      case 'BRL': amountInUsd = amount * rates.brlToUsd; break;
      case 'GBP': amountInUsd = amount * rates.gbpToUsd; break;
      case 'CHF': amountInUsd = amount * rates.chfToUsd; break;
      default: amountInUsd = amount;
    }

    switch (selectedCurrency) {
      case 'EUR': return amountInUsd * rates.usdToEur;
      case 'BRL': return amountInUsd * rates.usdToBrl;
      case 'GBP': return amountInUsd * rates.usdToGbp;
      case 'CHF': return amountInUsd * rates.usdToChf;
      default: return amountInUsd;
    }
  }

  final btcPrice = getBtcRate();
  final Map<String, double> allocation = {};

  final btcValue = (balance.onChainBtcBalance / 1e8) * btcPrice;
  if (btcValue > 0.01) allocation['BTC'] = btcValue;

  final lbtcValue = (balance.liquidBtcBalance / 1e8) * btcPrice;
  if (lbtcValue > 0.01) allocation['L-BTC'] = lbtcValue;

  final depixBalance = balance.liquidDepixBalance / 1e8;
  if (depixBalance > 0.01) {
    allocation['Depix'] = convertToSelectedCurrency(depixBalance, 'BRL');
  }
  final usdtBalance = balance.liquidUsdtBalance / 1e8;
  if (usdtBalance > 0.01) {
    allocation['USDT'] = convertToSelectedCurrency(usdtBalance, 'USD');
  }
  final eurxBalance = balance.liquidEuroxBalance / 1e8;
  if (eurxBalance > 0.01) {
    allocation['EURx'] = convertToSelectedCurrency(eurxBalance, 'EUR');
  }

  return allocation;
});

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
  final transactionData = ref.watch(transactionNotifierProvider);
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

    final DateTime date = normalizeDate(DateTime.fromMillisecondsSinceEpoch(transaction.btcDetails.confirmationTime!.timestamp.toInt() * 1000));
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
    for (DateTime day in selectedDays) {
      balancePerDay[normalizeDate(day)] = 0;
    }
    return balancePerDay;
  }

  DateTime firstDay = balanceOverPeriod.keys.first;

  for (var entry in balanceOverPeriod.entries) {
    DateTime balanceDate = entry.key;
    num balanceValue = entry.value;

    while (firstDay.isBefore(balanceDate)) {
      balancePerDay[normalizeDate(firstDay)] = lastKnownBalance;
      firstDay = firstDay.add(const Duration(days: 1));
    }

    lastKnownBalance = balanceValue;
    balancePerDay[normalizeDate(balanceDate)] = lastKnownBalance;
  }

  DateTime today = normalizeDate(DateTime.now());
  while (firstDay.isBefore(today) || firstDay.isAtSameMomentAs(today)) {
    balancePerDay[normalizeDate(firstDay)] = lastKnownBalance;
    firstDay = firstDay.add(const Duration(days: 1));
  }

  final Map<DateTime, num> selectedBalancePerDay = {};
  num lastBalanceForSelectedRange = 0;

  if (selectedDays.isNotEmpty) {
    final dayBeforeStart = normalizeDate(selectedDays.first.subtract(const Duration(days: 1)));
    lastBalanceForSelectedRange = balancePerDay[dayBeforeStart] ?? 0;
  }

  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);
    if (balancePerDay.containsKey(normalizedDay)) {
      selectedBalancePerDay[normalizedDay] = balancePerDay[normalizedDay]!;
      lastBalanceForSelectedRange = balancePerDay[normalizedDay]!;
    } else {
      selectedBalancePerDay[normalizedDay] = lastBalanceForSelectedRange;
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
  final transactions = ref.watch(transactionNotifierProvider).liquidTransactions;
  final balancePerDay = <DateTime, num>{};

  transactions.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  num cumulativeBalance = 0;
  for (final transaction in transactions) {
    if (transaction.timestamp.millisecondsSinceEpoch == 0) {
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
    for (DateTime day in selectedDays) {
      balancePerDay[normalizeDate(day)] = 0;
    }
    return balancePerDay;
  }

  DateTime firstDay = balanceOverPeriod.keys.first;

  for (var entry in balanceOverPeriod.entries) {
    DateTime balanceDate = entry.key;
    num balanceValue = entry.value;

    while (firstDay.isBefore(balanceDate)) {
      balancePerDay[normalizeDate(firstDay)] = lastKnownBalance;
      firstDay = firstDay.add(const Duration(days: 1));
    }

    lastKnownBalance = balanceValue;
    balancePerDay[normalizeDate(balanceDate)] = lastKnownBalance;
  }

  DateTime today = normalizeDate(DateTime.now());
  while (firstDay.isBefore(today) || firstDay.isAtSameMomentAs(today)) {
    balancePerDay[normalizeDate(firstDay)] = lastKnownBalance;
    firstDay = firstDay.add(const Duration(days: 1));
  }

  final Map<DateTime, num> selectedBalancePerDay = {};
  num lastBalanceForSelectedRange = 0;

  if (selectedDays.isNotEmpty) {
    final dayBeforeStart = normalizeDate(selectedDays.first.subtract(const Duration(days: 1)));
    lastBalanceForSelectedRange = balancePerDay[dayBeforeStart] ?? 0;
  }

  for (DateTime day in selectedDays) {
    final normalizedDay = normalizeDate(day);
    if (balancePerDay.containsKey(normalizedDay)) {
      selectedBalancePerDay[normalizedDay] = balancePerDay[normalizedDay]!;
      lastBalanceForSelectedRange = balancePerDay[normalizedDay]!;
    } else {
      selectedBalancePerDay[normalizedDay] = lastBalanceForSelectedRange;
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

  return Map.fromEntries(balanceInFormatByDay.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
});