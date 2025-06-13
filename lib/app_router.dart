import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/screens/pay/components/confirm_boltz_payment.dart';
import 'package:Satsails/screens/pay/components/confirm_non_native_asset_payment.dart';
import 'package:Satsails/screens/shared/boltz_transactions_details_screen.dart';
import 'package:Satsails/screens/shared/nox_transaction_details.dart';
import 'package:Satsails/screens/shared/peg_details.dart';
import 'package:Satsails/screens/explore/components/deposit_pix_nox.dart';
import 'package:Satsails/screens/explore/components/deposit_depix_pix_eulen.dart';
import 'package:Satsails/screens/explore/components/deposit_type.dart';
import 'package:Satsails/screens/explore/components/sell_type.dart';
import 'package:Satsails/screens/explore/explore.dart';
import 'package:Satsails/screens/creation/confirm_pin.dart';
import 'package:Satsails/screens/login/seed_words_pin.dart';
import 'package:Satsails/screens/pay/components/camera.dart';
import 'package:Satsails/screens/pay/components/confirm_spark_bitcoin_payment.dart';
import 'package:Satsails/screens/pay/components/confirm_liquid_asset_payment.dart';
import 'package:Satsails/screens/shared/affiliate_screen.dart';
import 'package:Satsails/screens/shared/liquid_transaction_details_screen.dart';
import 'package:Satsails/screens/shared/sideshift_transaction_details_screen.dart';
import 'package:Satsails/screens/shared/transactions_details_screen.dart';
import 'package:Satsails/screens/transactions/transactions.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/screens/shared/eulen_transaction_details.dart';
import 'package:Satsails/screens/home/main_screen.dart';
import 'package:Satsails/screens/creation/start.dart';
import 'package:Satsails/screens/pay/components/confirm_liquid_payment.dart';
import 'package:Satsails/screens/settings/components/seed_words.dart';
import 'package:Satsails/screens/settings/settings.dart';
import 'package:Satsails/screens/receive/receive.dart';
import 'package:Satsails/screens/accounts/accounts.dart';
import 'package:Satsails/screens/creation/set_pin.dart';
import 'package:Satsails/screens/analytics/analytics.dart';
import 'package:Satsails/screens/login/open_pin.dart';
import 'package:Satsails/screens/services/services.dart';
import 'package:Satsails/screens/creation/recover_wallet.dart';
import 'package:Satsails/screens/pay/components/confirm_bitcoin_payment.dart';
import 'package:Satsails/screens/exchange/exchange.dart';
import 'package:Satsails/screens/home/components/search_modal.dart';
import 'package:Satsails/screens/settings/components/backup_wallet.dart';

import 'package:flutter/material.dart';

class AppRouter {
  /// Helper method: returns a [CustomTransitionPage] that
  /// applies a subtle scale+fade effect—ideal for a premium app.
  ///
  /// 1) Starts slightly scaled down (0.95) for a refined "zoom up" feel.
  /// 2) Simultaneously fades in from 0.0 to 1.0.
  /// 3) Uses a CurvedAnimation (easeOutCubic) for a smooth yet professional vibe.
  static CustomTransitionPage<void> _buildFadeScalePage({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration, // Explicitly set reverse duration
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Use different curves for enter/exit
        final isPush = animation.status == AnimationStatus.forward;

        final curve = isPush
            ? Curves.easeOutCubic
            : Curves.easeInCubic;

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: curve,
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }

  /// Creates a GoRouter with all your routes, each wrapped in our custom
  /// "fade+scale" page transition.
  static GoRouter createRouter(String initialRoute) {
    return GoRouter(
      initialLocation: initialRoute,
      redirect: (BuildContext context, GoRouterState state) {
        final uri = state.uri;
        if (uri.scheme == 'https' && uri.host == 'links.satsails.com') {
          return '/affiliate';
        }
        return null; // No redirect by default
      },
      routes: [
        GoRoute(
          path: '/affiliate',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const AffiliateScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/',
          name: 'start',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const Start(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/transaction-details',
          name: 'transactionDetails',
          pageBuilder: (context, state) {
            final transaction = state.extra as BitcoinTransaction;
            return _buildFadeScalePage(
              child: TransactionDetailsScreen(transaction: transaction),
              state: state,
            );
          },
        ),
        GoRoute(
          path: '/peg-details',
          name: 'pegDetails',
          pageBuilder: (context, state) {
            final transaction = state.extra as SideswapPegStatus;
            return _buildFadeScalePage(
              child: PegDetails(swap: transaction),
              state: state,
            );
          },
        ),
        GoRoute(
          path: '/liquid-transaction-details',
          name: 'liquidTransactionDetails',
          pageBuilder: (context, state) {
            final transaction = state.extra as LiquidTransaction;
            return _buildFadeScalePage(
              child: LiquidTransactionDetailsScreen(transaction: transaction),
              state: state,
            );
          },
        ),
        GoRoute(
          path: '/sideshift-transaction-details',
          name: 'sideshiftTransactionDetails',
          pageBuilder: (context, state) {
            final transaction = state.extra as SideShiftTransaction;
            return _buildFadeScalePage(
              child: SideShiftTransactionDetailsScreen(transaction: transaction),
              state: state,
            );
          },
        ),
        GoRoute(
          path: '/seed_words',
          name: 'seed_words',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const SeedWords(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/open_pin',
          name: 'open_pin',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const OpenPin(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/open_seed_words_pin',
          name: 'open_seed_words_pin',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const SeedWordsPin(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/accounts',
          name: 'accounts',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const Accounts(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/analytics',
          name: 'analytics',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const Analytics(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/confirm_pin',
          name: 'confirm_pin',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const ConfirmPin(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/set_pin',
          name: 'set_pin',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const SetPin(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/services',
          name: 'services',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const Services(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/camera',
          name: 'camera',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;

            final paymentType = extra != null && extra.containsKey('paymentType') && extra['paymentType'] is PaymentType
                ? extra['paymentType'] as PaymentType
                : PaymentType.Bitcoin;

            return _buildFadeScalePage(
              child: Camera(paymentType: paymentType),
              state: state,
            );
          },
        ),
        GoRoute(
          path: '/home',
          name: 'home', // Already named
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const MainScreen(),
            state: state,
          ),
          routes: [
            GoRoute(
              path: 'pay', // Corrected to relative path
              name: 'pay',
              redirect: (context, state) {
                final asset = (state.extra as String?)?.toLowerCase();
                switch (asset) {
                  case 'bitcoin':
                    return state.namedLocation('pay_bitcoin');
                  case 'liquid':
                    return state.namedLocation('pay_liquid');
                  case 'liquid_asset':
                    return state.namedLocation('pay_liquid_asset');
                  case 'non_native_asset':
                    return state.namedLocation('pay_non_native_asset');
                  case 'lightning':
                    return state.namedLocation('pay_boltz');
                }
                return null;
              },
              routes: [
                GoRoute(
                  path: 'confirm_bitcoin_payment', // Corrected to relative path
                  name: 'pay_bitcoin',
                  pageBuilder: (context, state) => _buildFadeScalePage(
                    child: ConfirmBitcoinPayment(key: UniqueKey()),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: 'confirm_liquid_payment', // Corrected to relative path
                  name: 'pay_liquid',
                  pageBuilder: (context, state) => _buildFadeScalePage(
                    child: ConfirmLiquidPayment(key: UniqueKey()),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: 'confirm_boltz_payment', // Corrected to relative path
                  name: 'pay_boltz',
                  pageBuilder: (context, state) => _buildFadeScalePage(
                    child: ConfirmBoltzPayment(key: UniqueKey()),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: 'confirm_liquid_asset_payment', // Added :assetId parameter
                  name: 'pay_liquid_asset',
                  pageBuilder: (context, state) => _buildFadeScalePage(
                    child: ConfirmLiquidAssetPayment(key: UniqueKey()),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: 'confirm_spark_bitcoin_payment', // Corrected to relative path
                  name: 'pay_spark_bitcoin',
                  pageBuilder: (context, state) => _buildFadeScalePage(
                    child: ConfirmSparkBitcoinPayment(key: UniqueKey()),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: 'confirm_non_native_asset_bitcoin_payment', // Corrected to relative path
                  name: 'pay_non_native_asset',
                  pageBuilder: (context, state) => _buildFadeScalePage(
                    child: ConfirmNonNativeAssetPayment(key: UniqueKey()),
                    state: state,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/receive',
              pageBuilder: (context, state) => _buildFadeScalePage(
                child: const Receive(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/explore',
              pageBuilder: (context, state) => _buildFadeScalePage(
                child: const Explore(),
                state: state,
              ),
              routes: [
                GoRoute(
                  path: '/sell_type',
                  pageBuilder: (context, state) => _buildFadeScalePage(
                    child: const SellType(),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: 'deposit_type',
                  pageBuilder: (context, state) => _buildFadeScalePage(
                    child: const DepositTypeScreen(),
                    state: state,
                  ),
                  routes: [
                      GoRoute(
                        path: '/deposit_pix_eulen',
                        name: 'DepositPixEulen',
                        pageBuilder: (context, state) => _buildFadeScalePage(
                          child: const DepositDepixPixEulen(),
                          state: state,
                        ),
                      ),
                      GoRoute(
                        path: '/deposit_pix_nox',
                        name: 'DepositPixNox',
                        pageBuilder: (context, state) => _buildFadeScalePage(
                          child: const DepositPixNox(),
                          state: state,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/exchange',
              pageBuilder: (context, state) => _buildFadeScalePage(
                child: const Exchange(),
                state: state,
              ),
            ),
            GoRoute(
              path: 'settings',
              pageBuilder: (context, state) => _buildFadeScalePage(
                child: const Settings(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/transactions',
              name: 'transactions',
              pageBuilder: (context, state) => _buildFadeScalePage(
                child: const Transactions(),
                state: state,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/recover_wallet',
          name: 'recover_wallet',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const RecoverWallet(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/search_modal',
          name: 'search_modal',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const SearchModal(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/backup_wallet',
          name: 'backup_wallet',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const BackupWallet(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/eulen_transaction_details',
          name: 'eulen_transaction_details',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const EulenTransactionDetails(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/nox_transaction_details',
          name: 'nox_transaction_details',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const NoxTransactionDetails(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/boltz_transaction_details',
          name: 'boltzTransactionDetails',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const BoltzTransactionDetailsScreen(),
            state: state,
          ),
        ),
      ],
    );
  }
}