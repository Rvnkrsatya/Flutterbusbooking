import 'package:flutter/material.dart';

class BusCard extends StatelessWidget {
  const BusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("YESGOBUS", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                Text("₹800.00", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("9:30 PM — 05:35 AM", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Chip(label: Text("★ 4.3"), backgroundColor: Colors.greenAccent),
              ],
            ),
            const SizedBox(height: 4),

            const Text("8h 5m    •    3 Seats"),
            const SizedBox(height: 8),
            const Text("VRL Travels", style: TextStyle(fontWeight: FontWeight.w500)),
            const Text("Sleeper Coach (32)"),
            const SizedBox(height: 16),

            // Combined Legend in one Wrap row
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 8,
              children: const [
                SeatStatus(label: "Booked", color: Colors.grey),
                SeatStatus(label: "Available", color: Colors.white),
                SeatStatus(label: "Selected", color: Colors.greenAccent),
                SeatStatus(label: "Ladies (Booked)", color: Colors.pink),
              ],
            ),

            const SizedBox(height: 16),

            // Price filters in one Wrap row
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: Text("All"), selected: true),
                ChoiceChip(label: Text("₹900"), selected: false),
                ChoiceChip(label: Text("₹800"), selected: false),
                ChoiceChip(label: Text("₹1000"), selected: false),
              ],
            ),

            const SizedBox(height: 16),

            // Upper and Lower Tier side by side
            Row(
              children: const [
                Expanded(
                  child: Column(
                    children: [
                      Text("Upper Tier", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      SeatTierLayout(),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Text("Lower Tier", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      SeatTierLayout(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SeatStatus extends StatelessWidget {
  final String label;
  final Color color;

  const SeatStatus({required this.label, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class SeatTierLayout extends StatelessWidget {
  const SeatTierLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final seatColors = [
      Colors.grey,        // Booked
      Colors.white,       // Available
      Colors.greenAccent, // Selected
      Colors.pinkAccent,  // Ladies Available
      Colors.pink,        // Ladies Booked
    ];

    List<List<int>> seatMatrix = [
      [1, 0, 4],
      [2, 3, 1],
      [1, 4, 0],
      [3, 2, 1],
    ];

    return Column(
      children: seatMatrix.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((type) {
            return Container(
              margin: const EdgeInsets.all(4),
              width: 24,
              height: 34,
              decoration: BoxDecoration(
                color: seatColors[type],
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
