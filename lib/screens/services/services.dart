import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/translations.dart';

class Services extends ConsumerStatefulWidget {
  const Services({super.key});

  @override
  _ServicesState createState() => _ServicesState();
}

class _ServicesState extends ConsumerState<Services> with AutomaticKeepAliveClientMixin {
  late WebViewController _webViewController;
  String _currentTitle = 'Dashboards';
  bool _isLoading = true;
  String _currentUrl = 'https://bitcoincounterflow.com/satsails/dashboards-iframe';

  @override
  void initState() {
    super.initState();
    final language = ref.read(settingsProvider).language;
    if (language == 'pt') {
      setState(() {
        _currentUrl  = 'https://bitcoincounterflow.com/pt/satsails-2/mini-paineis-iframe/';
      });
    }
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final language = ref.watch(settingsProvider).language;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading:
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            setState(() {
              _webViewController.reload();
            });
          },
        ),
        actions: [Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        ],
        title: Center(
          child: Text(
            _currentTitle.i18n,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: _buildDrawer(ref, context, language),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _webViewController,
          ),
          if (_isLoading)
            Center(
              child: LoadingAnimationWidget.fourRotatingDots(size: 100, color: Colors.orange),
            ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_currentUrl.contains('bitcoincounterflow'))
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () async {
                    if (await _webViewController.canGoBack()) {
                      _webViewController.goBack();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () async {
                    if (await _webViewController.canGoForward()) {
                      _webViewController.goForward();
                    }
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDrawer(WidgetRef ref, BuildContext context, String language) {
    final links = {
      'Dashboards': language == 'pt'
          ? 'https://bitcoincounterflow.com/pt/satsails-2/mini-paineis-iframe/'
          : 'https://bitcoincounterflow.com/satsails/dashboards-iframe',
      'ETF Tracker': language == 'pt'
          ? 'https://bitcoincounterflow.com/pt/satsails-2/etf-tracker-btc-iframe'
          : 'https://bitcoincounterflow.com/satsails/etf-tracker-iframe',
      'Retirement Calculator': language == 'pt'
          ? 'https://bitcoincounterflow.com/pt/satsails-2/calculadora-de-aposentadoria-bitcoin-iframe/'
          : 'https://bitcoincounterflow.com/satsails/bitcoin-retirement-calculator-iframe/',
      'Bitcoin Converter': language == 'pt'
          ? 'https://bitcoincounterflow.com/pt/satsails-2/calculadora-conversora-bitcoin-iframe/'
          : 'https://bitcoincounterflow.com/satsails/bitcoin-converter-calculator-iframe/',
      'DCA Calculator': language == 'pt'
          ? 'https://bitcoincounterflow.com/pt/satsails-2/calculadora-dca-iframe/'
          : 'https://bitcoincounterflow.com/satsails/dca-calculator-iframe/',
      'Bitcoin Counterflow Strategy': language == 'pt'
          ? 'https://bitcoincounterflow.com/pt/satsails-2/estrategia-counterflow-iframe/'
          : 'https://bitcoincounterflow.com/satsails/bitcoin-counterflow-strategy-iframe/',
      'Charts': language == 'pt'
          ? 'https://bitcoincounterflow.com/pt/satsails-2/graficos-bitcoin-iframe/'
          : 'https://bitcoincounterflow.com/satsails/charts-iframe',
      'Liquidation Zone': language == 'pt'
          ? 'https://bitcoincounterflow.com/pt/satsails-2/zona-de-liquidacao-iframe/'
          : 'https://bitcoincounterflow.com/satsails/liquidation-heatmap-iframe/',
      'Bitrefill': language == 'pt'
          ? 'https://www.bitrefill.com/pt/pt/'
          : 'https://www.bitrefill.com',
    };

    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(
                  bottom: BorderSide.none,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Services'.i18n,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            ExpansionTile(
              leading: const Icon(Icons.school, color: Colors.orange),
              title: Text('Educação Real'.i18n, style: const TextStyle(color: Colors.white)),
              children: [
                _buildDrawerItem(
                  ref,
                  icon: Icons.arrow_right,
                  title: 'Courses',
                  url: 'https://www.educacaoreal.com',
                ),
              ],
            ),
            _buildDrawerItem(
              ref,
              icon: Icons.dashboard,
              title: 'Dashboards',
              url: links['Dashboards']!,
            ),
            _buildDrawerItem(
              ref,
              icon: Icons.assessment,
              title: 'ETF Tracker',
              url: links['ETF Tracker']!,
            ),
            _buildDrawerItem(
              ref,
              icon: Icons.calculate,
              title: 'Retirement Calculator',
              url: links['Retirement Calculator']!,
            ),
            _buildDrawerItem(
              ref,
              icon: Icons.attach_money,
              title: 'Bitcoin Converter',
              url: links['Bitcoin Converter']!,
            ),
            _buildDrawerItem(
              ref,
              icon: Icons.history,
              title: 'DCA Calculator',
              url: links['DCA Calculator']!,
            ),
            _buildDrawerItem(
              ref,
              icon: Icons.trending_up,
              title: 'Bitcoin Counterflow Strategy',
              url: links['Bitcoin Counterflow Strategy']!,
            ),
            _buildDrawerItem(
              ref,
              icon: Icons.show_chart,
              title: 'Charts',
              url: links['Charts']!,
            ),
            _buildDrawerItem(
              ref,
              icon: Icons.waterfall_chart,
              title: 'Liquidation Zone',
              url: links['Liquidation Zone']!,
            ),
            _buildDrawerItem(
              ref,
              icon: Icons.shopping_cart,
              title: 'Bitrefill',
              url: links['Bitrefill']!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(WidgetRef ref, {required IconData icon, required String title, required String url}) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(
        title.i18n,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _currentUrl = url;
          _currentTitle = title;
          _webViewController.loadRequest(Uri.parse(url));
        });
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
