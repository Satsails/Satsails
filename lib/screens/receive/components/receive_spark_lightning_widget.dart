import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../providers/bitcoin_provider.dart';

final selectedReceiveOptionProvider = StateProvider<String>((ref) => 'Lightning');
final lnurlNameProvider = StateProvider<String>((ref) => '');
final lnurlCreatedProvider = StateProvider<bool>((ref) => false);

class ReceiveSparkLightningWidget extends ConsumerStatefulWidget {
  const ReceiveSparkLightningWidget({super.key});

  @override
  _ReceiveSparkLightningWidgetState createState() => _ReceiveSparkLightningWidgetState();
}

class _ReceiveSparkLightningWidgetState extends ConsumerState<ReceiveSparkLightningWidget> {
  late TextEditingController controller;
  bool invoiceCreated = false;
  String displayAddress = '';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onCreateBitcoinAddress() async {
    String inputValue = controller.text;
    ref.read(inputAmountProvider.notifier).state = inputValue.isEmpty ? '0.0' : inputValue;
    final bitcoinAddress = await ref.read(bitcoinAddressProvider.future);
    final amount = inputValue.isEmpty ? '0' : inputValue;
    setState(() {
      invoiceCreated = true;
      displayAddress = 'bitcoin:$bitcoinAddress?amount=$amount';
    });
  }

  void _onCreateLnurl() {
    String inputValue = controller.text;
    ref.read(inputAmountProvider.notifier).state = inputValue.isEmpty ? '0.0' : inputValue;
    final amount = inputValue.isEmpty ? '0' : inputValue;
    setState(() {
      invoiceCreated = true;
      displayAddress = 'lnbc:placeholder_invoice_for_${amount}_sats';
    });
  }

  void _showLnurlInputModal(BuildContext context, WidgetRef ref) {
    final modalController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16.sp, top: 16.sp, left: 0, right: 0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: const Color(0x333333).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Set LNURL Username',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: modalController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: TextStyle(color: Colors.white, fontSize: 16.sp),
                              border: const OutlineInputBorder(),
                              fillColor: Colors.black,
                              filled: true,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orange),
                              ),
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 16.sp),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text('@satsails.com', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                      ],
                    ),
                    SizedBox(height: 20.sp),
                    CustomElevatedButton(
                      text: 'Set',
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      onPressed: () {
                        final username = modalController.text.trim();
                        if (username.isNotEmpty) {
                          ref.read(lnurlNameProvider.notifier).state = username;
                          ref.read(lnurlCreatedProvider.notifier).state = true;
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = ref.watch(selectedReceiveOptionProvider);
    final lnurlName = ref.watch(lnurlNameProvider);
    final bitcoinAddressAsyncValue = ref.watch(bitcoinAddressProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 16.h),
        _buildReceiveOptionButtons(),
        SizedBox(height: 24.h),
        if (invoiceCreated) ...[
          _buildAddressWithAmount(displayAddress),
        ] else if (selectedOption == 'Bitcoin') ...[
          _buildDefaultAddress(bitcoinAddressAsyncValue),
        ] else if (selectedOption == 'Lightning') ...[
          if (lnurlName.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  buildQrCode('lnurl not created', context),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'LNURL not set',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _showLnurlInputModal(context, ref),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  buildQrCode('$lnurlName@satsails.com', context),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.all(16.h),
                    child: buildAddressText('$lnurlName@satsails.com', context, ref),
                  ),
                ],
              ),
            ),
          ],
        ],
        Padding(
          padding: EdgeInsets.all(16.h),
          child: AmountInput(controller: controller),
        ),
        Padding(
          padding: EdgeInsets.all(16.h),
          child: CustomElevatedButton(
            onPressed: selectedOption == 'Bitcoin' ? _onCreateBitcoinAddress : _onCreateLnurl,
            text: selectedOption == 'Bitcoin' ? 'Create Address'.i18n : 'Create Invoice'.i18n,
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiveOptionButtons() {
    final selectedOption = ref.watch(selectedReceiveOptionProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildOptionButton('Lightning', selectedOption),
        SizedBox(width: 16.w),
        _buildOptionButton('Bitcoin', selectedOption),
      ],
    );
  }

  Widget _buildOptionButton(String option, String selectedOption) {
    final isSelected = option == selectedOption;
    return GestureDetector(
      onTap: () {
        ref.read(selectedReceiveOptionProvider.notifier).state = option;
        setState(() {
          invoiceCreated = false;
          displayAddress = '';
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAddress(AsyncValue<String> bitcoinAddressAsyncValue) {
    return bitcoinAddressAsyncValue.when(
      data: (bitcoinAddress) => Center(
        child: Column(
          children: [
            buildQrCode(bitcoinAddress, context),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.all(16.h),
              child: buildAddressText(bitcoinAddress, context, ref),
            ),
          ],
        ),
      ),
      loading: () => Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          size: 70.w,
          color: Colors.orange,
        ),
      ),
      error: (error, stack) => const Center(
        child: Text(
          'Error loading address',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildAddressWithAmount(String address) {
    return Center(
      child: Column(
        children: [
          buildQrCode(address, context),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.all(16.h),
            child: buildAddressText(address, context, ref),
          ),
        ],
      ),
    );
  }
}