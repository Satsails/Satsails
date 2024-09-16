import 'package:Satsails/models/affiliate_model.dart';
import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final loadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class AffiliatesSectionWidget extends ConsumerWidget {
  const AffiliatesSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider); // Watch loading state

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Affiliate'.i18n(ref), style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
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
                'lib/assets/affiliates.png',
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
                    Text(
                      'Connect with other users and earn sats!'.i18n(ref),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter your affiliate code or create a new code to receive discounts.'.i18n(ref),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    CustomElevatedButton(
                      text: 'Insert Affiliate Code'.i18n(ref),
                      textColor: Colors.black,
                      onPressed: () {
                        _showInsertBottomModal(context, 'Insert Affiliate Code'.i18n(ref), ref);
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
                      ),
                      child: CustomElevatedButton(
                        text: 'Become an Affiliate'.i18n(ref),
                        backgroundColor: Colors.transparent,
                        textColor: Colors.white,
                        onPressed: () {
                          _showCreateBottomModal(context, 'Create Affiliate Code'.i18n(ref), ref);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (isLoading) // Show CircularProgressIndicator when loading is true
              Align(
                alignment: Alignment.topCenter,
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: Colors.orange,
                  size: 50,
                ),
              )
          ],
        ),
      ),
    );
  }

  void _showInsertBottomModal(BuildContext context, String title, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.orange,
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Affiliate Code'.i18n(ref),
                    labelStyle: const TextStyle(color: Colors.black),
                    border: const OutlineInputBorder(),
                    fillColor: Colors.orange,
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CustomElevatedButton(
                    text: 'Submit'.i18n(ref),
                    textColor: Colors.white,
                    backgroundColor: Colors.black,
                    onPressed: () async {
                      ref.read(loadingProvider.notifier).state = true;
                      String code = controller.text;
                      try {
                        Navigator.pop(context);
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
                        ref.read(loadingProvider.notifier).state = false;
                      } catch (e) {
                        ref.read(loadingProvider.notifier).state = false;
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
    final TextEditingController liquidAddressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.orange,
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: liquidAddressController,
                  decoration: InputDecoration(
                    labelText: 'Liquid Address to receive commission'.i18n(ref),
                    labelStyle: const TextStyle(color: Colors.black),
                    border: const OutlineInputBorder(),
                    fillColor: Colors.orange,
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CustomElevatedButton(
                    text: 'Submit'.i18n(ref),
                    textColor: Colors.white,
                    backgroundColor: Colors.black,
                    onPressed: () async {
                      ref.read(loadingProvider.notifier).state = true;
                      final hasInserted = ref.watch(affiliateProvider).insertedAffiliateCode.isNotEmpty;
                      Affiliate affiliate = Affiliate(
                        createdAffiliateCode: "",
                        createdAffiliateLiquidAddress: liquidAddressController.text,
                        insertedAffiliateCode: hasInserted ? ref.watch(affiliateProvider).insertedAffiliateCode : '',
                      );
                      try {
                        Navigator.pop(context);
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
                        ref.read(loadingProvider.notifier).state = false;
                      } catch (e) {
                        ref.read(loadingProvider.notifier).state = false;
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
