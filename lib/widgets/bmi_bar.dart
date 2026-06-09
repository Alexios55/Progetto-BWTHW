import 'package:flutter/material.dart';

class BmiBar extends StatelessWidget {
  final double bmi;
  final Color statusColor;

  const BmiBar({
    super.key,
    required this.bmi,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    double maxBmi = 40;

    double position = (bmi / maxBmi).clamp(0.0, 1.0);

    return Column(
      children: [
        const SizedBox(height: 20),

        // barra colorata
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.red,
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              // "Underweight" occupa 18.5/40 = ~46% della larghezza
              Expanded(flex: 185, child: Text('Under-\nweight', style: TextStyle(fontSize: 9, color: Colors.blue), textAlign: TextAlign.center)),
              Expanded(flex: 65, child: Text('Normal', style: TextStyle(fontSize: 9, color: Colors.green), textAlign: TextAlign.center)),
              Expanded(flex: 50, child: Text('Over-\nweight', style: TextStyle(fontSize: 9, color: Colors.orange), textAlign: TextAlign.center)),
              Expanded(flex: 100, child: Text('Obese', style: TextStyle(fontSize: 9, color: Colors.red), textAlign: TextAlign.center)),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // indicatore animato
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: position),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Align(
              alignment: Alignment(-1 + (value * 2), 0),
              child: Column(
                children: [
                  Text(
                    bmi.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // scala
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('0'),
            Text('18.5'),
            Text('25'),
            Text('30'),
            Text('40'),
          ],
        ),
      ],
    );
  }
}
