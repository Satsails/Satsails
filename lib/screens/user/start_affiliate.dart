import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/user/affiliates_section.dart';
import 'package:Satsails/screens/user/affiliate_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartAffiliate extends ConsumerWidget {
  const StartAffiliate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCreatedAffiliate = ref.watch(userProvider).hasCreatedAffiliate;
    final hasInsertedAffiliate = ref.watch(userProvider).hasInsertedAffiliate;

    if (hasCreatedAffiliate || hasInsertedAffiliate) {
      return const AffiliateViewWidget();
    } else {
      return const AffiliatesSectionWidget();
    }
  }
}
