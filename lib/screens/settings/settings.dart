import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/shared/custom_bottom_navigation_bar.dart';
import 'package:Satsails/screens/shared/delete_wallet_modal.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:crisp_chat/crisp_chat.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Added for dotenv

class Settings extends ConsumerWidget {
  const Settings({super.key});

  // Method to open Crisp Chat directly
  Future<void> _openCrispChat(WidgetRef ref) async {
    final user = ref.read(userProvider);

    final config = CrispConfig(
      websiteID: dotenv.env['CRISP_ID']!,
      user: User(
        nickName: user.paymentId,
      ),
    );

    try {
      await FlutterCrispChat.openCrispChat(config: config);
      FlutterCrispChat.setSessionString(
        key: "payment_id",
        value: user.paymentId,
      );
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: ref.watch(navigationProvider),
          onTap: (int index) {
            ref.read(navigationProvider.notifier).state = index;
          },
        ),
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text('Settings'.i18n, style: const TextStyle(color: Colors.white)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBlockExplorerSection(context, ref),
              _buildSeedSection(context, ref),
              _buildChatWithSupportSection(context, ref),
              _buildLanguageSection(ref, context),
              _buildCurrencyDenominationSection(ref, context),
              _buildBitcoinUnitSection(ref, context),
              _buildElectrumNodeSection(context, ref),
              _buildAffiliateSection(context, ref),
              DeleteWalletSection(ref: ref), // Will apply red background in the widget
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElectrumNodeSection(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.cloud, color: Colors.white),
        title: Text('Select Electrum Node'.i18n, style: const TextStyle(color: Colors.white)),
        subtitle: Text(ref.watch(settingsProvider).nodeType, style: const TextStyle(color: Colors.grey)),
        onTap: () {
          showModalBottomSheet(
            backgroundColor: Colors.black,
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF212121),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
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
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF212121),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
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
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBlockExplorerSection(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Clarity.block_solid, color: Colors.white),
        title: Text('Search the blockchain'.i18n, style: const TextStyle(color: Colors.white)),
        subtitle: const Text('mempool.com', style: TextStyle(color: Colors.grey)),
        onTap: () {
          clearTransactionSearch(ref);
          context.push('/search_modal');
        },
      ),
    );
  }

  Widget _buildChatWithSupportSection(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.support_agent, color: Colors.white),
        title: Text('Chat with support'.i18n, style: const TextStyle(color: Colors.white)),
        subtitle: Text('Talk to us on Telegram'.i18n, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () async {
          await _openCrispChat(ref);
        },
      ),
    );
  }

  Widget _buildCurrencyDenominationSection(WidgetRef ref, BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.currency_exchange, color: Colors.white),
        title: Text('Currency Denomination'.i18n, style: const TextStyle(color: Colors.white)),
        subtitle: Text(settings.currency.toUpperCase(), style: const TextStyle(color: Colors.grey)),
        onTap: () {
          showModalBottomSheet(
            backgroundColor: Colors.black,
            context: context,
            builder: (BuildContext context) {
              return DenominationChangeModalBottomSheet(
                settingsNotifier: settingsNotifier,
                initialTab: 'currency',
                showCurrencyOnly: true, // Show only currency options
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBitcoinUnitSection(WidgetRef ref, BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.currency_bitcoin, color: Colors.white),
        title: Text('Bitcoin unit'.i18n, style: const TextStyle(color: Colors.white)),
        subtitle: Text(settings.btcFormat == 'sats' ? 'Sats' : 'Bitcoin', style: const TextStyle(color: Colors.grey)),
        onTap: () {
          showModalBottomSheet(
            backgroundColor: Colors.black,
            context: context,
            builder: (BuildContext context) {
              return DenominationChangeModalBottomSheet(
                settingsNotifier: settingsNotifier,
                initialTab: 'denomination',
                showDenominationOnly: true, // Show only Bitcoin unit options
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLanguageSection(WidgetRef ref, BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.language, color: Colors.white),
        title: Text('Language'.i18n, style: const TextStyle(color: Colors.white)),
        subtitle: Text(settings.language.toUpperCase(), style: const TextStyle(color: Colors.grey)),
        onTap: () {
          showModalBottomSheet(
            backgroundColor: Colors.black,
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF212121),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Flag(Flags.portugal),
                      title: Text('Portuguese'.i18n, style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        settingsNotifier.setLanguage('pt');
                        context.pop();
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF212121),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Flag(Flags.united_states_of_america),
                      title: Text('English'.i18n, style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        settingsNotifier.setLanguage('en');
                        context.pop();
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAffiliateSection(BuildContext context, WidgetRef ref) {
    final affiliateCode = ref.watch(userProvider).affiliateCode ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.account_circle_sharp, color: Colors.white),
        title: Text('Affiliate Section'.i18n, style: const TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (affiliateCode.isNotEmpty)
              Text('${'Inserted Code:'.i18n} $affiliateCode', style: const TextStyle(color: Colors.grey))
            else
              GestureDetector(
                onTap: () => _showInsertAffiliateModal(context, 'Insert Affiliate Code', ref),
                child: Text(
                  'Insert an affiliate code to get a discount'.i18n,
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
      ),
    );
  }

  void _showInsertAffiliateModal(BuildContext context, String title, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    final hasNotCreatedUser = ref.watch(userProvider).paymentId.isEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF212121),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16.0,
              left: 0, // No left padding to allow edge-to-edge
              right: 0, // No right padding to allow edge-to-edge
            ),
            child: SingleChildScrollView(
              child: Container(
                // Removed margin to make the card edge-to-edge
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF212121),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.i18n,
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
                        labelText: 'Affiliate Code'.i18n,
                        labelStyle: const TextStyle(color: Colors.white),
                        border: const OutlineInputBorder(),
                        fillColor: Colors.black,
                        filled: true,
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    CustomElevatedButton(
                      text: 'Insert',
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      onPressed: () async {
                        final affiliateCode = controller.text;
                        if (affiliateCode.isNotEmpty && !hasNotCreatedUser) {
                          try {
                            await ref.read(addAffiliateCodeProvider(affiliateCode).future);
                            showMessageSnackBar(
                              message: 'Affiliate code inserted successfully'.i18n,
                              error: false,
                              context: context,
                              top: true,
                            );
                            // hammer fix
                            ref.invalidate(initializeUserProvider);
                            context.pop();
                          } catch (e) {
                            showMessageSnackBar(
                              message: 'Error inserting affiliate code'.i18n,
                              error: true,
                              context: context,
                              top: true,
                            );
                          }
                        } else if(affiliateCode.isNotEmpty && hasNotCreatedUser) {
                          ref.read(userProvider.notifier).setAffiliateCode(affiliateCode);
                          showMessageSnackBar(
                            message: 'Affiliate code inserted successfully'.i18n,
                            error: false,
                            context: context,
                            top: true,
                          );
                          context.pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeedSection(BuildContext context, WidgetRef ref) {
    final walletBackedUp = ref.watch(settingsProvider).backup;
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.currency_bitcoin, color: Colors.white),
        title: Text('View Seed Words'.i18n, style: const TextStyle(color: Colors.white)),
        subtitle: Text('Write them down and keep them safe!'.i18n, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
          walletBackedUp ? context.push('/open_seed_words_pin') : context.push('/seed_words');
        },
      ),
    );
  }
}

class DenominationChangeModalBottomSheet extends StatelessWidget {
  final dynamic settingsNotifier;
  final String initialTab;
  final bool showCurrencyOnly; // Show only currency options
  final bool showDenominationOnly; // Show only denomination options

  const DenominationChangeModalBottomSheet({
    super.key,
    required this.settingsNotifier,
    this.initialTab = 'currency',
    this.showCurrencyOnly = false,
    this.showDenominationOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.4,
              ),
              child: showDenominationOnly || initialTab == 'denomination'
                  ? _buildBitcoinFormatList(context, settingsNotifier)
                  : _buildCurrencyList(context, settingsNotifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyList(BuildContext context, settingsNotifier) {
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Color(0xFF212121),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Flag(Flags.brazil),
            title: const Text('BRL', style: TextStyle(color: Colors.white)),
            onTap: () {
              settingsNotifier.setCurrency('BRL');
              context.pop();
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Color(0xFF212121),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Flag(Flags.united_states_of_america),
            title: const Text('USD', style: TextStyle(color: Colors.white)),
            onTap: () {
              settingsNotifier.setCurrency('USD');
              context.pop();
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Color(0xFF212121),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Flag(Flags.european_union),
            title: const Text('EUR', style: TextStyle(color: Colors.white)),
            onTap: () {
              settingsNotifier.setCurrency('EUR');
              context.pop();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBitcoinFormatList(BuildContext context, settingsNotifier) {
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Color(0xFF212121),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: const Text('₿', style: TextStyle(color: Colors.white, fontSize: 24)),
            title: const Text('BTC', style: TextStyle(color: Colors.white)),
            onTap: () {
              settingsNotifier.setBtcFormat('BTC');
              context.pop();
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Color(0xFF212121),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: const Text('sats', style: TextStyle(color: Colors.white, fontSize: 24)),
            title: const Text('Satoshi', style: TextStyle(color: Colors.white)),
            onTap: () {
              settingsNotifier.setBtcFormat('sats');
              context.pop();
            },
          ),
        ),
      ],
    );
  }
}