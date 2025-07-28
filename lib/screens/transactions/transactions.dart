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
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedFilter = 'All';

  // 1. Manage the state locally within the widget
  AsyncValue<Transaction> _transactionState = const AsyncValue.loading();

  @override
  void initState() {
    super.initState();
    // 2. Trigger the one-time fetch when the widget is first created.
    _fetchInitialTransactions();
  }

  Future<void> _fetchInitialTransactions() async {
    try {
      // Use ref.read to get the future from the provider and await its result.
      final transactions = await ref.read(transactionNotifierProvider.future);
      if (mounted) {
        // Update the local state with the fetched data.
        setState(() {
          _transactionState = AsyncValue.data(transactions);
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        // If an error occurs, update the local state to show the error.
        setState(() {
          _transactionState = AsyncValue.error(e, stackTrace);
        });
      }
    }
  }

  bool isPending(BaseTransaction tx) {
    return (tx is SideShiftTransaction && (tx.details.status == 'waiting' || tx.details.status == 'expired')) ||
        (tx is EulenTransaction &&
            (tx.details.failed ||
                tx.details.status == 'expired' ||
                tx.details.status == 'pending')) ||
        (tx is NoxTransaction &&
            (tx.details.status == 'quote' ||
                tx.details.status == 'failed')) ||
        (tx is LightningConversionTransaction && !tx.isConfirmed);
  }

  List<BaseTransaction> applyDateFilter(List<BaseTransaction> transactions) {
    if (_startDate != null && _endDate != null) {
      return transactions.where((tx) {
        final txDate = tx.timestamp.toLocal();
        final startDate = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        final endDate = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        return !txDate.isBefore(startDate) && !txDate.isAfter(endDate);
      }).toList();
    }
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    // 3. Use the local state variable instead of watching the provider.
    return _transactionState.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Error: $err')),
      ),
      data: (transactionData) {
        // The rest of the build method remains the same...
        final allTransactions = transactionData.allTransactionsSorted;
        final startDate = _startDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final endDate = _endDate ?? DateTime.now();
        final dateRange = DateTimeSelect(start: startDate, end: endDate);

        List<BaseTransaction> filteredTransactions;

        if (_selectedFilter == 'Expired and Pending') {
          filteredTransactions = applyDateFilter(allTransactions).where(isPending).toList();
        } else {
          List<BaseTransaction> tempTransactions;
          switch (_selectedFilter) {
            case 'All':
              tempTransactions = applyDateFilter(allTransactions);
              break;
            case 'Bitcoin':
              tempTransactions = transactionData.filterBitcoinTransactions(dateRange);
              break;
            case 'Liquid':
              tempTransactions = transactionData.filterLiquidTransactions(dateRange);
              break;
            case 'Purchases and Sales':
              tempTransactions = transactionData.buyAndSell(dateRange);
              break;
            case 'Swaps':
              tempTransactions = applyDateFilter(transactionData.filterSwapTransactions());
              break;
            case 'DePIX':
              tempTransactions = applyDateFilter(
                transactionData.filterLiquidTransactionsByAssetId(AssetMapper.reverseMapTicker(AssetId.BRL)),
              );
              break;
            case 'USDT':
              tempTransactions = applyDateFilter(
                transactionData.filterLiquidTransactionsByAssetId(AssetMapper.reverseMapTicker(AssetId.USD)),
              );
              break;
            case 'EUR':
              tempTransactions = applyDateFilter(
                transactionData.filterLiquidTransactionsByAssetId(AssetMapper.reverseMapTicker(AssetId.EUR)),
              );
              break;
            default:
              tempTransactions = applyDateFilter(allTransactions);
          }
          filteredTransactions = tempTransactions.where((tx) => !isPending(tx)).toList();
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
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      elevation: 0,
                      actions: [
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
                        Theme(
                          data: Theme.of(context).copyWith(
                            popupMenuTheme: PopupMenuThemeData(
                              color: const Color(0xFF212121),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.sort, color: Colors.white, size: 24.sp),
                            onSelected: (String value) {
                              setState(() {
                                _selectedFilter = value;
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
                                value: 'Expired and Pending',
                                child: Text(
                                  'Expired and Pending'.i18n,
                                  style: TextStyle(
                                    color: _selectedFilter == 'Expired and Pending' ? Colors.orange : Colors.white,
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
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              minimumSize: const Size(60, 30),
                            ),
                            child: Text('Reset'.i18n, style: TextStyle(color: Colors.black, fontSize: 16.0.sp)),
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
      },
    );
  }
}