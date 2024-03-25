import 'package:flutter/material.dart';

class Charge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charge Wallet'),
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PaymentMethodCard(
                title: 'Add Money with Pix',
                description: 'Coming Soon',
              ),
              SizedBox(height: 16.0),
              PaymentMethodCard(
                title: 'Receive your Salary',
                description: 'Coming Soon',
              ),
              PaymentMethodCard(
                title: 'Set up a Recurring Deposit',
                description: 'Coming Soon',
              ),
              SizedBox(height: 16.0),
              PaymentMethodCard(
                title: 'Add Money with Bank Transfer',
                description: 'Coming Soon',
              ),
              SizedBox(height: 16.0),
              PaymentMethodCard(
                title: 'Add money with Credit Card',
                description: 'Coming Soon',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final String title;
  final String description;

  const PaymentMethodCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      ),
    );
  }
}
