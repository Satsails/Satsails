import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuildSideswapTransactions extends ConsumerWidget {

  const BuildSideswapTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      child: Text('Sideswap Transactions'),
    );
  }
}