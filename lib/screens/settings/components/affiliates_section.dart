import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AffiliatesSectionWidget extends ConsumerWidget {
  const AffiliatesSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Affiliate'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                text: 'Insert Affiliate Code',
                onPressed: () {
                  _showInsertBottomModal(context, 'Insert Affiliate Code', ref);
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Create Affiliate Code',
                onPressed: () {
                  _showCreateBottomModal(context, 'Create Affiliate Code', ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInsertBottomModal(BuildContext context, String title, WidgetRef ref) {
    final TextEditingController _controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Affiliate Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Submit',
                  onPressed: () async {
                    String code = _controller.text;
                    try {
                      ref.read(userProvider.notifier).setAffiliateCode(code);
                      await ref.read(addAffiliateCodeProvider.future);

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
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateBottomModal(BuildContext context, String title, WidgetRef ref) {
    final TextEditingController _controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Create Affiliate Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Submit',
                  onPressed: () async {
                    String code = _controller.text;
                    try {
                      await ref.read(createAffiliateCodeProvider(code).future);
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
              ],
            ),
          ),
        );
      },
    );
  }
}