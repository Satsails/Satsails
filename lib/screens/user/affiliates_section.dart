import 'package:Satsails/models/affiliate_model.dart';
import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AffiliatesSectionWidget extends ConsumerWidget {
  const AffiliatesSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,  // This makes the body extend behind the AppBar
      appBar: AppBar(
        title: const Text('Affiliate', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,  // Make the AppBar transparent
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/affiliates.png',  // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Connect with other users and earn sats!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter your affiliate code or create a new code to receive benefits.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  CustomElevatedButton(
                    text: 'Insert Affiliate Code',
                    textColor: Colors.black,
                    onPressed: () {
                      _showInsertBottomModal(context, 'Insert Affiliate Code', ref);
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomElevatedButton(
                    text: 'Create Affiliate Code',
                    textColor: Colors.black,
                    onPressed: () {
                      _showCreateBottomModal(context, 'Create Affiliate Code', ref);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInsertBottomModal(BuildContext context, String title, WidgetRef ref) {
    final TextEditingController _controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.orange,  // Set the modal background to orange
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,  // Dark text color
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Affiliate Code',
                    labelStyle: TextStyle(color: Colors.black),  // Dark label color
                    border: OutlineInputBorder(),
                    fillColor: Colors.orange,  // Background color for input
                    filled: true,  // Fill the background color
                  ),
                  style: const TextStyle(color: Colors.black),  // Dark text color
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CustomElevatedButton(
                    text: 'Submit',
                    textColor: Colors.white,
                    backgroundColor: Colors.black,
                    onPressed: () async {
                      String code = _controller.text;
                      try {
                        await ref.read(addAffiliateCodeProvider(code).future);

                        Fluttertoast.showToast(
                          msg: 'Affiliate code saved successfully'.i18n(ref),
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: e.toString().i18n(ref),
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateBottomModal(BuildContext context, String title, WidgetRef ref) {
    final TextEditingController _affiliateController = TextEditingController();
    final TextEditingController _liquidAddressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.orange,  // Set the modal background to orange
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,  // Dark text color
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _liquidAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Liquid Address',
                    labelStyle: TextStyle(color: Colors.black),  // Dark label color
                    border: OutlineInputBorder(),
                    fillColor: Colors.orange,  // Background color for input
                    filled: true,  // Fill the background color
                  ),
                  style: const TextStyle(color: Colors.black),  // Dark text color
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _affiliateController,
                  decoration: const InputDecoration(
                    labelText: 'Affiliate Code',
                    labelStyle: TextStyle(color: Colors.black),  // Dark label color
                    border: OutlineInputBorder(),
                    fillColor: Colors.orange,  // Background color for input
                    filled: true,  // Fill the background color
                  ),
                  style: const TextStyle(color: Colors.black),  // Dark text color
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CustomElevatedButton(
                    text: 'Submit',
                    textColor: Colors.white,
                    backgroundColor: Colors.black,
                    onPressed: () async {
                      final hasInserted = ref.watch(affiliateProvider).insertedAffiliateCode.isNotEmpty;
                      Affiliate affiliate = Affiliate(
                        createdAffiliateCode: _affiliateController.text,
                        createdAffiliateLiquidAddress: _liquidAddressController.text,
                        insertedAffiliateCode: hasInserted ? ref.watch(affiliateProvider).insertedAffiliateCode : '',
                      );
                      try {
                        await ref.read(createAffiliateCodeProvider(affiliate).future);
                        Fluttertoast.showToast(
                          msg: 'Affiliate code created successfully'.i18n(ref),
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: e.toString().i18n(ref),
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
