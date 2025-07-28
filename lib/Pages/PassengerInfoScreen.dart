import 'package:flutter/material.dart';

class PassengerInfoScreen extends StatelessWidget {
  final String boardingId;
  final String droppingId;

  const PassengerInfoScreen({
    super.key,
    required this.boardingId,
    required this.droppingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Passenger Information"),
        backgroundColor: const Color(0xFF033564),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Enter Passenger Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: "Mobile Number",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }
}
