import 'package:flutter/material.dart';
import '../home/components/bottom_navigation_bar.dart';

class Apps extends StatefulWidget {
  @override
  _AppsState createState() => _AppsState();
}

class _AppsState extends State<Apps> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: AppGrid(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        context: context,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class AppGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return AppCard(
          title: getTitle(index + 1),
          subtitle: 'Coming Soon',
        );
      },
    );
  }

  String getTitle(int appNumber) {
    switch (appNumber) {
      case 1:
        return 'Remittance';
      case 2:
        return 'Pay to Bank';
      case 3:
        return 'Alby';
      case 4:
        return 'Point of Sale';
      case 5:
        return 'BitRefill';
      default:
        return '';
    }
  }
}

class AppCard extends StatelessWidget {
  final String title;
  final String subtitle;

  AppCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8.0),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      ),
    );
  }
}
