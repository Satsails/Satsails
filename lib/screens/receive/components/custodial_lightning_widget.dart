import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/coinos.provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/receive/components/lightning_widget.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustodialLightningWidget extends ConsumerStatefulWidget {
  const CustodialLightningWidget({Key? key}) : super(key: key);

  @override
  _CustodialLightningWidgetState createState() => _CustodialLightningWidgetState();
}

class _CustodialLightningWidgetState extends ConsumerState<CustodialLightningWidget> {
  late TextEditingController controller;
  bool includeAmountInAddress = false;
  String invoice = '';
  bool showLightningWidget = false;
  bool isLoading = false;
  late Future<void> usernameCheckFuture;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    usernameCheckFuture = _checkForUsername();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkForUsername() async {
    final lnurl = await ref.read(initialCoinosProvider.future).then((value) => value.username);
    if (lnurl == "") {
      _showUsernameModal();
    }
  }

  void _showUsernameModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  'Register for Custodial Lightning',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                const Text(
                  'A username and password will be derived from your private key. This will be used to access your custodial Lightning wallet.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
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
                      onPressed: () {
                        context.pop();
                        setState(() {
                          showLightningWidget = true; // Fallback to LightningWidget
                        });
                      },
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
                        try {
                          await ref.read(registerProvider.future);
                          context.pop();
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: 'Error during registration: $e',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                          );
                        }
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
    setState(() {
      isLoading = true;
    });
    String inputValue = controller.text;
    ref.read(inputAmountProvider.notifier).state = inputValue.isEmpty ? '0.0' : inputValue;
    try {
      final lnurlAsyncValue = await ref.read(createInvoiceProvider.future);
      setState(() {
        includeAmountInAddress = true;
        invoice = lnurlAsyncValue;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error creating address: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showCustodialWarningModal(BuildContext context, WidgetRef ref) {
    final coinosLn = ref.read(coinosLnProvider);

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  'Custodial Lightning Warning',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'By using this custodial Lightning service, your funds are held by our partner Coinos. Satsails does not have control over these funds. You agree to have your funds held by Coinos.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                _buildCopyableField(
                  label: 'Username',
                  value: coinosLn.username,
                ),
                const SizedBox(height: 16.0),
                _buildCopyableField(
                  label: 'Password',
                  value: coinosLn.password,
                ),
                const SizedBox(height: 24.0),
                TextButton(
                  onPressed: () => _launchURL('https://coinos.io/login'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                  ),
                  child: const Text(
                    'Visit Coinos',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16.0),
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
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
        msg: 'Could not launch $url',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Widget _buildCopyableField({required String label, required String value}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SelectableText(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, color: Colors.orange),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label copied to clipboard!')),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(coinosPaymentStreamProvider);

    payments.when(
      data: (data) {
        if (data['type'] == 'lightning' && data['confirmed'] == true) {
          // Extract relevant payment information
          final amount = data['amount'];

          // Show the modal with payment information
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showPaymentReceivedModal(context, amount);
          });
        }
      },
      loading: () {
        // Optionally handle loading state
      },
      error: (error, stackTrace) {
        // Handle error state
        print('Error: $error');
      },
    );

    return FutureBuilder<void>(
      future: usernameCheckFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              size: MediaQuery.of(context).size.width * 0.1,
              color: Colors.orange,
            ),
          );
        }

        if (showLightningWidget) {
          return const LightningWidget();
        }

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
              child: isLoading
                  ? LoadingAnimationWidget.threeArchedCircle(
                size: MediaQuery.of(context).size.width * 0.1,
                color: Colors.orange,
              )
                  : CustomElevatedButton(
                onPressed: _onCreateAddress,
                text: 'Create Address'.i18n(ref),
                controller: controller,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.info, color: Colors.orange, size: 40),
                  onPressed: () => _showCustodialWarningModal(context, ref),
                  tooltip: 'Custodial Lightning Info',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showPaymentReceivedModal(BuildContext context, int amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                  size: 60,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Payment Received!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  '$amount sats received!',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      context.pop();
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


  Widget _buildDefaultAddress(String lnurl) {
    final height = MediaQuery.of(context).size.height;

    return Column(
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
