import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String fromcity = '';
  String tocity = '';
  bool _showSeatDetails = false;

  @override
  void initState() {
    super.initState();
    loadSharedData();
  }

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

  Future<void> saveSelectedSeatInfo() async {
    final prefs = await SharedPreferences.getInstance();

    // Store list of seat names as a string (comma-separated)
    final seatNames = selectedSeats.map((s) => s.seatName).toList();
    final seatNamesString = seatNames.join(',');
    final seatPrices = selectedSeats.map((s) => (s.fare.toInt() ?? 0)).toList();
    final seatPricesString = seatPrices.join(',');
    final totalPrice = selectedSeats.fold(
      0,
          (sum, s) => sum + (s.fare.toInt() ?? 0),
    );
    final seatTaxes = selectedSeats.map((s) => s.serviceTax.toInt()).toList();
    final seatTaxesString = seatTaxes.join(',');

    // await prefs.setString('seatTaxes', seatTaxesString);
    await prefs.setString('seatTaxes', jsonEncode(seatTaxes));
    await prefs.setString('selectedSeats', seatNamesString);
    await prefs.setString('seatPrices', seatPricesString);
    await prefs.setInt('seatCount', selectedSeats.length);
    await prefs.setInt('totalPrice', totalPrice);

    debugPrint("✅ Saved to SharedPreferences:");
    debugPrint("Seats: $seatNamesString");
    debugPrint("Taxes: $seatTaxesString");
    debugPrint("Prices: $seatPricesString");
    debugPrint("Count: ${selectedSeats.length}");
    debugPrint("Total Price: ₹$totalPrice");
  }

  Future<void> loadSharedData() async {
    final prefs = await SharedPreferences.getInstance();

    fromcity = prefs.getString('fromCity') ?? '';
    tocity = prefs.getString('toCity') ?? '';

    debugPrint("📦 Loaded from SharedPreferences:");
    debugPrint("From: $fromcity");
    debugPrint("To: $tocity");

    // Optionally store in state or controller
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
      return {'id': parts[0], 'location': parts[1], 'time': parts[2]};
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
    List<Map<String, String>> amenities = parseAmenities(
      widget.bus.routeAmenities,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('VRL Seat Layout'),
        backgroundColor: const Color(0xFF033564),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
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
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: selectedSeats.isNotEmpty ? 160 : 0,
                                ),
                                child: _buildRouteTab(),
                              ),
                            ),

                            /// 🚏 Boarding Points Tab
                            ListView(
                              controller: scrollController,
                              padding: EdgeInsets.fromLTRB(16, 16, 16, selectedSeats.isNotEmpty ? 160 : 16),
                              children: [
                                const Text(
                                  "Boarding Points",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...boardingList.map(
                                      (bp) => _buildTimelineTile(
                                    bp['time']!,
                                    bp['location']!,
                                    bp['phone']!,
                                  ),
                                ),
                              ],
                            ),

                            /// 🛬 Dropping Points Tab
                            ListView(
                              controller: scrollController,
                              padding: EdgeInsets.fromLTRB(16, 16, 16, selectedSeats.isNotEmpty ? 160 : 16),
                              children: [
                                const Text(
                                  "Dropping Points",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...droppingList.map(
                                      (dp) => _buildTimelineTile(
                                    dp['time']!,
                                    dp['location']!,
                                    '',
                                  ),
                                ),
                              ],
                            ),

                            /// ✅ Amenities Tab
                            ListView(
                              controller: scrollController,
                              padding: EdgeInsets.fromLTRB(16, 16, 16, selectedSeats.isNotEmpty ? 160 : 16),
                              children: [
                                const Text(
                                  "Amenities",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  children:
                                  amenities.map((amenity) {
                                    return _buildAmenityChip(
                                      amenity['title'] ?? '',
                                      amenity['desc'] ?? '',
                                    );
                                  }).toList(),
                                ),
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
              child: _buildSelectedSeatsBar(),
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
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
        return const Icon(
          Icons.local_fire_department,
          color: Color(0xFF14bde3),
          size: 20,
        );
      case 'mobile charging point':
      case 'usb port for charger':
        return const Icon(Icons.power, color: Color(0xFF14bde3), size: 20);
      case 'm-ticket supported':
        return const Icon(
          Icons.confirmation_number,
          color: Color(0xFF14bde3),
          size: 20,
        );
      case 'emergency exit':
        return const Icon(
          Icons.exit_to_app,
          color: Color(0xFF14bde3),
          size: 20,
        );
      case 'live bus tracking':
        return const Icon(
          Icons.location_on,
          color: Color(0xFF14bde3),
          size: 20,
        );
      case 'hammer':
        return const Icon(
          Icons.construction,
          color: Color(0xFF14bde3),
          size: 20,
        );
      case 'helpline number':
        return const Icon(Icons.phone, color: Color(0xFF14bde3), size: 20);
      default:
        return const Icon(
          Icons.check_circle,
          color: Color(0xFF14bde3),
          size: 20,
        );
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
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF14bde3),
                          size: 28,
                        ),
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
                            child: Icon(
                              Icons.directions_bus,
                              color: Color(0xFF033564),
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Right Column - Arrival
                    Column(
                      children: [
                        const Icon(
                          Icons.flag,
                          color: Color(0xFF14bde3),
                          size: 28,
                        ),
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



  Widget _buildSelectedSeatsBar() {
    final totalPrice =
    selectedSeats.fold(0, (sum, s) => sum + (s.fare?.toInt() ?? 0));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
          // 🔹 Collapsed header
          if (!_showSeatDetails)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${selectedSeats.length} seat(s) selected",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF033564),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "₹$totalPrice",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF033564),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFF033564)),
                      onPressed: () {
                        setState(() {
                          _showSeatDetails = true;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),

          // 🔹 Expanded section
          if (_showSeatDetails) ...[
            // Heading with ❌
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Fare Breakdown",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF033564),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF033564)),
                  onPressed: () {
                    setState(() {
                      _showSeatDetails = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Seat list
            ...selectedSeats.map((seat) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      seat.seatName,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF14bde3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "₹${seat.fare?.toInt() ?? 0}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF14bde3),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const Divider(thickness: 1, height: 16),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF033564),
                  ),
                ),
                Text(
                  "₹$totalPrice",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF033564),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ Seats selected info at bottom
            Text(
              "${selectedSeats.length} seat(s) selected",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ✅ Boarding & Dropping Button (always visible)
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                await saveSelectedSeatInfo();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BoardingDroppingPage(
                      fromLocation: fromcity,
                      toLocation: tocity,
                      boardingPoints:
                      parseBoardingPoints(widget.bus.boardingPoints),
                      droppingPoints:
                      parseDroppingPoints(widget.bus.droppingPoints),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.location_on_outlined, color: Colors.white),
              label: const Text(
                "Select Boarding & Dropping Point",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: const Color(0xFF033564),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
