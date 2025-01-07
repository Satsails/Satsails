import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/shared/delete_wallet_modal.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Satsails/providers/settings_provider.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Settings'.i18n(ref), style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBlockExplorerSection(context, ref),
            _buildDivider(),
            _buildSeedSection(context, ref),
            _buildDivider(),
            _buildLanguageSection(ref, context),
            _buildDivider(),
            _buildElectrumNodeSection(context, ref),
            _buildDivider(),
            _buildAffiliateSection(context, ref),
            _buildDivider(),
            _buildCreatedAffiliateSection(context, ref),
            _buildDivider(),
            DeleteWalletSection(ref: ref),
          ],
        ),
      ),
    );
  }

  Widget _buildElectrumNodeSection(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.cloud, color: Colors.white),
      title: Text('Select Electrum Node'.i18n(ref), style: const TextStyle(color: Colors.white)),
      subtitle: Text(ref.watch(settingsProvider).nodeType, style: TextStyle(color: Colors.grey)),
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.black,
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.cloud, color: Colors.white),
                  title: const Text('Blockstream', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    ref.read(settingsProvider.notifier).setLiquidElectrumNode('blockstream.info:995');
                    ref.read(settingsProvider.notifier).setBitcoinElectrumNode('blockstream.info:700');
                    ref.read(settingsProvider.notifier).setNodeType('Blockstream');
                    ref.read(backgroundSyncNotifierProvider.notifier).performSync();
                    context.pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cloud, color: Colors.white),
                  title: const Text('BullBitcoin', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    ref.read(settingsProvider.notifier).setLiquidElectrumNode('les.bullbitcoin.com:995');
                    ref.read(settingsProvider.notifier).setBitcoinElectrumNode('electrum.bullbitcoin.com:50002');
                    ref.read(settingsProvider.notifier).setNodeType('Bull Bitcoin');
                    ref.read(backgroundSyncNotifierProvider.notifier).performSync();
                    context.pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBlockExplorerSection(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Clarity.block_solid, color: Colors.white),
      title: Text('Search the blockchain'.i18n(ref), style: const TextStyle(color: Colors.white)),
      subtitle: const Text('mempool.com', style: TextStyle(color: Colors.grey)),
      onTap: () {
        clearTransactionSearch(ref);
        context.push('/search_modal');
      },
    );
  }

  Widget _buildLanguageSection(WidgetRef ref, BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return ListTile(
      leading: const Icon(Icons.language, color: Colors.white),
      title: Text('Language'.i18n(ref), style: const TextStyle(color: Colors.white)),
      subtitle: Text(settings.language.toUpperCase(), style: const TextStyle(color: Colors.grey)),
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.black,
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Flag(Flags.portugal),
                  title: Text('Portuguese'.i18n(ref), style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    settingsNotifier.setLanguage('pt');
                    context.pop();
                  },
                ),
                ListTile(
                  leading: Flag(Flags.united_states_of_america),
                  title: Text('English'.i18n(ref), style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    settingsNotifier.setLanguage('en');
                    context.pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAffiliateSection(BuildContext context, WidgetRef ref) {
    final affiliateCode = ref.watch(affiliateProvider).insertedAffiliateCode;
    final hasNotCreatedUser = ref.watch(userProvider).recoveryCode.isEmpty;

    if (hasNotCreatedUser) {
      return SizedBox.shrink();
    }

    return ListTile(
      leading: const Icon(Icons.account_circle_sharp, color: Colors.white),
      title: Text('Affiliate Section'.i18n(ref), style: const TextStyle(color: Colors.white)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (affiliateCode.isNotEmpty)
            Text('Inserted Code: $affiliateCode', style: const TextStyle(color: Colors.grey))
          else
            GestureDetector(
              onTap: () => _showInsertAffiliateModal(context, 'Insert Affiliate Code', ref),
              child: Text(
                'Insert an affiliate code to get a discount'.i18n(ref),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
      onTap: () {
        if (affiliateCode.isEmpty) {
          _showInsertAffiliateModal(context, 'Insert Affiliate Code', ref);
        }
      },
    );
  }

  void _showInsertAffiliateModal(BuildContext context, String title, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.i18n(ref),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Affiliate Code'.i18n(ref),
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      fillColor: Colors.black,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  CustomElevatedButton(
                    text: 'Insert',
                    onPressed: () async {
                      final affiliateCode = controller.text;
                      if (affiliateCode.isNotEmpty) {
                        try {
                          await ref.read(addAffiliateCodeProvider(affiliateCode).future);
                          showMessageSnackBar(
                            message: 'Affiliate code inserted successfully'.i18n(ref),
                            error: false,
                            context: context,
                            top: true,
                          );
                          // hammer fix
                          ref.invalidate(initializeAffiliateProvider);
                          context.pop();
                        } catch (e) {
                          showMessageSnackBar(
                            message: 'Error inserting affiliate code'.i18n(ref),
                            error: true,
                            context: context,
                            top: true,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreatedAffiliateSection(BuildContext context, WidgetRef ref) {
    final hasCreatedAffiliate = ref.watch(userProvider).hasCreatedAffiliate;
    final createdAffiliateCode = ref.watch(affiliateProvider).createdAffiliateCode;
    final hasNotCreatedUser = ref.watch(userProvider).recoveryCode.isEmpty;

    if (!hasCreatedAffiliate || hasNotCreatedUser) {
      return SizedBox.shrink();
    }

    return ListTile(
      leading: const Icon(Icons.monetization_on, color: Colors.white),
      title: Text('Your affiliate code'.i18n(ref), style: const TextStyle(color: Colors.white)),
      subtitle: Text('Created Code:'.i18n(ref) + ' $createdAffiliateCode', style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildSeedSection(BuildContext context, WidgetRef ref) {
    final walletBackedUp = ref.watch(settingsProvider).backup;
    return ListTile(
      leading: const Icon(Icons.currency_bitcoin, color: Colors.white),
      title: Text('View Seed Words'.i18n(ref), style: const TextStyle(color: Colors.white)),
      subtitle: Text('Write them down and keep them safe!'.i18n(ref), style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: () {
        walletBackedUp ? context.push('/open_seed_words_pin') : context.push('/seed_words');
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],
    );
  }
}
