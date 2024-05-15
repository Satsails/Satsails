import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import './components/logo.dart';

class Start extends StatelessWidget {
  const Start({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(
                height: 30.0,
              ),
              const Expanded(
                flex: 1,
                child: Center(
                  child: Logo(),
                ),
              ),
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Satsails',
                      style: TextStyle(
                        fontSize: 40.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                        'Sail your wealth to the cloud',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      CustomButton(
                        text: 'Register Account',
                        onPressed: () {
                          Navigator.pushNamed(context, '/set_pin');
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        text: 'Recover Account',
                        onPressed: () {
                          Navigator.pushNamed(context, '/recover_wallet');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
