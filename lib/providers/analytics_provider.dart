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

final oneDay = StateProvider.autoDispose<bool>((ref) {
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
