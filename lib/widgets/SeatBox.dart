import 'package:flutter/material.dart';

class SeatBox extends StatelessWidget {
  final String seatImage;
  final VoidCallback? onTap;

  const SeatBox({super.key, required this.seatImage, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Image.asset(seatImage, width: 38, height: 50),
      ),
    );
  }
}
