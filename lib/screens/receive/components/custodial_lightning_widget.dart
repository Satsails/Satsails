import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/coinos.provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustodialLightningWidget extends ConsumerStatefulWidget {
  const CustodialLightningWidget({Key? key}) : super(key: key);

  @override
  _CustodialLightningWidgetState createState() => _CustodialLightningWidgetState();
}

class _CustodialLightningWidgetState extends ConsumerState<CustodialLightningWidget> {
  late TextEditingController controller;
  bool includeAmountInAddress = false;
  String invoice = '';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUsername());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _checkForUsername() {
    final coinosLn = ref.read(coinosLnProvider);
    coinosLn.whenData((value) {
      if (value.username.isEmpty) {
        _showUsernameModal();
      }
    });
  }

  void _showUsernameModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String username = '';
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter Your Preferred Username',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Please enter a username to proceed.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                TextField(
                  onChanged: (value) => username = value,
                  decoration: InputDecoration(
                    hintText: "Username",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () => context.pop(),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () async {
                        await ref.read(registerProvider({'username': username, 'password': 'default_password'}).future);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onCreateAddress() async {
    String inputValue = controller.text;
    ref.read(inputAmountProvider.notifier).state = inputValue.isEmpty ? '0.0' : inputValue;
    final lnurlAsyncValue = await ref.read(createInvoiceProvider.future);
    setState(() {
      includeAmountInAddress = true;
      invoice = lnurlAsyncValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AmountInput(controller: controller),
        SizedBox(height: height * 0.02),
        includeAmountInAddress
            ? _buildAddressWithAmount(invoice)
            : _buildDefaultAddress(ref.watch(lnurlProvider)),
        Padding(
          padding: EdgeInsets.all(height * 0.01),
          child: CustomElevatedButton(
            onPressed: _onCreateAddress,
            text: 'Create Address'.i18n(ref),
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAddress(String lnurl) {
    final height = MediaQuery.of(context).size.height;

    return  Column(
      children: [
        buildQrCode(lnurl, context),
        Padding(
          padding: EdgeInsets.all(height * 0.01),
          child: buildAddressText(lnurl, context, ref),
        ),
      ],
    );
  }

  Widget _buildAddressWithAmount(String invoice) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        buildQrCode(invoice, context),
        Padding(
          padding: EdgeInsets.all(height * 0.01),
          child: buildAddressText(invoice, context, ref),
        ),
      ],
    );
  }
}


