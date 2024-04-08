import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/liquid_provider.dart';
import '../shared/transactions_builder.dart';
import 'package:group_button/group_button.dart';

class Receive extends ConsumerWidget {
  Receive({Key? key}) : super(key: key);

  Widget buildQrCode(String address, BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: QrImageView(
          backgroundColor: Colors.white,
          data: address!,
          version: QrVersions.auto,
          size: MediaQuery
              .of(context)
              .size
              .width * 0.6,
        )
    );
  }

  Widget buildAddressText(String address, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: address));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Address copied to clipboard: $address'),
          ),
        );
      },
      child: Row(
        children: [
          Flexible(
            child: Text(
              address,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }


  final selectedButtonProvider = StateProvider<String>((ref) => "Bitcoin");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedButtonProvider);
    final bitcoinAddressAsyncValue = ref.watch(bitcoinAddressProvider);
    final liquidAddressAsyncValue = ref.watch(liquidAddressProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Receive'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          GroupButton(
            isRadio: true,
            onSelected: (index, isSelected, isLongPress) {
              switch (index) {
                case 'Bitcoin':
                  ref.read(selectedButtonProvider.notifier).state = "Bitcoin";
                  break;
                case 'Liquid':
                  ref.read(selectedButtonProvider.notifier).state = "Liquid";
                  break;
                case 'Lightning':
                  ref.read(selectedButtonProvider.notifier).state = "Lightning";
                  break;
                default:
                  'Bitcoin';
              }
            },
            buttons: ["Lightening", 'Bitcoin', "Liquid"],
            options: GroupButtonOptions(
              unselectedTextStyle: const TextStyle(fontSize: 16, color: Colors.black),
              selectedTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
              selectedColor: Colors.blue,
              mainGroupAlignment: MainGroupAlignment.center,
              crossGroupAlignment: CrossGroupAlignment.center,
              groupRunAlignment: GroupRunAlignment.center,
              unselectedColor: Colors.white,
              groupingType: GroupingType.row,
              alignment: Alignment.center,
              elevation: 0,
              textPadding: EdgeInsets.zero,
              selectedShadow: <BoxShadow>[const BoxShadow(color: Colors.transparent)],
              unselectedShadow: <BoxShadow>[
                const BoxShadow(color: Colors.transparent)
              ],
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          const SizedBox(height: 16.0),
          if (selectedIndex == 'Bitcoin')
            Expanded(
              child: bitcoinAddressAsyncValue.when(
              data: (bitcoinAddress) {
                return Column(
                  children: [
                    buildQrCode(bitcoinAddress.address, context),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildAddressText(bitcoinAddress.address, context),
                    ),
                    const SizedBox(height: 16.0),
                    const Divider(height: 1),
                    Expanded(child: buildTransactions([], context)),
                  ],
                );
              },
              loading: () => Center(child: LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.orange)),
                error: (error, stack) =>  Center(child: LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.orange)),),
            ),
          if (selectedIndex == "Liquid")
            Expanded(
              child: liquidAddressAsyncValue.when(
              data: (liquidAddress) {
                return Column(
                  children: [
                    buildQrCode(liquidAddress, context),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildAddressText(liquidAddress, context),
                    ),
                    const SizedBox(height: 16.0),
                    const Divider(height: 1),
                    Expanded(child: buildTransactions([], context)),
                  ],
                );
              },
              loading: () => Center(child: LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.orange)),
              error: (error, stack) =>  Center(child: LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.orange)),),
            ),
        ],
      ),
    );
  }
}