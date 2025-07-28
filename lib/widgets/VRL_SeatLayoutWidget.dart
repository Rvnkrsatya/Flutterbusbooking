import 'package:flutter/material.dart';
import '../Models/VRL_seat_layout_model.dart';

class SeatLayoutWidget extends StatelessWidget {
  final List<SeatLayout> seats;
  final List<double> allPrices;
  final int? selectedPrice;
  final Function(int?) onPriceSelected;
  final Function(SeatLayout) onSeatTap;
  final List<SeatLayout> selectedSeats;

  const SeatLayoutWidget({
    super.key,
    required this.seats,
    required this.allPrices,
    this.selectedPrice,
    required this.onPriceSelected,
    required this.onSeatTap,
    required this.selectedSeats,
  });

  @override
  Widget build(BuildContext context) {
    final lowerSeats = seats.where((s) => s.deck == 'L').toList();
    final upperSeats = seats.where((s) => s.deck == 'U').toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Seat Layout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF033564),
            ),
          ),
        ),

        _buildPriceChips(),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (upperSeats.isNotEmpty)
                buildTierLayout(upperSeats, 'Upper Tier', isUpper: true),
              const SizedBox(width: 8),
              if (lowerSeats.isNotEmpty)
                buildTierLayout(lowerSeats, 'Lower Tier', isUpper: false),
            ],
          ),
        ),

        buildSeatLegendSection(),

        const SizedBox(height: 200),
      ],
    );
  }

  Widget _buildPriceChips() {
    final List<int> prices = allPrices.map((p) => p.toInt()).toSet().toList()..sort();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildChip(
            label: 'All',
            selected: selectedPrice == null,
            onTap: () => onPriceSelected(null),
          ),
          ...prices.map((price) => _buildChip(
            label: '₹$price',
            selected: selectedPrice == price,
            onTap: () => onPriceSelected(price),
          )),
        ],
      ),
    );
  }

  Widget _buildChip({required String label, bool selected = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF14BDE3).withOpacity(0.1) : const Color(0xFFE8F9FC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFF14BDE3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF033564),
          ),
        ),
      ),
    );
  }

  Widget buildTierLayout(List<SeatLayout> tierSeats, String title, {required bool isUpper}) {
    int maxRow = tierSeats.map((s) => s.row).fold(0, (a, b) => a > b ? a : b);
    int maxCol = tierSeats.map((s) => s.column).fold(0, (a, b) => a > b ? a : b);

    List<List<SeatLayout?>> grid = List.generate(
      maxRow + 1,
          (_) => List.generate(maxCol + 1, (_) => null),
    );

    for (var seat in tierSeats) {
      if (seat.blockType == 0 || seat.blockType == 2) {
        grid[seat.row][seat.column] = seat;
      }
    }

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF033564), width: 1.0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: List.generate(grid.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(grid[i].length, (j) {
                        final seat = grid[i][j];
                        double rightPadding = 4;
                        if (isUpper && j == 1) rightPadding = 10;
                        if (!isUpper && j == 3) rightPadding = 20;
                        if (seat == null) return SizedBox(width: rightPadding);

                        final imagePath = getSeatImagePath(seat);
                        final isAvailable = seat.isAvailable;
                        final fare = seat.fare?.toStringAsFixed(0) ?? '0';

                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 48),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: isAvailable ? () => onSeatTap(seat) : null,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: (seat.fare?.toInt() == selectedPrice && isAvailable)
                                          ? [
                                        BoxShadow(
                                          color: const Color(0xFF033564).withOpacity(0.6),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        )
                                      ]
                                          : [],
                                    ),
                                    child: Image.asset(
                                      selectedSeats.any((s) => s.seatName == seat.seatName)
                                          ? getSelectedSeatImage(seat) // if selected, show selected version
                                          : getSeatImagePath(seat),        // otherwise default seat image
                                      height: 50,
                                    )

                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  isAvailable ? '₹$fare' : 'Sold',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isAvailable ? Colors.black87 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        if (!isUpper)
          Positioned(
            top: 20,
            right: 8,
            left: 110,
            child: Image.asset(
              'assets/images/seat_types/driver.png',
              height: 24,
              width: 24,
              fit: BoxFit.contain,
            ),
          ),
      ],
    );
  }

  String getSeatImagePath(SeatLayout seat) {
    final isLadies = seat.isLadies;
    final isBooked = !seat.isAvailable;
    final isSeater = seat.seatType == '0';

    if (isSeater && isBooked && isLadies)
      return 'assets/images/seat_types/seater_booked_ladies.png';
    if (isSeater && isBooked)
      return 'assets/images/seat_types/seater_booked.png';
    if (isSeater && isLadies)
      return 'assets/images/seat_types/seater_available_ladies.png';
    if (isSeater) return 'assets/images/seat_types/seater_available.png';
    if (isBooked && isLadies)
      return 'assets/images/seat_types/sleeper_booked_ladies.png';
    if (isBooked) return 'assets/images/seat_types/sleeper_booked.png';
    if (isLadies)
      return 'assets/images/seat_types/sleeper_available_ladies.png';
    return 'assets/images/seat_types/sleeper_available.png';
  }

  Widget buildSeatLegendSection() {
    final seatTypes = [
      'Available',
      'Available Ladies',
      'Available Men',
      'Booked',
      'Booked Ladies',
      'Booked Men',
      'Selected',
    ];

    final seaterImages = [
      'assets/images/seat_types/seater_available.png',
      'assets/images/seat_types/seater_available_ladies.png',
      'assets/images/seat_types/seater_available_men.png',
      'assets/images/seat_types/seater_booked.png',
      'assets/images/seat_types/seater_booked_ladies.png',
      'assets/images/seat_types/seater_booked_men.png',
      'assets/images/seat_types/seater_selected.png',
    ];

    final sleeperImages = [
      'assets/images/seat_types/sleeper_available.png',
      'assets/images/seat_types/sleeper_available_ladies.png',
      'assets/images/seat_types/sleeper_available_men.png',
      'assets/images/seat_types/sleeper_booked.png',
      'assets/images/seat_types/sleeper_booked_ladies.png',
      'assets/images/seat_types/sleeper_booked_men.png',
      'assets/images/seat_types/sleeper_selected.png',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Know Your Seat Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF033564),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFF033564), width: 1),
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2), // Seat Type
                1: FlexColumnWidth(3), // Seater
                2: FlexColumnWidth(3), // Sleeper
              },
              border: TableBorder.all(color: Color(0xFF033564), width: 1),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(color: Color(0xFFE8F9FC)),
                  children: [
                    _buildTableHeader('Seat Type'),
                    _buildTableHeader('Seater'),
                    _buildTableHeader('Sleeper'),
                  ],
                ),
                // Data rows
                for (int i = 0; i < seatTypes.length; i++)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          seatTypes[i],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF033564),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset(
                          seaterImages[i],
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset(
                          sleeperImages[i],
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF14BDE3),
          ),
        ),
      ),
    );
  }

  String getSelectedSeatImage(SeatLayout seat) {
    if (seat.blockType == 3) return "assets/walkway.png";

    if (seat.seatType == 1) {
      // Sleeper seat
      if (seat.isLadies == "Y") {
        return seat.isAvailable ? "assets/ladies_sleeper_booked.png" : "assets/ladies_sleeper_selected.png";
      } else {
        return seat.isAvailable ? "assets/sleeper_booked.png" : "assets/sleeper_selected.png";
      }
    } else {
      // Seater seat
      if (seat.isLadies == "Y") {
        return seat.isAvailable ? "assets/images/seat_types/seater_booked_ladies.png" : "assets/images/seat_types/seater_selected_ladies.png";
      } else {
        return seat.isAvailable ? "assets/images/seat_types/sleeper_selected.png" : "assets/images/seat_types/seater_selected.png";
      }
    }
  }

}
