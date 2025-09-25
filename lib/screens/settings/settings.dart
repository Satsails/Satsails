import 'dart:ui';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/delete_wallet_modal.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/models/settings_model.dart' as settings_model; // <--- FIX: Added import with prefix
import 'package:crisp_chat/crisp_chat.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
      FlutterCrispChat.setSessionString(
          key: "payment_id", value: user.paymentId);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricsAvailable = ref.watch(biometricsAvailableProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
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
                  _buildAffiliateSection(context, ref),
                  _buildSeedSection(context, ref),
                  biometricsAvailable.when(
                    data: (isAvailable) => isAvailable
                        ? _buildBiometricsSection(context, ref)
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  _buildLanguageSection(ref, context),
                  _buildCurrencyDenominationSection(ref, context),
                  _buildBitcoinUnitSection(ref, context),
                  _buildElectrumNodeSection(context, ref),
                  _buildBlockExplorerSection(context, ref),
                  DeleteWalletSection(ref: ref),
                ],
              ),
            ),
          ],
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
    final biometricsEnabled =
    ref.watch(settingsProvider.select((s) => s.biometricsEnabled));

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
        final settingsNotifier = ref.read(settingsProvider.notifier);
        final inAppReview = InAppReview.instance;

        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
          settingsNotifier.setReviewDone(true);
        } else {
          await inAppReview.openStoreListing(
              appStoreId: dotenv.env['APP_STORE_ID']!);
          settingsNotifier.setReviewDone(true);
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
      icon: Icons.key_rounded,
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
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) {
            return _buildLanguageModal(ref, context);
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
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) {
            return DenominationChangeModalBottomSheet(
              settingsNotifier: ref.read(settingsProvider.notifier),
              settings: settings,
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
      title: 'Bitcoin unit'.i18n,
      icon: Icons.currency_bitcoin,
      subtitle: Text(
        settings.btcFormat == 'sats' ? 'Sats' : 'Bitcoin',
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) {
            return DenominationChangeModalBottomSheet(
              settingsNotifier: ref.read(settingsProvider.notifier),
              settings: settings,
              initialTab: 'denomination',
              showDenominationOnly: true,
            );
          },
        );
      },
    );
  }

  Widget _buildElectrumNodeSection(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final subtitleText =
    settings.nodeType == 'Custom' ? settings.bitcoinElectrumNode : settings.nodeType;

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
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) {
            return _buildElectrumNodeModal(context, ref);
          },
        );
      },
    );
  }

  void _showCustomNodeModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _CustomNodeModalContent();
      },
    );
  }

  Widget _buildAffiliateSection(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final affiliateCode = user.affiliateCode;
    final bool hasAffiliateCode = affiliateCode != null && affiliateCode.isNotEmpty;

    return _buildSection(
      context: context,
      ref: ref,
      title: 'Affiliate Program'.i18n,
      icon: Icons.group_add_outlined,
      subtitle: Text(
        hasAffiliateCode
            ? "${'Affiliate code inserted'.i18n}: $affiliateCode"
            : 'Insert an affiliate code to get up to 6,67% discount on the fees'.i18n,
        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
      ),
      onTap: hasAffiliateCode
          ? null
          : () {
        _showInsertAffiliateModal(context, ref);
      },
    );
  }

  void _showInsertAffiliateModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _InsertAffiliateModalContent();
      },
    );
  }

  Widget _buildLanguageModal(WidgetRef ref, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Flag(Flags.portugal),
              title: Text('Portuguese'.i18n,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('pt');
                context.pop();
              },
            ),
            ListTile(
              leading: Flag(Flags.united_states_of_america),
              title: Text('English'.i18n,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('en');
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElectrumNodeModal(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.cloud_rounded, color: Colors.white, size: 24.sp),
              title: Text('Blockstream',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              onTap: () {
                ref.read(settingsProvider.notifier).setLiquidElectrumNode(
                    'elements-mainnet.blockstream.info:50002');
                ref.read(settingsProvider.notifier).setBitcoinElectrumNode(
                    'bitcoin-mainnet.blockstream.info:50002');
                ref.read(settingsProvider.notifier).setNodeType('Blockstream');
                ref.read(backgroundSyncNotifierProvider.notifier).performSync();
                context.pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.cloud_rounded, color: Colors.white, size: 24.sp),
              title: Text('BullBitcoin',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              onTap: () {
                ref.read(settingsProvider.notifier).setLiquidElectrumNode(
                    'les.bullbitcoin.com:995');
                ref.read(settingsProvider.notifier).setBitcoinElectrumNode(
                    'electrum.bullbitcoin.com:50002');
                ref.read(settingsProvider.notifier).setNodeType('Bull Bitcoin');
                ref.read(backgroundSyncNotifierProvider.notifier).performSync();
                context.pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.white, size: 24.sp),
              title: Text('Custom Node'.i18n,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              onTap: () {
                context.pop();
                _showCustomNodeModal(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DenominationChangeModalBottomSheet extends StatelessWidget {
  final dynamic settingsNotifier;
  final settings_model.Settings settings; // <--- FIX: Used prefixed type
  final String initialTab;
  final bool showCurrencyOnly;
  final bool showDenominationOnly;

  const DenominationChangeModalBottomSheet({
    super.key,
    required this.settingsNotifier,
    required this.settings,
    this.initialTab = 'currency',
    this.showCurrencyOnly = false,
    this.showDenominationOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCurrencyOnly)
                _buildCurrencyList(context, settingsNotifier),
              if (showDenominationOnly)
                _buildBitcoinFormatList(context, settingsNotifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyList(BuildContext context, settingsNotifier) {
    final currencies = [
      {'code': 'BRL', 'flag': Flag(Flags.brazil)},
      {'code': 'GBP', 'flag': Flag(Flags.united_kingdom)},
      {'code': 'CHF', 'flag': Flag(Flags.switzerland)},
      {'code': 'USD', 'flag': Flag(Flags.united_states_of_america)},
      {'code': 'EUR', 'flag': Flag(Flags.european_union)},
    ];

    return Column(
      children: currencies.map((currencyData) {
        final code = currencyData['code'] as String;
        final isSelected = settings.currency == code; // <--- FIX: This now works
        final tile = ListTile(
          leading: currencyData['flag'] as Widget,
          title: Text(code, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
          onTap: () {
            settingsNotifier.setCurrency(code);
            context.pop();
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        );

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 16.w),
          child: isSelected
              ? Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: tile,
          )
              : tile,
        );
      }).toList(),
    );
  }

  Widget _buildBitcoinFormatList(BuildContext context, settingsNotifier) {
    final formats = [
      {'key': 'BTC', 'label': 'BTC', 'icon': '₿'},
      {'key': 'sats', 'label': 'Satoshi', 'icon': 'sats'},
    ];

    return Column(
      children: formats.map((format) {
        final key = format['key']!;
        final isSelected = settings.btcFormat == key; // <--- FIX: This now works
        final tile = ListTile(
          leading: Text(format['icon']!, style: TextStyle(color: Colors.white, fontSize: 24.sp)),
          title: Text(format['label']!, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
          onTap: () {
            settingsNotifier.setBtcFormat(key);
            context.pop();
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        );

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 16.w),
          child: isSelected
              ? Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: tile,
          )
              : tile,
        );
      }).toList(),
    );
  }
}

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

  void handleSave() {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final backgroundSync = ref.read(backgroundSyncNotifierProvider.notifier);

    final newBitcoinNode = bitcoinController.text.trim();
    final newLiquidNode = liquidController.text.trim();

    settingsNotifier.setBitcoinElectrumNode(newBitcoinNode);
    settingsNotifier.setLiquidElectrumNode(newLiquidNode);
    settingsNotifier.setNodeType('Custom');

    backgroundSync.performSync();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF212121),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24.w,
                right: 24.w,
                top: 20.h),
            child: SingleChildScrollView(
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
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange, size: 20.sp),
                        SizedBox(width: 10.sp),
                        Expanded(
                          child: Text(
                            'Make sure the node you write works correctly, otherwise you might see wrong balances and not able to send your coins'
                                .i18n,
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
                  TextField(
                    controller: bitcoinController,
                    decoration: InputDecoration(
                      labelText: 'Bitcoin Node (host:port)'.i18n,
                      labelStyle:
                      TextStyle(color: Colors.white70, fontSize: 16.sp),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade800)),
                      fillColor: Colors.black,
                      filled: true,
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  SizedBox(height: 20.sp),
                  TextField(
                    controller: liquidController,
                    decoration: InputDecoration(
                      labelText: 'Liquid Node (host:port)'.i18n,
                      labelStyle:
                      TextStyle(color: Colors.white70, fontSize: 16.sp),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade800)),
                      fillColor: Colors.black,
                      filled: true,
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  SizedBox(height: 20.sp),
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

// --- Stateful Modal Content for Affiliate Code ---
class _InsertAffiliateModalContent extends ConsumerStatefulWidget {
  const _InsertAffiliateModalContent();

  @override
  ConsumerState<_InsertAffiliateModalContent> createState() =>
      _InsertAffiliateModalContentState();
}

class _InsertAffiliateModalContentState
    extends ConsumerState<_InsertAffiliateModalContent> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitAffiliateCode() async {
    final affiliateCode = _controller.text.trim();
    if (affiliateCode.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final hasNotCreatedUser = ref.read(userProvider).paymentId.isEmpty;

    try {
      if (hasNotCreatedUser) {
        ref.read(userProvider.notifier).setAffiliateCode(affiliateCode);
      } else {
        await ref.read(addAffiliateCodeProvider(affiliateCode).future);
        ref.invalidate(initializeUserProvider);
      }

      if (mounted) {
        showMessageSnackBar(
          message: 'Affiliate code inserted successfully'.i18n,
          error: false,
          context: context,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error inserting affiliate code'.i18n;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF212121),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24.w,
              right: 24.w,
              top: 20.h,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.group_add_outlined,
                    size: 40.sp,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Insert Affiliate Code'.i18n,
                    style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.2),
                      labelText: 'Affiliate Code'.i18n,
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.redAccent, fontSize: 14.sp),
                      ),
                    ),
                  SizedBox(height: 20.h),
                  _isLoading
                      ? Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                        size: 40.h, color: Colors.white),
                  )
                      : CustomButton(
                    text: 'Insert'.i18n,
                    onPressed: _submitAffiliateCode,
                    primaryColor: Colors.white.withOpacity(0.2),
                    secondaryColor: Colors.white.withOpacity(0.15),
                    textColor: Colors.white,
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}