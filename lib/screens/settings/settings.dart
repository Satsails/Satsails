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
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:crisp_chat/crisp_chat.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Satsails/providers/coinos_provider.dart'; // Assuming this is where coinosLnProvider is defined

class Settings extends ConsumerWidget {
  const Settings({super.key});

  Future<void> _openCrispChat(WidgetRef ref) async {
    final user = ref.read(userProvider);
    final config = CrispConfig(
      websiteID: dotenv.env['CRISP_ID']!,
      user: User(nickName: user.paymentId),
    );
    try {
      await FlutterCrispChat.openCrispChat(config: config);
      FlutterCrispChat.setSessionString(key: "payment_id", value: user.paymentId);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coinosLn = ref.watch(coinosLnProvider);
    final showCoinosMigration = coinosLn.token.isNotEmpty;

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
          title: Text(
            'Settings'.i18n,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.sp), // Updated body padding
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
              if (showCoinosMigration) _buildCoinosMigrationSection(context, ref),
              DeleteWalletSection(ref: ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? subtitle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.sp), // Updated margin between sections
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
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
        contentPadding: EdgeInsets.all(24.sp), // Updated internal padding
        leading: Icon(icon, color: Colors.white, size: 24.sp),
        title: Text(
          title.i18n,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
        subtitle: subtitle,
        onTap: onTap,
      ),
    );
  }

  Widget _buildBlockExplorerSection(BuildContext context, WidgetRef ref) {
    return _buildSection(
      context: context,
      ref: ref,
      title: 'Search the blockchain',
      icon: Clarity.block_solid,
      subtitle: Text(
        'mempool.com',
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: () {
        clearTransactionSearch(ref);
        context.push('/search_modal');
      },
    );
  }

  Widget _buildSeedSection(BuildContext context, WidgetRef ref) {
    final walletBackedUp = ref.watch(settingsProvider).backup;
    return _buildSection(
      context: context,
      ref: ref,
      title: 'View Seed Words',
      icon: Icons.currency_bitcoin,
      subtitle: Text(
        'Write them down and keep them safe!'.i18n,
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: () {
        walletBackedUp
            ? context.push('/open_seed_words_pin')
            : context.push('/seed_words');
      },
    );
  }

  Widget _buildChatWithSupportSection(BuildContext context, WidgetRef ref) {
    return _buildSection(
      context: context,
      ref: ref,
      title: 'Chat with support',
      icon: Icons.support_agent,
      subtitle: Text(
        'Talk to us on Telegram'.i18n,
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: () async {
        await _openCrispChat(ref);
      },
    );
  }

  Widget _buildLanguageSection(WidgetRef ref, BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return _buildSection(
      context: context,
      ref: ref,
      title: 'Language',
      icon: Icons.language,
      subtitle: Text(
        settings.language.toUpperCase(),
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.black,
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212121),
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
                    title: Text(
                      'Portuguese'.i18n,
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                    onTap: () {
                      ref.read(settingsProvider.notifier).setLanguage('pt');
                      context.pop();
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212121),
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
                    title: Text(
                      'English'.i18n,
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                    onTap: () {
                      ref.read(settingsProvider.notifier).setLanguage('en');
                      context.pop();
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCurrencyDenominationSection(WidgetRef ref, BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return _buildSection(
      context: context,
      ref: ref,
      title: 'Currency Denomination',
      icon: Icons.currency_exchange,
      subtitle: Text(
        settings.currency.toUpperCase(),
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.black,
          context: context,
          builder: (BuildContext context) {
            return DenominationChangeModalBottomSheet(
              settingsNotifier: ref.read(settingsProvider.notifier),
              initialTab: 'currency',
              showCurrencyOnly: true,
            );
          },
        );
      },
    );
  }

  Widget _buildBitcoinUnitSection(WidgetRef ref, BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return _buildSection(
      context: context,
      ref: ref,
      title: 'Bitcoin unit',
      icon: Icons.currency_bitcoin,
      subtitle: Text(
        settings.btcFormat == 'sats' ? 'Sats' : 'Bitcoin',
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.black,
          context: context,
          builder: (BuildContext context) {
            return DenominationChangeModalBottomSheet(
              settingsNotifier: ref.read(settingsProvider.notifier),
              initialTab: 'denomination',
              showDenominationOnly: true,
            );
          },
        );
      },
    );
  }

  Widget _buildElectrumNodeSection(BuildContext context, WidgetRef ref) {
    return _buildSection(
      context: context,
      ref: ref,
      title: 'Select Electrum Node',
      icon: Icons.cloud,
      subtitle: Text(
        ref.watch(settingsProvider).nodeType,
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.black,
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212121),
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
                    leading: Icon(Icons.cloud, color: Colors.white, size: 24.sp),
                    title: Text(
                      'Blockstream',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
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
                  margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212121),
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
                    leading: Icon(Icons.cloud, color: Colors.white, size: 24.sp),
                    title: Text(
                      'BullBitcoin',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
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
    );
  }

  Widget _buildAffiliateSection(BuildContext context, WidgetRef ref) {
    final affiliateCode = ref.watch(userProvider).affiliateCode ?? '';
    return _buildSection(
      context: context,
      ref: ref,
      title: 'Affiliate Section',
      icon: Icons.account_circle_sharp,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (affiliateCode.isNotEmpty)
            Text(
              '${'Inserted Code:'.i18n} $affiliateCode',
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            )
          else
            GestureDetector(
              onTap: () => _showInsertAffiliateModal(context, 'Insert Affiliate Code', ref),
              child: Text(
                'Insert an affiliate code to get a discount'.i18n,
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
        ],
      ),
      onTap: () {
        if (affiliateCode.isEmpty) _showInsertAffiliateModal(context, 'Insert Affiliate Code', ref);
      },
    );
  }

  Widget _buildCoinosMigrationSection(BuildContext context, WidgetRef ref) {
    return _buildSection(
      context: context,
      ref: ref,
      title: 'Coinos Migration',
      icon: Icons.cloud,
      onTap: () {
        _showCustodialWarningModal(context, ref);
      },
    );
  }

  void _showCustodialWarningModal(BuildContext context, WidgetRef ref) {
    final coinosLn = ref.watch(coinosLnProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(24.sp), // Updated padding for modal
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custodial Lightning Warning'.i18n,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.sp),
                Text(
                  'You can retreive your past coinos balances since we have migrated to spark'.i18n,
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
                SizedBox(height: 24.sp),
                _buildCopyableField(label: 'Username', value: coinosLn.username, context: context),
                SizedBox(height: 16.sp),
                _buildCopyableField(label: 'Password', value: coinosLn.password, context: context),
                SizedBox(height: 24.sp),
                Center(
                  child: TextButton(
                    onPressed: () => _launchURL('https://coinos.io/login'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24.sp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Visit Coinos'.i18n,
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
          ),
        );
      },
    );
  }

  Widget _buildCopyableField({required String label, required String value, required BuildContext context}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4.0),
              SelectableText(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, color: Colors.white),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            showMessageSnackBar(context: context, message: '$label copied to clipboard!', error: false);
          },
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showInsertAffiliateModal(BuildContext context, String title, WidgetRef ref) {
    final controller = TextEditingController();
    final hasNotCreatedUser = ref.watch(userProvider).paymentId.isEmpty;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF212121),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16.sp, top: 16.sp, left: 0, right: 0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: const Color(0xFF212121),
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
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Affiliate Code'.i18n,
                        labelStyle: TextStyle(color: Colors.white, fontSize: 16.sp),
                        border: const OutlineInputBorder(),
                        fillColor: Colors.black,
                        filled: true,
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                    SizedBox(height: 20.sp),
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
                        } else if (affiliateCode.isNotEmpty && hasNotCreatedUser) {
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
}

class DenominationChangeModalBottomSheet extends StatelessWidget {
  final dynamic settingsNotifier;
  final String initialTab;
  final bool showCurrencyOnly;
  final bool showDenominationOnly;

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
              constraints: BoxConstraints(maxHeight: screenHeight * 0.4),
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
          margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
          decoration: BoxDecoration(
            color: const Color(0xFF212121),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4.0, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            leading: Flag(Flags.brazil),
            title: Text('BRL', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
            onTap: () {
              settingsNotifier.setCurrency('BRL');
              context.pop();
            },
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
          decoration: BoxDecoration(
            color: const Color(0xFF212121),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4.0, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            leading: Flag(Flags.united_states_of_america),
            title: Text('USD', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
            onTap: () {
              settingsNotifier.setCurrency('USD');
              context.pop();
            },
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
          decoration: BoxDecoration(
            color: const Color(0xFF212121),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4.0, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            leading: Flag(Flags.european_union),
            title: Text('EUR', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
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
          margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
          decoration: BoxDecoration(
            color: const Color(0xFF212121),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4.0, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            leading: Text('₿', style: TextStyle(color: Colors.white, fontSize: 24.sp)),
            title: Text('BTC', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
            onTap: () {
              settingsNotifier.setBtcFormat('BTC');
              context.pop();
            },
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
          decoration: BoxDecoration(
            color: const Color(0xFF212121),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4.0, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            leading: Text('sats', style: TextStyle(color: Colors.white, fontSize: 24.sp)),
            title: Text('Satoshi', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
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