import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/models/boltz_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/translations/translations.dart';

class ReceiveBoltz extends ConsumerStatefulWidget {
  const ReceiveBoltz({super.key});

  @override
  ConsumerState<ReceiveBoltz> createState() => _ReceiveBoltzState();
}

class _ReceiveBoltzState extends ConsumerState<ReceiveBoltz> {
  final TextEditingController _amountController = TextEditingController();
  AsyncValue<LbtcBoltz>? _swapAsync;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _generateInvoice() async {
    final amountStr = _amountController.text.trim();

    // Validate input
    if (amountStr.isEmpty) {
      showMessageSnackBar(
        context: context,
        message: 'Please enter an amount'.i18n,
        error: true,
      );
      return;
    }

    final amountDouble = double.tryParse(amountStr);
    if (amountDouble == null || amountDouble <= 0) {
      showMessageSnackBar(
        context: context,
        message: 'Invalid amount'.i18n,
        error: true,
      );
      return;
    }

    // Update inputAmountProvider with the user-entered amount
    ref.read(inputAmountProvider.notifier).state = amountStr;

    // Set sendTxProvider.amount to 0 to use lnAmountProvider in boltzReceiveProvider
    final sendTxNotifier = ref.read(sendTxProvider.notifier);
    sendTxNotifier.state = sendTxNotifier.state.copyWith(amount: 0);

    setState(() {
      _swapAsync = const AsyncValue.loading();
    });

    try {
      // Generate the swap using boltzReceiveProvider, which will use lnAmountProvider
      final swap = await ref.read(boltzReceiveProvider.future);
      setState(() {
        _swapAsync = AsyncValue.data(swap);
      });
    } catch (e) {
      setState(() {
        _swapAsync = AsyncValue.error(e, StackTrace.current);
      });
      showMessageSnackBar(
        context: context,
        message: e.toString().i18n,
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 24.h),
          _buildSwapContent(),
          Padding(
            padding: EdgeInsets.all(16.h),
            child: AmountInput(controller: _amountController, label: '(Mandatory)'),
          ),
          Padding(
            padding: EdgeInsets.all(16.h),
            child: CustomButton(
              onPressed: _generateInvoice,
              text: 'Generate Invoice'.i18n,
              primaryColor: Colors.green,
              secondaryColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapContent() {
    if (_swapAsync == null) {
      return Center(
        child: Text(
          'Enter amount and generate invoice'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      );
    }

    return _swapAsync!.when(
      data: (swap) => Center(
        child: Column(
          children: [
            buildQrCode(swap.swap.invoice, context),
            SizedBox(height: 16.h),
            buildAddressText(swap.swap.invoice, context, ref),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      loading: () => Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          size: 70.w,
          color: Colors.orange,
        ),
      ),
      error: (error, stack) => Center(
        child: Text(
          '$error'.i18n,
          style: TextStyle(color: Colors.red, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}