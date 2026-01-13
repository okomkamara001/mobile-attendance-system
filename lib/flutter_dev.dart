import 'package:flutter/material.dart';
import 'package:flutter_application/styled_body_text.dart';
import 'package:flutter_application/styled_button.dart';

class FlutterDev extends StatefulWidget {
  const FlutterDev({super.key});

  @override
  State<FlutterDev> createState() => _FlutterDevState();
}

class _FlutterDevState extends State<FlutterDev> {
  int strength = 1;
  int sugars = 1;

  void increaseStrength() {
    setState(() {
      strength = strength < 5 ? strength + 1 : 1;
    });
  }

  void increaseSugars() {
    setState(() {
      sugars = sugars < 5 ? sugars + 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            StyledBodyText("Strength"),
            for (int i = 0; i < strength; i++)
              Image.asset(
                "images/coffee_bean.png",
                width: 30,
                color: Colors.brown[100],
                colorBlendMode: BlendMode.multiply,
              ),

            Expanded(child: SizedBox()),
            StyledButton(onPressed: increaseStrength, child: const Text("+")),
          ],
        ),
        Row(
          children: [
            StyledBodyText("Sugars"),
            if (sugars == 0) const Text("No sugars....."),
            for (int i = 0; i < sugars; i++)
              Image.asset(
                "images/sugar_cube.png",
                width: 30,
                color: Colors.brown[300],
                colorBlendMode: BlendMode.multiply,
              ),
            Expanded(child: SizedBox()),
            StyledButton(onPressed: increaseSugars, child: const Text("+")),
          ],
        ),
      ],
    );
  }
}
