import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Services extends ConsumerStatefulWidget {
  const Services({super.key});

  @override
  _ServicesState createState() => _ServicesState();
}

class _ServicesState extends ConsumerState<Services> {
  late WebViewController _webViewController;
  String _currentTitle = 'Dashboards';
  bool _isLoading = true;
  String _currentUrl = 'https://bitcoincounterflow.com/satsails/dashboards-iframe';
  int _selectedIndex = 0; // Track selected item

  @override
  void initState() {
    super.initState();
    final language = ref.read(settingsProvider).language;
    if (language == 'pt') {
      setState(() {
        _currentUrl = 'https://bitcoincounterflow.com/pt/satsails-2/mini-paineis-iframe/';
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
    final language = ref.watch(settingsProvider).language;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Market Data'.i18n,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.w),
          onPressed: () async {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 24.w),
            onPressed: () {
              setState(() {
                _webViewController.reload();
              });
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.white, size: 24.w),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(ref, context, language),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _webViewController,
          ),
          if (_isLoading)
            Center(
              child: LoadingAnimationWidget.fourRotatingDots(size: 100.w, color: Colors.orange),
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
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.w),
                  onPressed: () async {
                    if (await _webViewController.canGoBack()) {
                      _webViewController.goBack();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: Colors.white, size: 24.w),
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
    };

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0x333333).withOpacity(0.4),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0x333333).withOpacity(0.4),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Services'.i18n,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 24.w),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            ...links.entries.map((entry) {
              final index = links.keys.toList().indexOf(entry.key);
              return ListTile(
                leading: Icon(
                  _getIconForTitle(entry.key),
                  color: _selectedIndex == index ? Colors.orange : Colors.white,
                  size: 24.w,
                ),
                title: Text(
                  entry.key.i18n,
                  style: TextStyle(
                    color: _selectedIndex == index ? Colors.orange : Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _currentUrl = entry.value;
                    _currentTitle = entry.key;
                    _webViewController.loadRequest(Uri.parse(_currentUrl));
                    _selectedIndex = index;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Dashboards':
        return Icons.dashboard;
      case 'ETF Tracker':
        return Icons.assessment;
      case 'Retirement Calculator':
        return Icons.calculate;
      case 'Bitcoin Converter':
        return Icons.attach_money;
      case 'DCA Calculator':
        return Icons.history;
      case 'Bitcoin Counterflow Strategy':
        return Icons.trending_up;
      case 'Charts':
        return Icons.show_chart;
      case 'Liquidation Zone':
        return Icons.waterfall_chart;
      default:
        return Icons.link;
    }
  }
}