import 'package:flutter/material.dart';
import '../home/components/bottom_navigation_bar.dart';

class Apps extends StatefulWidget {
  @override
  _AppsState createState() => _AppsState();
}

class _AppsState extends State<Apps> {
  int _currentIndex = 1; // Add this line to store the current index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Grid'),
      ),
      body: AppGrid(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex, // Pass the current index to the bottom navigation bar
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: 12, // Adjust this based on the number of apps you have
      itemBuilder: (context, index) {
        return AppCard(index + 1); // You can pass the app number or any relevant data here
      },
    );
  }
}

class AppCard extends StatelessWidget {
  final int appNumber;

  AppCard(this.appNumber);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text('App $appNumber'),
        ),
      ),
    );
  }
}
