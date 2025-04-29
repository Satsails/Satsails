import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/shared/transactions_builder.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class Transactions extends ConsumerStatefulWidget {
  const Transactions({super.key});

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends ConsumerState<Transactions> {
  DateTime? _startDate; // Stores the start date of the selected range
  DateTime? _endDate;   // Stores the end date of the selected range
  String _selectedFilter = 'All'; // Default filter set to 'All'

  @override
  Widget build(BuildContext context) {
    // Access transactions from the provider
    final transactionState = ref.watch(transactionNotifierProvider);
    final allTransactions = transactionState.allTransactionsSorted;

    // Define the date range for filtering
    final startDate = _startDate ?? DateTime.fromMillisecondsSinceEpoch(0); // Default: 1970-01-01
    final endDate = _endDate ?? DateTime.now(); // Default: current date/time
    final dateRange = DateTimeSelect(start: startDate, end: endDate);

    // Filter transactions based on date range and selected filter
    List<BaseTransaction> filteredTransactions = allTransactions;
    if (_startDate != null && _endDate != null) {
      filteredTransactions = filteredTransactions.where((tx) {
        return tx.timestamp.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            tx.timestamp.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }
    if (_selectedFilter != 'All') {
      switch (_selectedFilter) {
        case 'Bitcoin':
          filteredTransactions = transactionState.filterBitcoinTransactions(dateRange);
          break;
        case 'Liquid':
          filteredTransactions = transactionState.filterLiquidTransactions(dateRange);
          break;
        case 'Purchases and Sales':
          filteredTransactions = transactionState.buyAndSell(dateRange);
          break;
        case 'Swaps':
          filteredTransactions = transactionState.filterSwapTransactions();
          break;
        case 'DePIX':
          filteredTransactions = transactionState.filterLiquidTransactionsByAssetId(
            AssetMapper.reverseMapTicker(AssetId.BRL),
          );
          break;
        case 'USDT':
          filteredTransactions = transactionState.filterLiquidTransactionsByAssetId(
            AssetMapper.reverseMapTicker(AssetId.USD),
          );
          break;
        case 'EUR':
          filteredTransactions = transactionState.filterLiquidTransactionsByAssetId(
            AssetMapper.reverseMapTicker(AssetId.EUR),
          );
          break;
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.black,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  elevation: 0,
                  actions: [
                    // Calendar picker button
                    IconButton(
                      icon: Icon(Icons.calendar_today, color: Colors.white, size: 24.sp),
                      onPressed: () async {
                        final selectedDate = await showCalendarDatePicker2Dialog(
                          context: context,
                          config: CalendarDatePicker2WithActionButtonsConfig(
                            calendarType: CalendarDatePicker2Type.range,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            currentDate: _startDate ?? DateTime.now(),
                            dayTextStyle: const TextStyle(color: Colors.white),
                            weekdayLabelTextStyle: const TextStyle(color: Colors.white),
                            controlsTextStyle: const TextStyle(color: Colors.white),
                            selectedDayTextStyle: const TextStyle(color: Colors.black),
                            selectedDayHighlightColor: Colors.orange,
                            disabledDayTextStyle: const TextStyle(color: Colors.grey),
                            yearTextStyle: const TextStyle(color: Colors.white),
                            lastMonthIcon: const Icon(Icons.arrow_back, color: Colors.white),
                            nextMonthIcon: const Icon(Icons.arrow_forward, color: Colors.white),
                          ),
                          dialogSize: const Size(325, 400),
                          dialogBackgroundColor: const Color(0xFF212121),
                        );

                        if (selectedDate != null && selectedDate.isNotEmpty) {
                          setState(() {
                            _startDate = selectedDate.first;
                            _endDate = selectedDate.length > 1 ? selectedDate.last : selectedDate.first;
                          });
                        }
                      },
                    ),
                    // Filter menu button
                    Theme(
                      data: Theme.of(context).copyWith(
                        popupMenuTheme: PopupMenuThemeData(
                          color: Color(0xFF212121), // Dark background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0), // Rounded corners
                          ),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.sort, color: Colors.white, size: 24.sp),
                        onSelected: (String value) {
                          setState(() {
                            _selectedFilter = value; // Update filter on selection
                          });
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'All',
                            child: Text(
                              'All'.i18n,
                              style: TextStyle(
                                color: _selectedFilter == 'All' ? Colors.orange : Colors.white,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Bitcoin',
                            child: Text(
                              'Bitcoin',
                              style: TextStyle(
                                color: _selectedFilter == 'Bitcoin' ? Colors.orange : Colors.white,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Liquid',
                            child: Text(
                              'Liquid Bitcoin',
                              style: TextStyle(
                                color: _selectedFilter == 'Liquid' ? Colors.orange : Colors.white,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Purchases and Sales',
                            child: Text(
                              'Purchases and Sales'.i18n,
                              style: TextStyle(
                                color: _selectedFilter == 'Purchases and Sales' ? Colors.orange : Colors.white,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Swaps',
                            child: Text(
                              'Swaps'.i18n,
                              style: TextStyle(
                                color: _selectedFilter == 'Swaps' ? Colors.orange : Colors.white,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'DePIX',
                            child: Text(
                              'Depix',
                              style: TextStyle(
                                color: _selectedFilter == 'DePIX' ? Colors.orange : Colors.white,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'USDT',
                            child: Text(
                              'USDT',
                              style: TextStyle(
                                color: _selectedFilter == 'USDT' ? Colors.orange : Colors.white,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'EUR',
                            child: Text(
                              'EURx',
                              style: TextStyle(
                                color: _selectedFilter == 'EUR' ? Colors.orange : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Styled reset button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                            _selectedFilter = 'All';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          minimumSize: const Size(60, 30),
                        ),
                        child: Text('Reset'.i18n, style: TextStyle(color: Colors.white, fontSize: 16.0.sp)),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TransactionListByWeek(transactions: filteredTransactions),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}