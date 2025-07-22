import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:action_slider/action_slider.dart';

Future<bool> showConfirmationModal(
    BuildContext context, String amount, String address, int fee, String btcFormat, WidgetRef ref, bool isPayjoinTx, String asset) async {
  String shortenAddress(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

  // A local helper for creating styled detail rows
  Widget buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16.sp)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // User must explicitly confirm or cancel
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 20.h),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2A2A2A), Color(0xFF1C1C1C)],
                ),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Confirm Transaction'.i18n,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),

                // Hero Amount Section
                Text(
                  '$amount $asset',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Divider(color: Colors.white.withOpacity(0.15)),
                ),

                // Details Section
                buildDetailRow(
                  label: 'Recipient'.i18n,
                  value: shortenAddress(address),
                ),
                buildDetailRow(
                  label: 'Network Fee'.i18n,
                  value: '$fee sats',
                ),

                // Conditional Payjoin Fee
                if (isPayjoinTx)
                  ref.watch(payjoinFeeProvider).when(
                    data: (String payjoinFee) => buildDetailRow(
                      label: 'Payjoin fee'.i18n,
                      value: '$payjoinFee $asset',
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const SizedBox.shrink(),
                  ),

                SizedBox(height: 24.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel'.i18n,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Confirm'.i18n,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
      false; // Default to false if dialog is dismissed
}

Widget buildTransactionDetailsCard(WidgetRef ref, TextEditingController controller, String asset, bool isPayjoinTx) {
  return Card(
    color: const Color(0x00333333).withOpacity(0.4),
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    elevation: 4,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: ExpansionTile(
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(bottom: 16.h),
        maintainState: true,
        shape: const Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
        collapsedShape: const Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
        title: Text(
          'Transaction Details'.i18n,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount:'.i18n,
                style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                controller.text,
                style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ref.watch(liquidFeeProvider).when(
            data: (int fee) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fee:'.i18n,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    '$fee sats',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              );
            },
            loading: () => LoadingAnimationWidget.progressiveDots(size: 16.sp, color: Colors.white),
            error: (error, stack) => TextButton(
              onPressed: () {
                ref.refresh(liquidFeeProvider);
              },
              child: Text(
                ref.watch(sendTxProvider).amount == 0 ? '' : error.toString().i18n,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          ref.watch(liquidFeeValueInCurrencyProvider).when(
            data: (double feeValue) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fee in ${ref.watch(settingsProvider).currency}:'.i18n,
                    style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    currencyFormat(feeValue, ref.watch(settingsProvider).currency),
                    style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
            loading: () => LoadingAnimationWidget.progressiveDots(size: 16.sp, color: Colors.white),
            error: (error, stack) => Text(
              '',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 8.h),
          if (isPayjoinTx) ...[
            ref.watch(payjoinFeeProvider).when(
              data: (String fee) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payjoin Fee'.i18n,
                      style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$fee $asset',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
          ]
        ],
      ),
    ),
  );
}

class ConfirmLiquidAssetPayment extends ConsumerStatefulWidget {
  const ConfirmLiquidAssetPayment({super.key});

  @override
  _ConfirmLiquidAssetPaymentState createState() => _ConfirmLiquidAssetPaymentState();
}

class _ConfirmLiquidAssetPaymentState extends ConsumerState<ConfirmLiquidAssetPayment> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isProcessing = false;
  late String btcFormat;
  late String currency;
  late String assetId;
  late String assetName;
  late double currencyRate;
  late String balanceText;

  void updateControllerText(int satsAmount) {
    final selectedCurrency = ref.read(inputCurrencyProvider);
    if (satsAmount == 0) {
      controller.text = '';
      return;
    }

    final converted = calculateAmountInSelectedCurrency(
      satsAmount,
      selectedCurrency,
      ref.read(currencyNotifierProvider),
    );

    controller.text = selectedCurrency == 'BTC'
        ? converted
        : selectedCurrency == 'Sats'
        ? satsAmount.toString()
        : double.parse(converted).toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    btcFormat = settings.btcFormat;
    currency = settings.currency;
    currencyRate = ref.read(selectedCurrencyProvider(currency));

    final sendTxState = ref.read(sendTxProvider);
    assetId = sendTxState.assetId;
    assetName = AssetMapper.mapAsset(assetId).name;
    updateControllerText(sendTxState.amount);
    final address = sendTxState.address;
    addressController.text = address;

    final balance = ref.read(balanceNotifierProvider);
    switch (assetId) {
      case 'ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2':
        balanceText = fiatInDenominationFormatted(balance.liquidUsdtBalance);
        break;
      case '18729918ab4bca843656f08d4dd877bed6641fbd596a0a963abbf199cfeb3cec':
        balanceText = fiatInDenominationFormatted(balance.liquidEuroxBalance);
        break;
      case '02f22f8d9c76ab41661a2729e4752e2c5d1a263012141b86ea98af5472df5189':
        balanceText = fiatInDenominationFormatted(balance.liquidDepixBalance);
        break;
      default:
        balanceText = '';
    }
  }

  @override
  void dispose() {
    controller.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPayjoinTx = ref.watch(isPayjoin);

    return PopScope(
      canPop: !isProcessing,
      onPopInvoked: (bool canPop) {
        if (isProcessing) {
          showMessageSnackBarInfo(
            message: "Transaction in progress, please wait.".i18n,
            context: context,
          );
        } else {
          ref.read(sendTxProvider.notifier).resetToDefault();
          ref.read(sendBlocksProvider.notifier).state = 1;
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
              title: Text('Send'.i18n, style: TextStyle(color: Colors.white, fontSize: 20.sp)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () {
                  if (!isProcessing) {
                    ref.read(sendTxProvider.notifier).resetToDefault();
                    ref.read(sendBlocksProvider.notifier).state = 1;
                    context.replace('/home');
                  } else {
                    showMessageSnackBarInfo(
                      message: "Transaction in progress, please wait.".i18n,
                      context: context,
                    );
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
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.sp),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0x00333333).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  assetName,
                                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                ),
                                Text(
                                  balanceText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Text(
                                  'Recipient Address'.i18n,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: const Color(0x00333333).withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: TextFormField(
                                  controller: addressController,
                                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                  cursorColor: Colors.white,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter recipient address'.i18n,
                                    hintStyle: const TextStyle(color: Colors.white70),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.camera_alt, color: Colors.white, size: 24.w),
                                      onPressed: () {
                                        context.pushNamed(
                                          'camera',
                                          extra: {'paymentType': PaymentType.Liquid},
                                        );
                                      },
                                    ),
                                  ),
                                  onChanged: (value) {
                                    ref.read(sendTxProvider.notifier).updateAddress(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Text(
                                  'Amount'.i18n,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0x00333333).withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            CommaTextInputFormatter(),
                                            DecimalTextInputFormatter(decimalRange: 2)
                                          ],
                                          validator: (value) {
                                            return null;
                                          },
                                          style: TextStyle(fontSize: 24.sp, color: Colors.white),
                                          textAlign: TextAlign.left,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '0',
                                            hintStyle: const TextStyle(color: Colors.white70),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                                          ),
                                          onChanged: (value) async {
                                            ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormat);
                                            ref.read(sendTxProvider.notifier).updateDrain(false);
                                          },
                                        ),
                                      ),
                                      // Conditionally display the "Max" button
                                      if (!isPayjoinTx)
                                        Padding(
                                          padding: EdgeInsets.only(right: 8.sp),
                                          child: GestureDetector(
                                            onTap: () async {
                                              try {
                                                final amount = double.parse(balanceText);
                                                // Adjusted amount logic remains the same
                                                final adjustedAmount = isPayjoinTx ? amount * 0.95 : amount;
                                                ref.read(sendTxProvider.notifier).updateAmountFromInput(adjustedAmount.toString(), btcFormat);
                                                controller.text = adjustedAmount.toStringAsFixed(2);
                                              } catch (e) {
                                                showMessageSnackBar(
                                                  message: e.toString().i18n,
                                                  error: true,
                                                  context: context,
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8.r),
                                              ),
                                              child: Text(
                                                'Max',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0x00333333).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Pay fee in %s'.i18n.fill([assetName]),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Checkbox(
                                  value: ref.watch(isPayjoin),
                                  onChanged: (bool? value) {
                                    ref.read(isPayjoin.notifier).state = value ?? false;
                                    ref.read(sendTxProvider.notifier).updateDrain(false);
                                    ref.read(sendTxProvider.notifier).updateAmount(0);
                                    controller.text = '0';
                                  },
                                  activeColor: Colors.white,
                                  checkColor: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          buildTransactionDetailsCard(ref, controller, assetName, isPayjoinTx),
                        ],
                      ),
                    ),
                  ),
                  ActionSlider.standard(
                    sliderBehavior: SliderBehavior.stretch,
                    width: double.infinity,
                    backgroundColor: Colors.black,
                    toggleColor: const Color(0xFF212121),
                    action: (controller) async {
                      setState(() {
                        isProcessing = true;
                      });
                      controller.loading();

                      try {
                        final sendTxState = ref.read(sendTxProvider);
                        final fee = await ref.read(liquidFeeProvider.future);

                        final confirmed = await showConfirmationModal(
                          context,
                          fiatInDenominationFormatted(sendTxState.amount),
                          sendTxState.address ?? '',
                          fee,
                          btcFormat,
                          ref,
                          isPayjoinTx,
                          assetName,
                        );

                        if (confirmed) {
                          final String tx;
                          if (isPayjoinTx) {
                            tx = await ref.watch(liquidPayjoinTransaction.future);
                          } else {
                            tx = await ref.watch(sendLiquidTransactionProvider.future);
                          }
                          showFullscreenTransactionSendModal(
                            context: context,
                            asset: AssetMapper.mapAsset(ref.watch(sendTxProvider).assetId).name,
                            amount: btcInDenominationFormatted(ref.watch(sendTxProvider).amount, btcFormat),
                            fiat: AssetMapper.mapAsset(ref.watch(sendTxProvider).assetId).isFiat,
                            fiatAmount: ref.watch(sendTxProvider).amount.toString(),
                            txid: tx,
                            isLiquid: true,
                            receiveAddress: ref.read(sendTxProvider).address,
                            confirmationBlocks: ref.read(sendBlocksProvider.notifier).state.toInt(),
                          );

                          ref.read(sendTxProvider.notifier).resetToDefault();
                          ref.read(sendBlocksProvider.notifier).state = 1;
                          context.replace('/home');
                        } else {
                          controller.reset();
                        }
                      } catch (e) {
                        controller.failure();
                        showMessageSnackBar(
                          message: e.toString().i18n,
                          error: true,
                          context: context,
                        );
                        controller.reset();
                      } finally {
                        setState(() {
                          isProcessing = false;
                        });
                      }
                    },
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
}