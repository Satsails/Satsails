import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
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
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';

final biometricsAvailableProvider = FutureProvider<bool>((ref) async {
  try {
    return await LocalAuthentication().canCheckBiometrics;
  } catch (e) {
    return false;
  }
});

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
    final biometricsAvailable = ref.watch(biometricsAvailableProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text(
            'Settings'.i18n,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 14.sp,
                  right: 14.sp,
                  top: 14.sp,
                  bottom: 14.sp + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildChatWithSupportSection(context, ref),
                    _buildRateAppSection(context, ref),
                    _buildSeedSection(context, ref),
                    biometricsAvailable.when(
                      data: (isAvailable) => isAvailable ? _buildBiometricsSection(context, ref) : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    _buildLanguageSection(ref, context),
                    _buildCurrencyDenominationSection(ref, context),
                    _buildBitcoinUnitSection(ref, context),
                    _buildElectrumNodeSection(context, ref),
                    _buildAffiliateSection(context, ref),
                    _buildBlockExplorerSection(context, ref),
                    DeleteWalletSection(ref: ref),
                  ],
                ),
              ),
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
    VoidCallback? onTap,
    Widget? subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.sp),
      decoration: BoxDecoration(
        color: const Color(0x00333333).withOpacity(0.4),
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
        leading: Icon(icon, color: Colors.white, size: 24.sp),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildBiometricsSection(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final biometricsEnabled = ref.watch(settingsProvider.select((s) => s.biometricsEnabled));

    return _buildSection(
      context: context,
      ref: ref,
      title: 'Biometric Unlock'.i18n,
      icon: Icons.fingerprint,
      subtitle: Text(
        'Use your fingerprint or face to unlock'.i18n,
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: () {
        settingsNotifier.setBiometricsEnabled(!biometricsEnabled);
      },
      trailing: Switch(
        value: biometricsEnabled,
        onChanged: (value) {
          settingsNotifier.setBiometricsEnabled(value);
        },
        activeColor: Colors.white,
        inactiveTrackColor: Colors.grey[800],
      ),
    );
  }

  Widget _buildRateAppSection(BuildContext context, WidgetRef ref) {
    return _buildSection(
      context: context,
      ref: ref,
      title: 'Rate the App'.i18n,
      icon: Icons.star,
      subtitle: Text(
        'Help us improve by rating the app!'.i18n,
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: () async {
        final InAppReview inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
        } else {
          await inAppReview.openStoreListing(appStoreId: dotenv.env['APP_STORE_ID']!);
        }
      },
    );
  }

  Widget _buildBlockExplorerSection(BuildContext context, WidgetRef ref) {
    return _buildSection(
      context: context,
      ref: ref,
      title: 'Search the blockchain'.i18n,
      icon: Clarity.block_solid,
      subtitle: Text(
        'mempool.space',
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
      title: 'View Seed Words'.i18n,
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
      title: 'Chat with support'.i18n,
      icon: Icons.support_agent,
      subtitle: Text(
        'Chat with us for help!'.i18n,
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
      title: 'Language'.i18n,
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
            return SafeArea(
              bottom: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
                    decoration: BoxDecoration(
                      color: const Color(0x00333333).withOpacity(0.4),
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
                      color: const Color(0x00333333).withOpacity(0.4),
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
              ),
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
      title: 'Currency Denomination'.i18n,
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
            return SafeArea(
              bottom: true,
              child: DenominationChangeModalBottomSheet(
                settingsNotifier: ref.read(settingsProvider.notifier),
                initialTab: 'currency',
                showCurrencyOnly: true,
              ),
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
      title: 'Bitcoin unit'.i18n,
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
            return SafeArea(
              bottom: true,
              child: DenominationChangeModalBottomSheet(
                settingsNotifier: ref.read(settingsProvider.notifier),
                initialTab: 'denomination',
                showDenominationOnly: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildElectrumNodeSection(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final subtitleText = settings.nodeType == 'Custom' ? settings.bitcoinElectrumNode : settings.nodeType;

    return _buildSection(
      context: context,
      ref: ref,
      title: 'Select Electrum Node'.i18n,
      icon: Icons.cloud,
      subtitle: Text(
        subtitleText,
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.black,
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              bottom: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
                    decoration: BoxDecoration(
                      color: const Color(0x00333333).withOpacity(0.4),
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
                        ref.read(settingsProvider.notifier).setLiquidElectrumNode('elements-mainnet.blockstream.info:50002');
                        ref.read(settingsProvider.notifier).setBitcoinElectrumNode('bitcoin-mainnet.blockstream.info:50002');
                        ref.read(settingsProvider.notifier).setNodeType('Blockstream');
                        ref.read(backgroundSyncNotifierProvider.notifier).performSync();
                        context.pop();
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
                    decoration: BoxDecoration(
                      color: const Color(0x00333333).withOpacity(0.4),
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
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
                    decoration: BoxDecoration(
                      color: const Color(0x00333333).withOpacity(0.4),
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
                      leading: Icon(Icons.edit, color: Colors.white, size: 24.sp),
                      title: Text(
                        'Custom Node'.i18n,
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                      onTap: () {
                        context.pop();
                        _showCustomNodeModal(context, ref);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomNodeModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _CustomNodeModalContent();
      },
    );
  }

  Widget _buildAffiliateSection(BuildContext context, WidgetRef ref) {
    return _buildSection(
      context: context,
      ref: ref,
      title: 'Affiliate Section'.i18n,
      icon: Icons.account_circle_sharp,
      subtitle: Text(
        'Insert an affiliate code to get 6.67% cashback on purchases'.i18n,
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: () {
        showMessageSnackBar(context: context, message: 'Coming soon'.i18n, error: true);
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
            showMessageSnackBar(context: context, message: '$label copied to clipboard!'.i18n, error: false);
          },
        ),
      ],
    );
  }

  void _showInsertAffiliateModal(BuildContext context, String title, WidgetRef ref) {
    final controller = TextEditingController();
    final hasNotCreatedUser = ref.watch(userProvider).paymentId.isEmpty;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          bottom: true,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16.sp, top: 16.sp, left: 0, right: 0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: const Color(0x00333333).withOpacity(0.4),
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
            color: const Color(0x00333333).withOpacity(0.4),
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
            color: const Color(0x00333333).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4.0, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            leading: Flag(Flags.united_kingdom),
            title: Text('GBP', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
            onTap: () {
              settingsNotifier.setCurrency('GBP');
              context.pop();
            },
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
          decoration: BoxDecoration(
            color: const Color(0x00333333).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4.0, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            leading: Flag(Flags.switzerland),
            title: Text('CHF', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
            onTap: () {
              settingsNotifier.setCurrency('CHF');
              context.pop();
            },
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
          decoration: BoxDecoration(
            color: const Color(0x00333333).withOpacity(0.4),
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
            color: const Color(0x00333333).withOpacity(0.4),
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
            color: const Color(0x00333333).withOpacity(0.4),
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
            color: const Color(0x00333333).withOpacity(0.4),
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

// This widget encapsulates the UI and logic for the custom node modal.
class _CustomNodeModalContent extends ConsumerStatefulWidget {
  const _CustomNodeModalContent();

  @override
  ConsumerState<_CustomNodeModalContent> createState() =>
      _CustomNodeModalContentState();
}

class _CustomNodeModalContentState
    extends ConsumerState<_CustomNodeModalContent> {
  late final TextEditingController bitcoinController;
  late final TextEditingController liquidController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    bitcoinController =
        TextEditingController(text: settings.bitcoinElectrumNode);
    liquidController =
        TextEditingController(text: settings.liquidElectrumNode);
  }

  @override
  void dispose() {
    bitcoinController.dispose();
    liquidController.dispose();
    super.dispose();
  }

  // This function now simply saves the user's input without validation.
  void handleSave() {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final backgroundSync = ref.read(backgroundSyncNotifierProvider.notifier);

    // Get text from controllers and save it directly.
    final newBitcoinNode = bitcoinController.text.trim();
    final newLiquidNode = liquidController.text.trim();

    settingsNotifier.setBitcoinElectrumNode(newBitcoinNode);
    settingsNotifier.setLiquidElectrumNode(newLiquidNode);
    settingsNotifier.setNodeType('Custom');

    // Trigger a sync with the new node configuration.
    backgroundSync.performSync();

    // Close the modal.
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.sp,
              top: 16.sp,
              left: 16.sp,
              right: 16.sp),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: const Color(0x00333333).withOpacity(0.4),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Custom Electrum Node'.i18n,
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 16.sp),
                  // Warning Message
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20.sp),
                        SizedBox(width: 10.sp),
                        Expanded(
                          child: Text(
                            'Make sure the node you write works correctly, otherwise you might see wrong balances and not able to send your coins'.i18n,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  // Bitcoin Node TextField
                  TextField(
                    controller: bitcoinController,
                    decoration: InputDecoration(
                      labelText: 'Bitcoin Node (host:port)'.i18n,
                      labelStyle: TextStyle(
                          color: Colors.white70, fontSize: 16.sp),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.grey.shade800)),
                      fillColor: Colors.black,
                      filled: true,
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp),
                  ),
                  SizedBox(height: 20.sp),
                  // Liquid Node TextField
                  TextField(
                    controller: liquidController,
                    decoration: InputDecoration(
                      labelText: 'Liquid Node (host:port)'.i18n,
                      labelStyle: TextStyle(
                          color: Colors.white70, fontSize: 16.sp),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.grey.shade800)),
                      fillColor: Colors.black,
                      filled: true,
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp),
                  ),
                  SizedBox(height: 20.sp),
                  // Simplified Save & Exit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: handleSave,
                    child: Text(
                      'Save & Exit'.i18n,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}