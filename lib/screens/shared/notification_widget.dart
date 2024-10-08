import 'package:flutter/material.dart';

class NotificationWidget extends StatelessWidget {
  final String title;
  final String body;
  final Color backgroundColor;

  const NotificationWidget({
    Key? key,
    required this.title,
    required this.body,
    this.backgroundColor = Colors.orangeAccent, // Default background color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: const Icon(Icons.notifications, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          body,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
