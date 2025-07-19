import 'dart:async';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/formatters.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideshift_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:action_slider/action_slider.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

final nonNativeAddressProvider = StateProvider.autoDispose<String?>((ref) => null);

class ConfirmNonNativeAssetPayment extends ConsumerStatefulWidget {
  const ConfirmNonNativeAssetPayment({super.key});

  @override
  _ConfirmNonNativeAssetPaymentState createState() =>
      _ConfirmNonNativeAssetPaymentState();
}

class _ConfirmNonNativeAssetPaymentState
    extends ConsumerState<ConfirmNonNativeAssetPayment> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isProcessing = false;

  late String depositCoin;
  late String settleCoin;
  late String depositNetwork;
  late String settleNetwork;
  late String btcFormat;
  late String currency;
  late double currencyRate;
  late int balance;
  late ShiftPair shiftPair;

  @override
  void initState() {
    super.initState();
    shiftPair = ref.read(selectedSendShiftPairProvider);
    final params = shiftParamsMap[shiftPair]!;
    depositCoin = params.depositCoin;
    settleCoin = params.settleCoin;
    depositNetwork = params.depositNetwork;
    settleNetwork = params.settleNetwork;

    final settings = ref.read(settingsProvider);
    btcFormat = settings.btcFormat;
    currency = settings.currency;
    currencyRate = ref.read(selectedCurrencyProvider(currency));

    if (shiftPair == ShiftPair.liquidBtcToBtc) {
      balance = ref.read(balanceNotifierProvider).liquidBtcBalance;
      final sendTxState = ref.read(sendTxProvider);
      updateAmountControllerText(sendTxState.amount);
      addressController.text = sendTxState.address ?? '';
    } else {
      balance = ref.read(balanceNotifierProvider).liquidUsdtBalance;
      final sendTxState = ref.read(sendTxProvider);
      if (sendTxState.amount > 0) {
        amountController.text = (sendTxState.amount / 100000000).toStringAsFixed(2);
      }
    }
  }

  void updateAmountControllerText(int satsAmount) {
    final selectedCurrency = ref.read(inputCurrencyProvider);
    if (satsAmount == 0) {
      amountController.text = '';
      return;
    }

    final converted = calculateAmountInSelectedCurrency(
      satsAmount,
      selectedCurrency,
      ref.read(currencyNotifierProvider),
    );

    amountController.text = selectedCurrency == 'BTC'
        ? converted
        : selectedCurrency == 'Sats'
        ? satsAmount.toString()
        : double.parse(converted).toStringAsFixed(2);
  }

  @override
  void dispose() {
    amountController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String shortenAddress(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

  Future<bool> showNonBtcConfirmationModal(BuildContext context, String amount, String address, String fee, WidgetRef ref) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double amountDouble = double.parse(amount.replaceAll(',', ''));
        double serviceFeeDouble = amountDouble * 0.01;
        String serviceFee = serviceFeeDouble.toStringAsFixed(3);

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Card(
            color: const Color(0xFF333333),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Confirm Transaction'.i18n, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount'.i18n, style: TextStyle(color: Colors.grey[400], fontSize: 20.sp)),
                      Text('$amount USDT', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Divider(color: Colors.grey[700], height: 20.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recipient'.i18n, style: TextStyle(color: Colors.grey[400], fontSize: 20.sp)),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(6.r)),
                        child: Text(shortenAddress(address), style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Service Fee'.i18n, style: TextStyle(color: Colors.grey[400], fontSize: 20.sp)),
                      Text('$serviceFee USDT', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Divider(color: Colors.grey[700], height: 20.h),
                  ref.watch(payjoinFeeProvider).when(
                    data: (String fee) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payjoin fee'.i18n, style: TextStyle(color: Colors.grey[400], fontSize: 20.sp)),
                        Text('$fee USDT', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel'.i18n, style: TextStyle(color: Colors.grey[400], fontSize: 18.sp, fontWeight: FontWeight.w600))),
                      SizedBox(width: 16.w),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r))),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Confirm'.i18n, style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ) ??
        false;
  }

  Future<bool> showBtcConfirmationModal(BuildContext context, String amount, String address, int fee, String btcFormat, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final currency = settings.currency;
    final amountInCurrency = ref.read(bitcoinValueInCurrencyProvider);
    final amountInSats = ref.read(sendTxProvider).amount;
    final serviceFeeInSats = (amountInSats * 0.01).toInt();

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Card(
            color: const Color(0xFF333333),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text('Confirm Transaction'.i18n, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold))),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount'.i18n, style: TextStyle(color: Colors.grey[400], fontSize: 20.sp)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$amount $btcFormat', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600)),
                          Text('${currencyFormat(Decimal.parse(amountInCurrency.toString()), currency)} $currency', style: TextStyle(color: Colors.grey[400], fontSize: 18.sp)),
                        ],
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey[700], height: 20.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recipient'.i18n, style: TextStyle(color: Colors.grey[400], fontSize: 20.sp)),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(6.r)),
                        child: Text(shortenAddress(address), style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey[700], height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Service Fee'.i18n, style: TextStyle(color: Colors.grey[400], fontSize: 20.sp)),
                      Text('$serviceFeeInSats sats', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Divider(color: Colors.grey[700], height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Network Fee'.i18n, style: TextStyle(color: Colors.grey[400], fontSize: 20.sp)),
                      Text('$fee sats', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel'.i18n, style: TextStyle(color: Colors.grey[400], fontSize: 18.sp, fontWeight: FontWeight.w600))),
                      SizedBox(width: 16.w),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r))),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Confirm'.i18n, style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final scannedAddress = ref.watch(nonNativeAddressProvider);
    if (scannedAddress != null && scannedAddress != addressController.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        addressController.text = scannedAddress;
        ref.read(sendTxProvider.notifier).updateAddress(scannedAddress);
        ref.read(nonNativeAddressProvider.notifier).state = null;
      });
    }

    return PopScope(
      canPop: !isProcessing,
      onPopInvoked: (bool canPop) {
        if (isProcessing) {
          showMessageSnackBarInfo(message: "Transaction in progress, please wait.".i18n, context: context);
        } else {
          ref.read(sendTxProvider.notifier).resetToDefault();
          context.replace('/home');
        }
      },
      child: SafeArea(
        child: KeyboardDismissOnTap(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              centerTitle: false,
              title: Text('Send'.i18n, style: TextStyle(color: Colors.white, fontSize: 22.sp)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () {
                  if (!isProcessing) {
                    ref.read(sendTxProvider.notifier).resetToDefault();
                    context.replace('/home');
                  } else {
                    showMessageSnackBarInfo(message: "Transaction in progress, please wait.".i18n, context: context);
                  }
                },
              ),
            ),
            body: Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: shiftPair == ShiftPair.liquidBtcToBtc
                          ? _buildLiquidBtcUi()
                          : _buildNonNativeUi(),
                    ),
                  ),
                  ActionSlider.standard(
                    sliderBehavior: SliderBehavior.stretch,
                    width: double.infinity,
                    backgroundColor: Colors.black,
                    toggleColor: Colors.orange,
                    action: _handleSendAction,
                    child: Text('Slide to send'.i18n, style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSendAction(ActionSliderController controller) async {
    setState(() {
      isProcessing = true;
    });
    controller.loading();

    SideShift? shift;
    try {
      shift = await ref.read(createSendSideShiftShiftProvider((ref.read(selectedSendShiftPairProvider), addressController.text)).future);

      ref.read(sendTxProvider.notifier).updateAddress(shift!.depositAddress);
      if (shiftPair == ShiftPair.liquidBtcToBtc) {
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
      } else {
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.USD));
      }

      final amount = ref.read(sendTxProvider).amount;
      final depositMin = (double.parse(shift.depositMin) * 100000000).toInt();
      final depositMax = (double.parse(shift.depositMax) * 100000000).toInt();

      if (amount < depositMin) {
        throw "${"Amount is too small. Minimum amount is".i18n} ${shift.depositMin} $depositCoin";
      }
      if (amount > depositMax) {
        throw "${"Amount is too large. Maximum amount is".i18n} ${shift.depositMax} $depositCoin";
      }

      bool confirmed = false;
      if (shiftPair == ShiftPair.liquidBtcToBtc) {
        final fee = await ref.read(liquidFeeProvider.future);
        confirmed = await showBtcConfirmationModal(
          context,
          btcInDenominationFormatted(amount, btcFormat),
          shift.settleAddress,
          fee,
          btcFormat,
          ref,
        );
      } else {
        confirmed = await showNonBtcConfirmationModal(
          context,
          fiatInDenominationFormatted(amount),
          shift.settleAddress,
          shift.networkFeeUsd,
          ref,
        );
      }

      if (!confirmed) {
        ref.read(deleteSideShiftProvider(shift.id));
        controller.reset();
        setState(() {
          isProcessing = false;
        });
        return;
      }

      final tx = await (shiftPair == ShiftPair.liquidBtcToBtc
          ? ref.read(sendLiquidTransactionProvider.future)
          : ref.read(liquidPayjoinTransaction.future));

      showFullscreenTransactionSendModal(
        context: context,
        asset: depositCoin,
        amount: shiftPair == ShiftPair.liquidBtcToBtc
            ? btcInDenominationFormatted(ref.watch(sendTxProvider).amount, btcFormat)
            : fiatInDenominationFormatted(ref.watch(sendTxProvider).amount),
        fiat: AssetMapper.mapAsset(ref.watch(sendTxProvider).assetId).isFiat,
        fiatAmount: ref.watch(sendTxProvider).amount.toString(),
        txid: tx,
        isLiquid: true,
        receiveAddress: shift.settleAddress,
        confirmationBlocks: 1,
      );

      ref.read(sendTxProvider.notifier).resetToDefault();
      context.replace('/home');
    } catch (e) {
      if (shift != null) {
        ref.read(deleteSideShiftProvider(shift.id));
      }
      controller.failure();
      showMessageSnackBar(message: e.toString().i18n, error: true, context: context);
      controller.reset();
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Widget _buildNonNativeUi() {
    final balanceText = fiatInDenominationFormatted(balance);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.sp),
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            children: [
              Text(depositCoin, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              Text(balanceText, style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text('Recipient Address'.i18n + ' ($settleNetwork $settleCoin)', style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
              child: TextFormField(
                controller: addressController,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter recipient address'.i18n,
                  hintStyle: const TextStyle(color: Colors.white70),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 24.w),
                    onPressed: () => context.pushNamed('camera', extra: {'paymentType': PaymentType.NonNative}),
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(bottom: 8.h), child: Text('Amount'.i18n, style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold))),
            Container(
              decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          CommaTextInputFormatter(),
                          DecimalTextInputFormatter(decimalRange: 2)
                        ],
                        style: TextStyle(fontSize: 24.sp, color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: const TextStyle(color: Colors.white70),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                        ),
                        onChanged: (value) {
                          final amount = (double.tryParse(value) ?? 0.0);
                          ref.read(sendTxProvider.notifier).updateAmountFromInput(amount.toString(), 'sats');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          "A 1% service fee is applied, excluding network fees.".i18n,
          style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildLiquidBtcUi() {
    final btcBalanceInFormat = ref.watch(liquidBalanceInFormatProvider(btcFormat));
    final valueInBtc = ref.watch(liquidBalanceInFormatProvider('BTC')) == '0.00000000' ? 0 : double.parse(ref.watch(liquidBalanceInFormatProvider('BTC')));
    final balanceInSelectedCurrency = (valueInBtc * currencyRate).toStringAsFixed(2);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.sp),
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            children: [
              Text('Liquid Balance'.i18n, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              Text('$btcBalanceInFormat $btcFormat', style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold)),
              Text('$balanceInSelectedCurrency $currency', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text('Recipient Address'.i18n + ' ($settleNetwork $settleCoin)', style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
              child: TextFormField(
                controller: addressController,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter recipient address'.i18n,
                  hintStyle: const TextStyle(color: Colors.white70),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 24.w),
                    onPressed: () => context.pushNamed('camera', extra: {'paymentType': PaymentType.NonNative}),
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(bottom: 8.h), child: Text('Amount'.i18n, style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold))),
            Container(
              decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: ref.watch(inputCurrencyProvider) == 'Sats' ? [DecimalTextInputFormatter(decimalRange: 0)] : [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 8)],
                        style: TextStyle(fontSize: 24.sp, color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: const TextStyle(color: Colors.white70),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                        ),
                        onChanged: (value) {
                          ref.read(inputAmountProvider.notifier).state = amountController.text.isEmpty ? '0.0' : amountController.text;
                          if (value.isEmpty) {
                            ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                            ref.read(sendTxProvider.notifier).updateDrain(false);
                          }
                          final amountInSats = calculateAmountInSatsToDisplay(value, ref.watch(inputCurrencyProvider), ref.watch(currencyNotifierProvider));
                          ref.read(sendTxProvider.notifier).updateAmountFromInput(amountInSats.toString(), 'sats');
                          ref.read(sendTxProvider.notifier).updateDrain(false);
                        },
                      ),
                    ),
                    _buildCurrencySelectorAndMaxButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          "A 1% service fee is applied, excluding network fees.".i18n,
          style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildCurrencySelectorAndMaxButton() {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF212121),
              value: ref.watch(inputCurrencyProvider),
              items: ['BTC', 'USD', 'EUR', 'BRL', 'Sats'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: Text(value, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                ref.read(inputCurrencyProvider.notifier).state = value.toString();
                amountController.text = '';
                ref.read(sendTxProvider.notifier).updateAmountFromInput('0', 'sats');
                ref.read(sendTxProvider.notifier).updateDrain(false);
              },
              icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 24.sp),
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            ),
          ),
        ),
      ],
    );
  }
}