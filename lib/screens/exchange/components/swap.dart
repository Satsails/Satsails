import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:satsails/providers/sideswap_provider.dart';
import 'package:satsails/screens/exchange/components/liquid_swap_cards.dart';

class Swap extends ConsumerWidget {
  Swap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Stack(
      children: [
        Column(
          children: [
            LiquidSwapCards(),
          ],
        ),
      ],
    );
  }
}


