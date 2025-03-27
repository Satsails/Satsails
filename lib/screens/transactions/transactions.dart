import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/shared/custom_bottom_navigation_bar.dart';
import 'package:Satsails/screens/shared/transactions_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        case 'Pix Purchases':
          filteredTransactions = transactionState.filterPixPurchases(dateRange);
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: ref.watch(navigationProvider),
          onTap: (int index) {
            ref.read(navigationProvider.notifier).state = index;
          },
        ),
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  AppBar(
                    title: const Text(
                      'Transactions',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    backgroundColor: Colors.black,
                    elevation: 0,
                    actions: [
                      // Calendar picker button
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.white),
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
                            color: const Color(0xFF212121), // Dark background
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0), // Rounded corners
                            ),
                          ),
                        ),
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.sort, color: Colors.white), // Sort icon
                          onSelected: (String value) {
                            setState(() {
                              _selectedFilter = value; // Update filter on selection
                            });
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'All',
                              child: Text(
                                'All',
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
                              value: 'Pix Purchases',
                              child: Text(
                                'Pix Purchases',
                                style: TextStyle(
                                  color: _selectedFilter == 'Pix Purchases' ? Colors.orange : Colors.white,
                                ),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'Swaps',
                              child: Text(
                                'Swaps',
                                style: TextStyle(
                                  color: _selectedFilter == 'Swaps' ? Colors.orange : Colors.white,
                                ),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'DePIX',
                              child: Text(
                                'DePIX',
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
                                'EUR',
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
                          child: const Text('Reset'),
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
      ),
    );
  }
}