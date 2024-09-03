import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CreatedAffiliateWidget extends ConsumerWidget {
  const CreatedAffiliateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affiliateData = ref.watch(userProvider);
    final numberOfInstall = ref.watch(numberOfAffiliateInstallsProvider);
    final earnings = ref.watch(affiliateEarningsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Created Affiliate Code', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'This is the affiliate code you created: ${affiliateData.affiliateCode}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              numberOfInstall.when(
                data: (installs) {
                  return Text(
                    'Number of installs: ${installs.toString()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                loading: () => LoadingAnimationWidget.threeArchedCircle(
                  size: MediaQuery.of(context).size.height * 0.1,
                  color: Colors.orange,
                ),
                error: (error, stackTrace) {
                  return Text('Error: $error');
                },
              ),
              const SizedBox(height: 10),
              earnings.when(
                data: (earnings) {
                  return Text(
                    'Earnings: ${earnings.toString()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                loading: () => LoadingAnimationWidget.threeArchedCircle(
                  size: MediaQuery.of(context).size.height * 0.1,
                  color: Colors.orange,
                ),
                error: (error, stackTrace) {
                  return Text('Error: $error');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
