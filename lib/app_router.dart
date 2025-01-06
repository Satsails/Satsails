import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/screens/explore/components/deposit.dart';
import 'package:Satsails/screens/explore/components/deposit_pix.dart';
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

class AppRouter {
  static GoRouter createRouter(String initialRoute) {
    return GoRouter(
      initialLocation: initialRoute,
      routes: [
        GoRoute(
          path: '/',
          name: 'start',
          builder: (context, state) => const Start(),
        ),
        GoRoute(
          path: '/transaction-details',
          name: 'transactionDetails',
          builder: (context, state) {
            final transaction = state.extra as BitcoinTransaction;
            return TransactionDetailsScreen(transaction: transaction);
          },
        ),
        GoRoute(
          path: '/liquid-transaction-details',
          name: 'liquidTransactionDetails',
          builder: (context, state) {
            final transaction = state.extra as LiquidTransaction;
            return LiquidTransactionDetailsScreen(transaction: transaction);
          },
        ),
        GoRoute(
          path: '/seed_words',
          name: 'seed_words',
          builder: (context, state) => const SeedWords(),
        ),
        GoRoute(
          path: '/open_pin',
          name: 'open_pin',
          builder: (context, state) => OpenPin(),
        ),
        GoRoute(
          path: '/open_seed_words_pin',
          name: 'open_seed_words_pin',
          builder: (context, state) => SeedWordsPin(),
        ),
        GoRoute(
          path: '/accounts',
          name: 'accounts',
          builder: (context, state) => const Accounts(),
        ),
        GoRoute(
          path: '/analytics',
          name: 'analytics',
          builder: (context, state) => const Analytics(),
        ),
        GoRoute(
          path: '/confirm_pin',
          name: 'confirm_pin',
          builder: (context, state) => const ConfirmPin(),
        ),
        GoRoute(
          path: '/set_pin',
          name: 'set_pin',
          builder: (context, state) => const SetPin(),
        ),
        GoRoute(
          path: '/apps',
          name: 'apps',
          builder: (context, state) => const Services(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const MainScreen(),
          routes: [
            GoRoute(
              path: '/pay',
              builder: (context, state) => Pay(),
              routes: [
                GoRoute(
                  path: '/confirm_bitcoin_payment',
                  builder: (context, state) => ConfirmBitcoinPayment(),
                ),
                GoRoute(
                  path: '/confirm_liquid_payment',
                  builder: (context, state) => ConfirmLiquidPayment(),
                ),
                GoRoute(
                  path: '/confirm_custodial_lightning_payment',
                  builder: (context, state) => ConfirmCustodialLightningPayment(),
                ),
              ],
            ),

            GoRoute(
              path: '/receive',
              builder: (context, state) => Receive(),
            ),
            GoRoute(
              path: '/explore',
              builder: (context, state) => const Explore(),
              routes: [
                GoRoute(
                    path: '/deposit',
                    builder: (context, state) => Deposit(),
                    routes: [
                      GoRoute(
                        path: '/deposit_pix',
                        builder: (context, state) => DepositPix(),
                      ),
                    ]
                ),
              ],
            ),
            GoRoute(
              path: '/exchange',
              builder: (context, state) => Exchange(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const Settings(),
            )
          ],
        ),
        GoRoute(
          path: '/recover_wallet',
          name: 'recover_wallet',
          builder: (context, state) => const RecoverWallet(),
        ),
        GoRoute(
          path: '/search_modal',
          name: 'search_modal',
          builder: (context, state) => const SearchModal(),
        ),
        GoRoute(
          path: '/backup_wallet',
          name: 'backup_wallet',
          builder: (context, state) => const BackupWallet(),
        ),
        GoRoute(
          path: '/pix_transaction_details',
          name: 'pix_transaction_details',
          builder: (context, state) => const PixTransactionDetails(),
        ),
        GoRoute(
          path: '/support',
          name: 'support',
          builder: (context, state) => const Support(),
        ),
      ],
    );
  }
}
