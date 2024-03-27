import 'package:flutter/material.dart';
import '../accounts/accounts.dart';
import './components/search_modal.dart';
import './components/bottom_navigation_bar.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
          children: [
            _buildTopSection(),
            _buildActionButtons(),
             CustomBottomNavigationBar(
              currentIndex: _currentIndex,
              context: context,
              onTap: (int index) {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
          ],
        ),
        _buildAppBar(),
      ],
    );
  }

  Widget _buildTopSection() {
    return Expanded(
            child: SizedBox(
              height: MediaQuery
                  .of(context)
                  .padding
                  .top + kToolbarHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Text(
                    '0.00000000 BTC', // Replace with the actual balance
                    style: const TextStyle(fontSize: 30, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  const Text('or',
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(height: 10),
                  Text(
                    '0.00000000 USD', // Replace with the actual riverpod
                    style: const TextStyle(fontSize: 13, color: Colors.black),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Accounts(),
                        ),
                      );
                    },
                    style: _buildElevatedButtonStyle(),
                    child: const Text('View Accounts'),
                  ),
                ],
              ),
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
        return SizedBox(
          height: MediaQuery
              .of(context)
              .padding
              .top + kToolbarHeight + 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularButton(Icons.add, 'Add Money', () {
                Navigator.pushNamed(context, '/charge');
              }, Colors.white),
              _buildCircularButton(Icons.swap_horizontal_circle, 'Exchange',
                      () {
                    Navigator.pushNamed(context, '/exchange');
                  }, Colors.white),
              _buildCircularButton(Icons.payments, 'Pay', () {
                Navigator.pushNamed(context, '/pay');
              }, Colors.white),
              _buildCircularButton(
                  Icons.arrow_downward_sharp, 'Receive', () {
                Navigator.pushNamed(context, '/receive');
              }, Colors.white),
            ],
          ),
        );
  }

  Widget _buildCircularButton(IconData icon, String subtitle,
      VoidCallback onPressed, Color color) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Material(
            color: Colors.transparent,
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
        ),
        const SizedBox(height: 8),
        Text(subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.black)),
      ],
    );
  }

  Widget _buildAppBar() {
        return Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              title: _buildSearchTextField(context),
              leading: IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.credit_card),
                  color: Colors.black,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: null,
                ),
                IconButton(
                  icon: const Icon(Icons.account_balance),
                  color: Colors.black,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: null,
                ),
              ],
            ),
          ],
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
            readOnly: true,
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
}