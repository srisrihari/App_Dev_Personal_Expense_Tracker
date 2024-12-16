import 'package:flutter/material.dart';

class ChillBillsLogo extends StatelessWidget {
  final double width;
  final double height;

  const ChillBillsLogo({
    super.key, 
    this.width = 200, 
    this.height = 200
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6A5AE0), 
            const Color(0xFFA78BFA)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ]
      ),
      child: Center(
        child: Text(
          'CB',
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.4,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
