import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk_dart/lwk_dart.dart' as lwk;
import 'package:satsails/providers/conversion_provider.dart';
import 'package:satsails/providers/transaction_search_provider.dart';

Widget buildTransactions(List transactions, BuildContext context, WidgetRef ref) {
  if (transactions.isEmpty) {
    return const Center(
      child: Text(
        'No transactions',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  return Container(
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      color: Colors.white,
    ),
    child: SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - kToolbarHeight,
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildTransactionItem(transactions[index], context, ref);
        },
      ),
    ),
  );
}

Widget _buildTransactionItem(transaction, BuildContext context, WidgetRef ref) {
  if (transaction is TransactionDetails) {
    return _buildBitcoinTransactionItem(transaction, context, ref);
  } else if (transaction is lwk.Tx) {
    return _buiildLiquidTransactionItem(transaction, context, ref);
  } else {
    return const SizedBox();
  }
}

Widget _buildBitcoinTransactionItem(TransactionDetails transaction, BuildContext context, WidgetRef ref) {
  return Column(
    children: [
      GestureDetector(
        onTap: () {
          ref.read(transactionSearchProvider).isLiquid = false;
          ref.read(transactionSearchProvider).transactionHash = transaction.txid;
          Navigator.pushNamed(context, '/search_modal');
        },
        child: ListTile(
          leading: _transactionType(transaction) == 'Sent' ? const Icon(Icons.arrow_upward, color: Colors.green) : const Icon(Icons.arrow_downward, color: Colors.red),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_transactionType(transaction), style: const TextStyle(fontSize: 16)),
              Text(_transactionAmount(transaction, ref), style: const TextStyle(fontSize: 14)),
            ],
          ),
          subtitle: Text("Fee: ${_transactionFee(transaction, ref)}", style: const TextStyle(fontSize: 14)),
          trailing: _confirmationStatus(transaction) == 'Confirmed'
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.access_alarm_outlined, color: Colors.red),
        ),
      )
    ],
  );
}

Widget _buiildLiquidTransactionItem(lwk.Tx transaction, BuildContext context, WidgetRef ref) {
  final balance = transaction.balances[0];
  final balance1 = balance.$1;
  return Column(
    children: [
      GestureDetector(
        onTap: () {
          ref.read(transactionSearchProvider).isLiquid = true;
          ref.read(transactionSearchProvider).transactionHash = transaction.txid;
          Navigator.pushNamed(context, '/search_modal');
        },
        child: ListTile(
          // leading: _transactionType(transaction) == 'Sent' ? const Icon(Icons.arrow_upward, color: Colors.green) : const Icon(Icons.arrow_downward, color: Colors.red),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(_transactionType(transaction), style: const TextStyle(fontSize: 16)),
              // Text(_transactionAmount(transaction, ref), style: const TextStyle(fontSize: 14)),
            ],
          ),
          // subtitle: Text("Fee: ${_transactionFee(transaction, ref)}", style: const TextStyle(fontSize: 14)),
          // trailing: _confirmationStatus(transaction) == 'Confirmed'
          //     ? const Icon(Icons.check_circle, color: Colors.green)
          //     : const Icon(Icons.access_alarm_outlined, color: Colors.red),
        ),
      )
    ],
  );
}

String _transactionType(TransactionDetails transaction){
  if (transaction.received == 0 && transaction.sent > 0) {
    return 'Sent';
  } else if (transaction.received > 0 && transaction.sent == 0) {
    return 'Received';
  } else {
    return 'Mixed';
  }
}

String _confirmationStatus(TransactionDetails transaction) {
  if (transaction.confirmationTime == null) {
    return 'Unconfirmed';
  } else if (transaction.confirmationTime != null) {
    return 'Confirmed';
  } else {
    return 'Unknown';
  }
}

String _transactionAmount(TransactionDetails transaction, WidgetRef ref) {
  if (transaction.received == 0 && transaction.sent > 0) {
    return ref.watch(conversionProvider(transaction.sent));
  } else if (transaction.received > 0 && transaction.sent == 0) {
    return ref.watch(conversionProvider(transaction.received));
  } else {
    int total = (transaction.received - transaction.sent).abs();
    return ref.watch(conversionProvider(total));
  }
}

String _transactionFee(TransactionDetails transaction, WidgetRef ref) {
  return ref.watch(conversionProvider(transaction.fee ?? 0));
}
