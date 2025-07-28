import 'package:flutter/material.dart';
import '../Models/srsBusesModel.dart';
import '../Models/srs_seat_model.dart';
import '../Widgets/srs_seat_layout_widget.dart';
import 'BoardingDroppingPage.dart';

class SrsSeatLayoutPage extends StatefulWidget {
  final List<SrsSeat> seats;
  final SrsBusModel bus;

  const SrsSeatLayoutPage({
    super.key,
    required this.seats,
    required this.bus,
  });

  @override
  State<SrsSeatLayoutPage> createState() => _SrsSeatLayoutPageState();
}

class _SrsSeatLayoutPageState extends State<SrsSeatLayoutPage> {
  List<SrsSeat> selectedSeats = [];
  String selectedPrice = "All";

  void toggleSeatSelection(SrsSeat seat) {
    setState(() {
      if (selectedSeats.contains(seat)) {
        selectedSeats.remove(seat);
        seat.isSelected = false;
      } else {
        selectedSeats.add(seat);
        seat.isSelected = true;
      }
    });
  }

  void updatePriceFilter(String? value) {
    setState(() {
      selectedPrice = value ?? "All"; // set to "All" when null
    });
  }


  @override
  Widget build(BuildContext context) {
    final bus = widget.bus;
    final boardingList = bus.boardingStages;
    final droppingList = bus.dropoffStages;
    print("🟢 Boarding Points: ${boardingList.map((e) => '${e.stage} at ${e.time}').toList()}");
    print("🟢 Dropping Points: ${droppingList.map((e) => '${e.stage} at ${e.time}').toList()}");

    return Scaffold(
      appBar: AppBar(
        title: Text(bus.operatorServiceName),
        backgroundColor: const Color(0xFF033564),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Seat Layout
          Positioned.fill(
            child: SrsSeatLayoutWidget(
              seats: widget.seats,
              selectedPrice: selectedPrice,
              selectedSeats: selectedSeats,
              onSeatTap: toggleSeatSelection,
              onPriceSelected: updatePriceFilter,
            ),
          ),

          // Bottom Draggable Sheet with Route, Boarding, Dropping
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Material(
                elevation: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.white,
                child: DefaultTabController(
                  length: 3,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
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
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  controller: scrollController,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                    child: _buildRouteTab(bus),
                                  ),
                                ),
                                _buildStageList(boardingList, scrollController, "Boarding Points"),
                                _buildStageList(droppingList, scrollController, "Dropping Points"),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Selected Seat Summary
          if (selectedSeats.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    ...selectedSeats.map((seat) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(seat.seatType,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Color(0xFF033564))),
                        Text("₹${seat.cost?.split(".").first ?? '0'}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF033564))),
                      ],
                    )),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Price",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF033564))),
                        Text(
                          "₹${selectedSeats.fold(0, (sum, s) => sum + int.tryParse(s.cost?.split(".").first ?? '0')!)}",
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF033564)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BoardingDroppingPage(
                                fromLocation: "From",
                                toLocation: "To",
                                boardingPoints: boardingList
                                    .map((e) => {
                                  'location': e.stage,
                                  'time': e.time,
                                  'id': '',
                                  'phone': '',
                                })
                                    .toList(),
                                droppingPoints: droppingList
                                    .map((e) => {
                                  'location': e.stage,
                                  'time': e.time,
                                  'id': '',
                                })
                                    .toList(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.location_on_outlined),
                        label: const Text("Select Boarding & Dropping Point"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF033564),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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

  Widget _buildRouteTab(SrsBusModel bus) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF14bde3), size: 28),
                const SizedBox(height: 4),
                const Text("Departure", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(bus.depTime),
              ],
            ),
            const Icon(Icons.directions_bus, color: Color(0xFF033564), size: 28),
            Column(
              children: [
                const Icon(Icons.flag, color: Color(0xFF14bde3), size: 28),
                const SizedBox(height: 4),
                const Text("Arrival", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(bus.arrTime),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Duration: ${bus.duration}   |   Fare from ₹${bus.fare}",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildStageList(List<StagePoint> stages, ScrollController controller, String title) {
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      itemCount: stages.length + 1, // +1 for the title
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          // Heading
          return Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF033564),
            ),
          );
        }

        final stage = stages[index - 1];
        final isLast = index == stages.length;
        final timeFormatted = _formatTime(stage.time);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF14bde3),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeFormatted,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stage.stage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }


  String _formatTime(String time24) {
    try {
      final time = TimeOfDay(
        hour: int.parse(time24.split(':')[0]),
        minute: int.parse(time24.split(':')[1]),
      );
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      final formatted = TimeOfDay.fromDateTime(dt).format(context);
      return formatted;
    } catch (e) {
      return time24; // fallback if parsing fails
    }
  }

}
