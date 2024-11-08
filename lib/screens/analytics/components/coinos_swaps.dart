import 'package:Satsails/models/coinos_ln_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/coinos.provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CoinosPaymentsList extends ConsumerWidget {
  const CoinosPaymentsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ref.watch(getPaymentsProvider).when(
      data: (payments) => payments.isEmpty
          ? Center(
        child: Text(
          'No swaps found'.i18n(ref),
          style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: payments.length,
        itemBuilder: (context, index) => _buildPaymentItem(payments[index], context, ref, screenWidth),
      ),
      loading: () => Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          color: Colors.orange,
          size: screenWidth * 0.1,
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error', style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white)),
      ),
    );
  }

  Widget _buildPaymentItem(CoinosPayment payment, BuildContext context, WidgetRef ref, double screenWidth) {

    // Check if payment represents a "sent" or "received" transaction
    final bool isSentToLightning = payment.amount != null && payment.amount! > 0;
    final String transactionType = isSentToLightning ? 'Sent'.i18n(ref) : 'Received'.i18n(ref);
    final String receiveType = transactionType == 'Sent'.i18n(ref) ? 'lightning' : payment.type ?? 'N/A';
    final String sentType = transactionType == 'Received'.i18n(ref) ? 'lightning' : payment.type ?? 'N/A';

    if (sentType == receiveType || sentType == 'internal' || receiveType == 'internal') {
      return SizedBox.shrink();
    }

    // Define common text styles
    final TextStyle titleStyle = TextStyle(
      fontSize: screenWidth * 0.05,
      color: Colors.grey,
    );
    final TextStyle subtitleStyle = TextStyle(
      fontSize: screenWidth * 0.04,
      color: Colors.white,
    );
    final TextStyle amountStyle = TextStyle(
      fontSize: screenWidth * 0.045,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02, horizontal: screenWidth * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 29, 29, 29),
        borderRadius: BorderRadius.circular(screenWidth * 0.0375),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _formatTimestamp(payment.created),
                style: titleStyle,
              ),
              Spacer(),
              Icon(
                Icons.swap_horiz,
                color: Colors.orange,
                size: screenWidth * 0.08,
              ),
            ],
          ),
          Divider(color: Colors.grey[700], thickness: 0.5),
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  sentType,
                  style: subtitleStyle,
                ),

                SizedBox(width: screenWidth * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      transactionType,
                      style: subtitleStyle,
                    ),
                    Text(
                      "${payment.amount?.abs() ?? 0}",
                      style: amountStyle,
                    ),
                  ],
                ),
                Text(
                  receiveType,
                  style: subtitleStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'N/A';
    return "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }
}

// improve later
class PaymentDetailsScreen extends StatelessWidget {
  final CoinosPayment payment;

  const PaymentDetailsScreen({Key? key, required this.payment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Details"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID: ${payment.id ?? 'N/A'}", style: TextStyle(color: Colors.white)),
            Text("Amount: ${payment.amount ?? 0} satoshis", style: TextStyle(color: Colors.white)),
            Text("Currency: ${payment.currency ?? 'BTC'}", style: TextStyle(color: Colors.white)),
            Text("Memo: ${payment.memo ?? 'N/A'}", style: TextStyle(color: Colors.white)),
            Text("Confirmed: ${payment.confirmed == true ? 'Yes' : 'No'}", style: TextStyle(color: Colors.white)),
            Text("Created At: ${_formatTimestamp(payment.created)}", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'N/A';
    return "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
  }
}
