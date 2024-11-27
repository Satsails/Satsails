import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
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

final showRegistrationProvider = StateProvider<bool>((ref) => false);


class CustodialLightningWidget extends ConsumerStatefulWidget {
  const CustodialLightningWidget({Key? key}) : super(key: key);

  @override
  _CustodialLightningWidgetState createState() => _CustodialLightningWidgetState();
}

class _CustodialLightningWidgetState extends ConsumerState<CustodialLightningWidget> {
  late TextEditingController controller;
  bool includeAmountInAddress = false;
  String invoice = '';
  bool isLoading = false;
  late Future<void> initializationFuture;

  String? lastProcessedPaymentId;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    initializationFuture = _initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _checkForUsername();
  }

  Future<void> _checkForUsername() async {
    final lnurl = await ref.read(initialCoinosProvider.future).then((value) => value.username);
    if (lnurl.isEmpty) {
      ref.read(showRegistrationProvider.notifier).state = true;
    }
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
        msg: '$e'.i18n(ref),
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
    final coinosLn = ref.watch(coinosLnProvider);

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
                Text(
                  'Custodial Lightning Warning'.i18n(ref),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                Text(
                  'By using this custodial Lightning service, your funds are held by our partner Coinos. Satsails does not have control over these funds. You agree to have your funds held by Coinos.'.i18n(ref),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                _buildCopyableField(
                  label: 'Username'.i18n(ref),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  ),
                  child: Text(
                    'Visit Coinos'.i18n(ref),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
    final showRegistration = ref.watch(showRegistrationProvider);
    if (showRegistration) {
      return _showRegistration(ref);
    }

    final payments = ref.watch(coinosPaymentStreamProvider);

    payments.when(
      data: (data) {
        if (data['type'] == 'lightning' && data['confirmed'] == true) {
          final amount = data['amount'];
          final paymentId = data['id'];

          if (lastProcessedPaymentId != paymentId) {
            lastProcessedPaymentId = paymentId;
            ref.read(backgroundSyncNotifierProvider.notifier).performSync();
            Future.microtask(() => _showPaymentReceivedModal(context, amount));
          }
        }
      },
      loading: () {
        // Optionally handle loading state
      },
      error: (error, stackTrace) {
        print('Error: $error');
      },
    );

    return FutureBuilder<void>(
      future: initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              size: MediaQuery.of(context).size.width * 0.1,
              color: Colors.orange,
            ),
          );
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
                  tooltip: 'Custodial Lightning Info'.i18n(ref),
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
                Text(
                  'Payment Received!'.i18n(ref),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  '$amount ' + 'sats received!'.i18n(ref),
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

Widget _showRegistration(WidgetRef ref) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Create Lightning Wallet'.i18n(ref),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12.0),
          Text(
            'A username and password will be derived from your private key. This will be used to access your custodial Lightning wallet. Your funds will be custodied by coinos.'.i18n(ref),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            ),
            child: Text(
              'Register'.i18n(ref),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            onPressed: () async {
              try {
                await ref.read(registerProvider.future);
                ref.read(showRegistrationProvider.notifier).state = false;
              } catch (e) {
                Fluttertoast.showToast(
                  msg: e.toString().i18n(ref),
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            },
          ),
        ],
      ),
    ),
  );
}

