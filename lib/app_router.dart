import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/screens/explore/components/deposit_bitcoin_pix_nox.dart';
import 'package:Satsails/screens/explore/components/deposit_method.dart';
import 'package:Satsails/screens/explore/components/deposit_depix_pix_eulen.dart';
import 'package:Satsails/screens/explore/components/deposit_provider.dart';
import 'package:Satsails/screens/explore/components/deposit_type.dart';
import 'package:Satsails/screens/explore/components/sell_type.dart';
import 'package:Satsails/screens/explore/explore.dart';
import 'package:Satsails/screens/creation/confirm_pin.dart';
import 'package:Satsails/screens/login/seed_words_pin.dart';
import 'package:Satsails/screens/pay/components/confirm_custodial_lightning_payment.dart';
import 'package:Satsails/screens/shared/liquid_transaction_details_screen.dart';
import 'package:Satsails/screens/shared/transactions_details_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/screens/analytics/components/pix_transaction_details.dart';
import 'package:Satsails/screens/home/main_screen.dart';
import 'package:Satsails/screens/settings/components/support.dart';
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
import 'package:Satsails/screens/pay/pay.dart';
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
      routes: [
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
            child: OpenPin(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/open_seed_words_pin',
          name: 'open_seed_words_pin',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: SeedWordsPin(),
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
          path: '/apps',
          name: 'apps',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const Services(),
            state: state,
          ),
        ),
        // Main screen with subroutes
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const MainScreen(),
            state: state,
          ),
          routes: [
            GoRoute(
              path: '/pay',
              pageBuilder: (context, state) => _buildFadeScalePage(
                child: Pay(),
                state: state,
              ),
              routes: [
                GoRoute(
                  path: '/confirm_bitcoin_payment',
                  pageBuilder: (context, state) => _buildFadeScalePage(
                    child: ConfirmBitcoinPayment(),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: '/confirm_liquid_payment',
                  pageBuilder: (context, state) => _buildFadeScalePage(
                    child: ConfirmLiquidPayment(),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: '/confirm_custodial_lightning_payment',
                  pageBuilder: (context, state) => _buildFadeScalePage(
                    child: ConfirmCustodialLightningPayment(),
                    state: state,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/deposit_type',
              pageBuilder: (context, state) => _buildFadeScalePage(
                child: DepositType(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/receive',
              pageBuilder: (context, state) => _buildFadeScalePage(
                child: Receive(),
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
                    child: SellType(),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: 'deposit_type',
                  pageBuilder: (context, state) => _buildFadeScalePage(
                    child: DepositType(),
                    state: state,
                  ),
                  routes: [
                    GoRoute(
                      path: 'deposit_method',
                      pageBuilder: (context, state) => _buildFadeScalePage(
                        child: DepositMethod(),
                        state: state,
                      ),
                      routes: [
                        GoRoute(
                          path: 'deposit_provider',
                          pageBuilder: (context, state) => _buildFadeScalePage(
                            child: DepositProvider(),
                            state: state,
                          ),
                          routes: [
                            GoRoute(
                              path: 'deposit_pix_eulen',
                              pageBuilder: (context, state) => _buildFadeScalePage(
                                child: DepositDepixPixEulen(),
                                state: state,
                              ),
                            ),
                            GoRoute(
                              path: 'deposit_pix_nox',
                              pageBuilder: (context, state) => _buildFadeScalePage(
                                child: DepositBitcoinPixNox(),
                                state: state,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/exchange',
              pageBuilder: (context, state) => _buildFadeScalePage(
                child: Exchange(),
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
          path: '/pix_transaction_details',
          name: 'pix_transaction_details',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const PixTransactionDetails(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/support',
          name: 'support',
          pageBuilder: (context, state) => _buildFadeScalePage(
            child: const Support(),
            state: state,
          ),
        ),
      ],
    );
  }
}