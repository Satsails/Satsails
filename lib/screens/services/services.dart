import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/screens/shared/bottom_navigation_bar.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/providers/navigation_provider.dart';

class Services extends ConsumerWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black, // Ensure background stays black
      appBar: AppBar(
        title: Center(
          child: Text(
            'Services'.i18n(ref),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black, // Ensure the app bar is black
      ),
      drawer: _buildDrawer(ref, context), // Add the drawer here
      body: const ServiceWebView(url: 'https://www.educacaoreal.com/'), // Default WebView on page load
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: ref.watch(navigationProvider),
        context: context,
        onTap: (int index) {
          ref.read(navigationProvider.notifier).state = index;
        },
      ),
    );
  }

  // Create a drawer (sidebar)
  Widget _buildDrawer(WidgetRef ref, BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black, // Background color of the drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.orange, // Header background color
              ),
              child: Center(
                child: Text(
                  'Services'.i18n(ref),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // List of services
            _buildDrawerItem(
              context,
              ref,
              icon: Icons.language,
              title: 'Education Real',
              url: 'https://www.educacaoreal.com/',
            ),
            _buildDrawerItem(
              context,
              ref,
              icon: Icons.dashboard,
              title: 'Dashboards',
              url: 'https://bitcoincounterflow.com/satsails/dashboards-iframe',
            ),
            _buildDrawerItem(
              context,
              ref,
              icon: Icons.assessment,
              title: 'ETF Tracker',
              url: 'https://bitcoincounterflow.com/satsails/etf-tracker-iframe',
            ),
            _buildDrawerItem(
              context,
              ref,
              icon: Icons.calculate,
              title: 'Retirement Calculator',
              url: 'https://bitcoincounterflow.com/satsails/bitcoin-retirement-calculator-iframe/',
            ),
            _buildDrawerItem(
              context,
              ref,
              icon: Icons.attach_money,
              title: 'Bitcoin Converter',
              url: 'https://bitcoincounterflow.com/satsails/bitcoin-converter-calculator-iframe/',
            ),
            _buildDrawerItem(
              context,
              ref,
              icon: Icons.history,
              title: 'DCA Calculator',
              url: 'https://bitcoincounterflow.com/satsails/dca-calculator-iframe/',
            ),
            _buildDrawerItem(
              context,
              ref,
              icon: Icons.trending_up,
              title: 'Bitcoin Counterflow Strategy',
              url: 'https://bitcoincounterflow.com/satsails/bitcoin-counterflow-strategy-iframe/',
            ),
            _buildDrawerItem(
              context,
              ref,
              icon: Icons.show_chart,
              title: 'Charts',
              url: 'https://bitcoincounterflow.com/satsails/charts-iframe',
            ),
            _buildDrawerItem(
              context,
              ref,
              icon: Icons.waterfall_chart,
              title: 'Liquidation Zone',
              url: 'https://bitcoincounterflow.com/satsails/pt/zona-de-liquidacao-iframe',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create each drawer item
  Widget _buildDrawerItem(BuildContext context, WidgetRef ref, {required IconData icon, required String title, required String url}) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(
        title.i18n(ref),
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceWebView(url: url), // Pass the URL to the WebView
          ),
        );
      },
    );
  }
}

class ServiceWebView extends StatefulWidget {
  final String url;

  const ServiceWebView({super.key, required this.url});

  @override
  _ServiceWebViewState createState() => _ServiceWebViewState();
}

class _ServiceWebViewState extends State<ServiceWebView> with AutomaticKeepAliveClientMixin {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url)); // Load the specific URL
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
