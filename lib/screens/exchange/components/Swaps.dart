// import 'package:Satsails/translations/translations.dart';
// import 'package:action_slider/action_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// final selectedDeliverAssetProvider = StateProvider<String>((ref) => 'BTC');
// final selectedReceiveAssetProvider = StateProvider<String>((ref) => 'USDt');
// final deliverAmountProvider = StateProvider<String>((ref) => '');
// final receiveAmountProvider = StateProvider<String>((ref) => '');
//
// class Swaps extends ConsumerWidget {
//   const Swaps({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final deliverAsset = ref.watch(selectedDeliverAssetProvider);
//     final receiveAsset = ref.watch(selectedReceiveAssetProvider);
//     final deliverAmount = ref.watch(deliverAmountProvider);
//     final receiveAmount = ref.watch(receiveAmountProvider);
//
//     final availableAssets = ['BTC', 'L-BTC', 'USDt', 'EURx', 'Depix', 'Lightning'];
//
//     // Ensure the current value exists in the list or set a default value
//     final safeDeliverAsset = availableAssets.contains(deliverAsset) ? deliverAsset : availableAssets.first;
//     final safeReceiveAsset = availableAssets.contains(receiveAsset) ? receiveAsset : availableAssets.first;
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Exchange from',
//               style: TextStyle(color: Colors.white),
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Stack(
//                     alignment: Alignment.centerRight,
//                     children: [
//                       TextField(
//                         style: TextStyle(color: Colors.white),
//                         decoration: InputDecoration(
//                           hintText: 'Enter amount',
//                           hintStyle: TextStyle(color: Colors.grey),
//                           filled: true,
//                           fillColor: Colors.grey[800],
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide.none,
//                           ),
//                           suffixIcon: Padding(
//                             padding: const EdgeInsets.only(right: 8.0),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: safeDeliverAsset,
//                                 dropdownColor: Colors.grey[800],
//                                 onChanged: (String? newValue) {
//                                   if (newValue != null) {
//                                     ref.read(selectedDeliverAssetProvider.notifier).state = newValue;
//                                   }
//                                 },
//                                 items: availableAssets
//                                     .map((String asset) => DropdownMenuItem<String>(
//                                   value: asset,
//                                   child: Text(
//                                     asset,
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ))
//                                     .toList(),
//                               ),
//                             ),
//                           ),
//                         ),
//                         onChanged: (value) {
//                           ref.read(deliverAmountProvider.notifier).state = value;
//                           ref.read(receiveAmountProvider.notifier).state =
//                               (double.tryParse(value) ?? 0 * 0.9).toStringAsFixed(2); // Example logic
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Ecchange to',
//               style: TextStyle(color: Colors.white),
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Stack(
//                     alignment: Alignment.centerRight,
//                     children: [
//                       TextField(
//                         style: TextStyle(color: Colors.white),
//                         readOnly: true,
//                         decoration: InputDecoration(
//                           hintText: receiveAmount,
//                           hintStyle: TextStyle(color: Colors.grey),
//                           filled: true,
//                           fillColor: Colors.grey[800],
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide.none,
//                           ),
//                           suffixIcon: Padding(
//                             padding: const EdgeInsets.only(right: 8.0),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: safeReceiveAsset,
//                                 dropdownColor: Colors.grey[800],
//                                 onChanged: (String? newValue) {
//                                   if (newValue != null) {
//                                     ref.read(selectedReceiveAssetProvider.notifier).state = newValue;
//                                   }
//                                 },
//                                 items: availableAssets
//                                     .map((String asset) => DropdownMenuItem<String>(
//                                   value: asset,
//                                   child: Text(
//                                     asset,
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ))
//                                     .toList(),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 40),
//             _liquidSlideToSend(ref, MediaQuery.of(context).size.height, MediaQuery.of(context).size.width, context
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
// Widget _liquidSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context) {
//   return Padding(
//     padding: EdgeInsets.only(bottom: dynamicPadding / 2),
//     child: Align(
//       alignment: Alignment.bottomCenter,
//       child: ActionSlider.standard(
//         sliderBehavior: SliderBehavior.stretch,
//         width: double.infinity,
//         backgroundColor: Colors.black,
//         toggleColor: Colors.orange,
//         action: (controller) async {
//           controller.loading();
//           try {
//           } catch (e) {
//           }
//         },
//         child: Text('Slide to Swap'.i18n(ref), style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white)),
//       ),
//     ),
//   );
// }