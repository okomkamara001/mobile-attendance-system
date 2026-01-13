import 'package:flutter/material.dart';
import 'package:flutter_application/flutter_dev.dart';
import 'package:flutter_application/styled_body_text.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hello flutter developer",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.brown[700],
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.green[200],
            padding: const EdgeInsets.all(20),
            child: StyledBodyText("I am a Flutter Developer"),
          ),
          Container(
            color: Colors.blue[400],
            padding: const EdgeInsets.all(20),
            child: const FlutterDev(),
          ),
          Expanded(
            child: Image.asset(
              "images/coffee_bg.jpg",
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    );
  }
}
