import 'package:flutter/material.dart';
import 'package:animate_gradient/animate_gradient.dart';
import './components/balance.dart';
import '../accounts/accounts.dart';
import './components/search_modal.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  void initState() {
    super.initState();
    Provider.of<SettingsProvider>(context, listen: false).loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        AnimateGradient(
          primaryColors: const [
            Color(0xFF001F3F),
            Color(0xFF001F3F),
            Color(0xFF001F3F),
          ],
          secondaryColors: const [
            Color(0xFFFF6F61),
            Color(0xFF001F3F),
            Color(0xFF001F3F),
          ],
          duration: const Duration(seconds: 15),
          reverse: true,
          child: Column(
            children: [
              _buildTopSection(),
              _buildActionButtons(),
              _buildBottomNavigationBar(),
            ],
          ),
        ),
        _buildAppBar(),
      ],
    );
  }

  Widget _buildTopSection() {
    return Expanded(
      child: FutureBuilder<Map<String, double>>(
        future: BalanceWrapper().calculateTotalValue(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            double usdBalance = snapshot.data!["usd"]!;
            double btcBalance = snapshot.data!["totalValueInBTC"]!;

            return SizedBox(
              height: MediaQuery
                  .of(context)
                  .padding
                  .top + kToolbarHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Text(
                    '${btcBalance.toStringAsFixed(8)} BTC',
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text('or',
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                    '${usdBalance.toStringAsFixed(2)} USD',
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Accounts(balances: snapshot.data!),
                        ),
                      );
                    },
                    style: _buildElevatedButtonStyle(),
                    child: const Text('View Accounts'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  ButtonStyle _buildElevatedButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        Colors.white,
      ),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      elevation: MaterialStateProperty.all<double>(0.0),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return SizedBox(
          height: MediaQuery.of(context).padding.top + kToolbarHeight + 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularButton(Icons.add, 'Add Money', () {}, Colors.grey),
              _buildCircularButton(Icons.swap_horizontal_circle, 'Exchange', () {}, Colors.white),
              _buildCircularButton(Icons.payment, 'Pay', () {}, Colors.white),
              _buildCircularButton(Icons.arrow_downward_sharp, 'Receive', () {}, Colors.white),
              _buildCircularButton(Icons.checklist, 'Transactions', () {}, Colors.white),
            ],
          ),
        );
      },
    );
  }


  Widget _buildCircularButton(IconData icon, String subtitle, VoidCallback onPressed, Color color) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color],
              ),
              border: Border.all(color: Colors.black.withOpacity(0.7)),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 25,
              child: Icon(
                icon,
                color: Colors.black.withOpacity(0.7),
                size: 25,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.white)),
      ],
    );
  }

  Widget _buildAppBar() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              title: _buildSearchTextField(context),
              leading: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.credit_card),
                  color: settingsProvider.proMode ? Colors.white : Colors.grey,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: settingsProvider.proMode ? null : () {},
                ),
                IconButton(
                  icon: const Icon(Icons.account_balance),
                  color: settingsProvider.proMode ? Colors.white : Colors.grey,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: settingsProvider.proMode ? null : () {},
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchTextField(BuildContext context) {
    return SizedBox(
      height: 50,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SearchModal();
            },
          );
        },
        child: AbsorbPointer(
          child: TextField(
            readOnly: true, // Prevents the keyboard from appearing
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              filled: true,
              hintStyle: TextStyle(color: Colors.grey[800]),
              hintText: "Search",
              fillColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        List<BottomNavigationBarItem> bottomNavBarItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
        ];

          bottomNavBarItems.insert(
            1,
            const BottomNavigationBarItem(
              icon: Icon(Icons.apps, color: Colors.white),
              label: 'Apps',
            ),
          );

        return Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedFontSize: 12,
            unselectedFontSize: 12,
            iconSize: 24,
            unselectedItemColor: Colors.white,
            selectedItemColor: Colors.orangeAccent,
            elevation: 0.0,
            items: bottomNavBarItems,
          ),
        );
      },
    );
  }
}
