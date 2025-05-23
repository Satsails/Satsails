import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';

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
    final bitcoinAddress = ref.read(addressProvider).bitcoinAddress;
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
                  color: const Color(0x00333333).withOpacity(0.4),
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
    final bitcoinAddresss = ref.watch(addressProvider).bitcoinAddress;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildReceiveOptionButtons(),
        SizedBox(height: 24.h),
        if (invoiceCreated) ...[
          _buildAddressWithAmount(displayAddress),
        ] else if (selectedOption == 'Bitcoin' || selectedOption == 'Spark') ...[
          _buildDefaultAddress(bitcoinAddresss),
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
        if (selectedOption != 'Spark') ...[
          Padding(
            padding: EdgeInsets.all(16.h),
            child: AmountInput(controller: controller),
          ),
          Padding(
            padding: EdgeInsets.all(16.h),
            child: CustomButton(
              onPressed: selectedOption == 'Bitcoin' ? _onCreateBitcoinAddress : _onCreateLnurl,
              text: selectedOption == 'Bitcoin' ? 'Create Address'.i18n : 'Create Invoice'.i18n,
              primaryColor: Colors.green,
              secondaryColor: Colors.green,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReceiveOptionButtons() {
    final selectedOption = ref.watch(selectedReceiveOptionProvider);
    return Wrap(
      spacing: 16.w,
      children: [
        _buildOptionButton('Lightning', selectedOption),
        _buildOptionButton('Bitcoin', selectedOption),
        _buildOptionButton('Spark', selectedOption),
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
          color: isSelected ? const Color(0xFF212121) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            option == 'Spark'
                ? Image.asset(
              'lib/assets/sparkSmallIcon.png',
              width: 24.w,
              height: 24.h,
            )
                : Image.asset(
              option == 'Bitcoin' ? 'lib/assets/bitcoin-logo.png' : 'lib/assets/Bitcoin_lightning_logo.png',
              width: 24.w,
              height: 24.h,
            ),
            SizedBox(width: 8.w),
            Text(
              option,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAddress(String bitcoinAddress) {
    return Column(
      children: [
        buildQrCode(bitcoinAddress, context),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.all(16.h),
          child: buildAddressText(bitcoinAddress, context, ref),
        ),
      ],
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