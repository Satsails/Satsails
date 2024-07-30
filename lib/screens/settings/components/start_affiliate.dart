import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/settings/components/affiliates_section.dart';
import 'package:Satsails/screens/settings/components/created_affiliate_dashboard.dart';
import 'package:Satsails/screens/settings/components/inserted_affiliate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartAffiliate extends ConsumerWidget {
  const StartAffiliate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAffiliateCode = ref.watch(userProvider).hasAffiliate;
    final hasCreatedAffiliate = ref.watch(userProvider).hasCreatedAffiliate;

    if (hasAffiliateCode) {
      return const InsertedAffiliateWidget();
    } else if (hasCreatedAffiliate) {
      return const CreatedAffiliateWidget();
    } else {
      return const AffiliatesSectionWidget();
    }
  }
}
