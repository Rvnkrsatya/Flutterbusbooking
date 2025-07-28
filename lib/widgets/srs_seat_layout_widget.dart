import 'package:flutter/material.dart';
import '../Models/srs_seat_model.dart';
import 'package:collection/collection.dart';

class SrsSeatLayoutWidget extends StatelessWidget {
  final List<SrsSeat> seats;
  final List<SrsSeat> selectedSeats;
  final String? selectedPrice;
  final Function(SrsSeat) onSeatTap;
  final Function(String?) onPriceSelected;

  const SrsSeatLayoutWidget({
    super.key,
    required this.seats,
    required this.selectedSeats,
    required this.selectedPrice,
    required this.onSeatTap,
    required this.onPriceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final upperSleepers = seats.where((s) => s.isUpper && _isSleeper(s)).toList();
    final lowerSleepers = seats.where((s) => !s.isUpper && _isSleeper(s)).toList();
    final upperSeaters = seats.where((s) => s.isUpper && !_isSleeper(s)).toList();
    final lowerSeaters = seats.where((s) => !s.isUpper && !_isSleeper(s)).toList();

    const Color darkBlue = Color(0xFF033564);
    const Color lightBlue = Color(0xFF14bde3);

    final allCosts = seats
        .map((s) => s.cost?.split('.').first)
        .where((c) => c != null && c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    allCosts.insert(0, "All");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20.0, 12.0, 12.0, 12.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Seat Layout",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: allCosts.map((price) {
              return ChoiceChip(
                label: Text(price == "All" ? "All" : "₹$price"),
                selected: (selectedPrice == null && price == "All") || selectedPrice == price,
                onSelected: (_) => onPriceSelected(price == "All" ? null : price),
                selectedColor: lightBlue,
                backgroundColor: const Color(0xFFE0F7FA),
                labelStyle: const TextStyle(
                  color: darkBlue,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: darkBlue, width: 1.2),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTier("Upper Tier", upperSleepers, upperSeaters),
                      const SizedBox(width: 12),
                      _buildTier("Lower Tier", lowerSleepers, lowerSeaters),
                    ],
                  ),
                ),
                const SizedBox(height: 400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTier(String title, List<SrsSeat> sleeperSeats, List<SrsSeat> seaterSeats) {
    final sleeperRows = _groupSeatsByRow(sleeperSeats);
    final sleeperRowCount = sleeperRows.length;
    const Color darkBlue = Color(0xFF033564);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: darkBlue, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlue),
              ),
              if (title.contains("Lower"))
                const SizedBox(width: 8),
              if (title.contains("Lower"))
                Image.asset('assets/images/seat_types/driver.png', width: 30, height: 30),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (seaterSeats.isNotEmpty) ...[
                Column(children: _buildSeaterColumn(seaterSeats, totalRows: sleeperRowCount)),
                SizedBox(width: title.contains("Lower") ? 16 : 0),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sleeperRows.entries.map((e) {
                  return _buildSleeperRow(e.value, addGapAfterFirst: true);
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleeperRow(List<SrsSeat> rowSeats, {bool addGapAfterFirst = false}) {
    final visibleSeats = rowSeats.where((seat) => getImagePath(seat).isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: visibleSeats.asMap().entries.map((entry) {
          final index = entry.key;
          final seat = entry.value;
          final imagePath = getImagePath(seat);
          final isSelected = selectedSeats.contains(seat);

          return GestureDetector(
            onTap: seat.isBooked ? null : () => onSeatTap(seat),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    children: [
                      //Image.asset(imagePath, width: 48, height: 74),
                      Container(
                        decoration: _shouldHighlight(seat)
                            ? BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33033564), // subtle dark blue
                              blurRadius: 2,
                              spreadRadius: 0.1,
                              offset: Offset(0, 1),
                            ),
                          ],
                        )
                            : null,
                        child: Image.asset(imagePath, width: 48, height: 74),
                      ),

                      const SizedBox(height: 2),
                      Text(
                        seat.isBooked ? "Sold" : "₹${seat.cost}",
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (addGapAfterFirst && index == 0)
                  const SizedBox(width: 16),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildSeaterColumn(List<SrsSeat> seaters, {required int totalRows}) {
    if (seaters.isEmpty) return [];
    const double seaterWidth = 36.0;
    const double totalContainerHeight = 42.0;
    const double textHeight = 10.0;
    final double imageHeight = totalContainerHeight - textHeight;

    return seaters.map((seat) {
      final cost = seat.cost?.split(".").first;
      final imagePath = getImagePath(seat);

      if (imagePath.isEmpty) return const SizedBox(width: 0, height: 10);


      return GestureDetector(
        onTap: seat.isBooked ? null : () => onSeatTap(seat),
        child: SizedBox(
          width: seaterWidth,
          height: totalContainerHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Image.asset(imagePath, width: seaterWidth, height: imageHeight, fit: BoxFit.contain),
              Container(
                decoration: _shouldHighlight(seat)
                    ? BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33033564), // subtle dark blue
                      blurRadius: 4,
                      spreadRadius: 0.5,
                      offset: Offset(0, 1),
                    ),
                  ],
                )
                    : null,
                child: Image.asset(imagePath, width: seaterWidth, height: imageHeight, fit: BoxFit.contain),
              ),


              SizedBox(
                height: textHeight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    seat.isBooked ? "Sold" : "₹${seat.cost}",
                    style: const TextStyle(fontSize: 9, height: 1.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Map<int, List<SrsSeat>> _groupSeatsByRow(List<SrsSeat> seats) {
    final map = <int, List<SrsSeat>>{};
    for (final seat in seats) {
      map.putIfAbsent(seat.row, () => []).add(seat);
    }
    for (final row in map.values) {
      row.sort((a, b) => a.column.compareTo(b.column));
    }
    return map;
  }

  bool _isSleeper(SrsSeat seat) {
    final type = seat.seatType.toUpperCase();
    return ['SUB', 'SLB', 'LB', 'UB'].contains(type);
  }

  String getImagePath(SrsSeat seat) {
    final type = seat.seatType.toUpperCase();
    if (type == '.GY' || type == '--') return '';

    final isSleeper = _isSleeper(seat);
    final isLadies = seat.isLadiesOnly;
    final isSelected = selectedSeats.contains(seat);

    if (isSelected) {
      return isSleeper
          ? 'assets/images/seat_types/sleeper_selected.png'
          : 'assets/images/seat_types/seater_selected.png';
    }
    if (seat.isBooked) {
      if (seat.isLadiesBooked) {
        return isSleeper
            ? 'assets/images/seat_types/sleeper_booked_ladies.png'
            : 'assets/images/seat_types/seater_booked_ladies1.png';
      } else {
        return isSleeper
            ? 'assets/images/seat_types/sleeper_booked_men.png'
            : 'assets/images/seat_types/seater_booked_men1.png';
      }
    }
    if (seat.isAvailable) {
      if (isLadies) {
        return isSleeper
            ? 'assets/images/seat_types/sleeper_available_ladies.png'
            : 'assets/images/seat_types/seater_available_ladies.png';
      } else {
        return isSleeper
            ? 'assets/images/seat_types/sleeper_available.png'
            : 'assets/images/seat_types/seater_available.png';
      }
    }
    return '';
  }

  bool _shouldHighlight(SrsSeat seat) {
    if (selectedPrice == "All") return false;

    final seatPrice = seat.cost?.split(".").first;
    return seatPrice == selectedPrice;
  }


}
