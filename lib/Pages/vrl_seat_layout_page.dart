import 'package:flutter/material.dart';
import '../Models/VRL_seat_layout_model.dart';
import '../Models/vrlBusesModel.dart';
import '../Widgets/VRL_SeatLayoutWidget.dart';
import 'BoardingDroppingPage.dart';

class VrlSeatLayoutPage extends StatefulWidget {
  final List<SeatLayout> seats;
  final vrlBusesModel bus;
  final List<int> allPrices;

  const VrlSeatLayoutPage({
    super.key,
    required this.seats,
    required this.bus,
    required this.allPrices,
  });

  @override
  State<VrlSeatLayoutPage> createState() => _VrlSeatLayoutPageState();
}

class _VrlSeatLayoutPageState extends State<VrlSeatLayoutPage> {
  int? selectedPrice;
  List<SeatLayout> selectedSeats = [];

  void handleSeatTap(SeatLayout seat) {
    if (!seat.isAvailable) return;

    if (_isBesideOppositeGender(seat)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot select seat beside opposite gender"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      final exists = selectedSeats.any((s) => s.seatName == seat.seatName);
      if (exists) {
        selectedSeats.removeWhere((s) => s.seatName == seat.seatName);
      } else {
        selectedSeats.add(seat);
      }
    });
  }

// 👥 Gender restriction check
  bool _isBesideOppositeGender(SeatLayout seat) {
    for (var s in selectedSeats) {
      if (areAdjacent(s, seat)) {
        // If current is ladies, and selected is not ladies (i.e. gents)
        if ((s.isLadies && !seat.isLadies) || (!s.isLadies && seat.isLadies)) {
          return true;
        }
      }
    }
    return false;
  }

// 🪑 Define adjacency logic as per your layout (e.g. same row, next column)
  bool areAdjacent(SeatLayout a, SeatLayout b) {
    // Example logic: check if seatNo difference is 1 or in adjacent columns
    int numA = int.tryParse(RegExp(r'\d+').stringMatch(a.seatName) ?? '') ?? -1;
    int numB = int.tryParse(RegExp(r'\d+').stringMatch(b.seatName) ?? '') ?? -1;
    return (numA - numB).abs() == 1;
  }

  List<Map<String, String>> parseBoardingPoints(String raw) {
    return raw.split('#').map((point) {
      final parts = point.split('|');
      return {
        'id': parts[0],
        'location': parts[1],
        'time': parts[2],
        'phone': parts.length > 3 ? parts[3] : '',
      };
    }).toList();
  }

  List<Map<String, String>> parseDroppingPoints(String raw) {
    return raw.split('#').map((point) {
      final parts = point.split('|');
      return {
        'id': parts[0],
        'location': parts[1],
        'time': parts[2],
      };
    }).toList();
  }

  List<Map<String, String>> parseAmenities(String rawData) {
    final entries = rawData.split('#');
    return entries.map((entry) {
      final parts = entry.split('|');
      return {
        'title': parts.length > 1 ? parts[1].trim() : '',
        'desc': parts.length > 2 ? parts[2].trim() : '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final boardingList = parseBoardingPoints(widget.bus.boardingPoints);
    final droppingList = parseDroppingPoints(widget.bus.droppingPoints);
    final amenitiesList = parseAmenities(widget.bus.routeAmenities);
    final routeName = widget.bus.routeName;
    List<Map<String, String>> amenities =
        parseAmenities(widget.bus.routeAmenities);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VRL Seat Layout'),
        backgroundColor: const Color(0xFF033564),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          /// 🪑 Seat Layout with Price Selection
          /*SeatLayoutWidget(
            seats: widget.seats,
            allPrices: widget.allPrices.map((e) => e.toDouble()).toList(),
            selectedPrice: selectedPrice,
            onPriceSelected: (int? price) {
              setState(() {
                selectedPrice = price;
              });
            },
          ),*/

          SeatLayoutWidget(
            seats: widget.seats,
            allPrices: widget.allPrices.map((e) => e.toDouble()).toList(),
            selectedPrice: selectedPrice,
            selectedSeats: selectedSeats,
            onSeatTap: handleSeatTap,
            onPriceSelected: (price) {
              setState(() {
                selectedPrice = price;
              });
            },
          ),

          /// 📍 Bottom Tabs - Route, Boarding, Dropping, Amenities
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Material(
                elevation: 20,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.white,
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        height: 5,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const TabBar(
                        labelColor: Color(0xFF033564),
                        indicatorColor: Color(0xFF14bde3),
                        tabs: [
                          Tab(text: "Route"),
                          Tab(text: "Boarding"),
                          Tab(text: "Dropping"),
                          Tab(text: "Amenities"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            /// 🗺️ Route Tab
                            SingleChildScrollView(
                              controller: scrollController,
                              child: _buildRouteTab(),
                            ),

                            /// 🚏 Boarding Points Tab
                            ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              children: [
                                const Text("Boarding Points",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                ...boardingList.map((bp) => _buildTimelineTile(
                                      bp['time']!,
                                      bp['location']!,
                                      bp['phone']!,
                                    )),
                              ],
                            ),

                            /// 🛬 Dropping Points Tab
                            ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              children: [
                                const Text("Dropping Points",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                ...droppingList.map((dp) => _buildTimelineTile(
                                      dp['time']!,
                                      dp['location']!,
                                      '',
                                    )),
                              ],
                            ),

                            /// ✅ Amenities Tab
                            ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              children: [
                                const Text("Amenities",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  children: amenities.map((amenity) {
                                    return _buildAmenityChip(
                                        amenity['title'] ?? '',
                                        amenity['desc'] ?? '');
                                  }).toList(),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          if (selectedSeats.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selected Seats",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF033564),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: selectedSeats.map((seat) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${seat.seatName}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF033564),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "₹${seat.fare?.toInt() ?? 0}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF033564),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const Divider(thickness: 1, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Price",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF033564),
                              ),
                            ),
                            Text(
                              "₹${selectedSeats.fold(0, (sum, s) => sum + (s.fare?.toInt() ?? 0))}",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF033564),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BoardingDroppingPage(
                                fromLocation: 'Bangalore',
                                toLocation: 'Mumbai',
                                boardingPoints: boardingList,
                                droppingPoints: droppingList,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.location_on_outlined,
                            color: Colors.white),
                        label: const Text(
                          "Select Boarding & Dropping Point",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          backgroundColor: const Color(0xFF033564), // dark navy
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          shadowColor:
                              const Color(0x6614bde3), // subtle glow effect
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 🧭 Timeline entry for Boarding/Dropping
  Widget _buildTimelineTile(String time, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.circle, size: 10, color: Color(0xFF14bde3)),
            Container(width: 2, height: 40, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              if (subtitle.isNotEmpty)
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 16),
            ],
          ),
        )
      ],
    );
  }

  /// ✅ Amenities Chip
  Widget _buildAmenityChip(String title, String desc) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6), // vertical spacing only
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getAmenityIcon(title),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(
                color: Color(0xFF000000),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getAmenityIcon(String title) {
    switch (title.toLowerCase()) {
      case 'reading light':
        return const Icon(Icons.lightbulb, color: Color(0xFF14bde3), size: 20);
      case 'fire extinguisher':
        return const Icon(Icons.local_fire_department,
            color: Color(0xFF14bde3), size: 20);
      case 'mobile charging point':
      case 'usb port for charger':
        return const Icon(Icons.power, color: Color(0xFF14bde3), size: 20);
      case 'm-ticket supported':
        return const Icon(Icons.confirmation_number,
            color: Color(0xFF14bde3), size: 20);
      case 'emergency exit':
        return const Icon(Icons.exit_to_app,
            color: Color(0xFF14bde3), size: 20);
      case 'live bus tracking':
        return const Icon(Icons.location_on,
            color: Color(0xFF14bde3), size: 20);
      case 'hammer':
        return const Icon(Icons.construction,
            color: Color(0xFF14bde3), size: 20);
      case 'helpline number':
        return const Icon(Icons.phone, color: Color(0xFF14bde3), size: 20);
      default:
        return const Icon(Icons.check_circle,
            color: Color(0xFF14bde3), size: 20);
    }
  }

  Widget _buildRouteTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Departure
                    Column(
                      children: [
                        const Icon(Icons.location_on,
                            color: Color(0xFF14bde3), size: 28),
                        const SizedBox(height: 4),
                        Text(
                          widget.bus.fromCityName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.bus.cityTime,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    // Route line with bus icon
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 2,
                            color: Colors.grey.shade400,
                            margin: const EdgeInsets.only(top: 48),
                          ),
                          const Positioned(
                            child: Icon(Icons.directions_bus,
                                color: Color(0xFF033564), size: 28),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Right Column - Arrival
                    Column(
                      children: [
                        const Icon(Icons.flag,
                            color: Color(0xFF14bde3), size: 28),
                        const SizedBox(height: 4),
                        Text(
                          widget.bus.toCityName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.bus.arrivalTime,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Distance & Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.route, color: Colors.orange, size: 20),
                        const SizedBox(width: 6),
                        Text("${widget.bus.kilometer} km"),
                      ],
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
}
