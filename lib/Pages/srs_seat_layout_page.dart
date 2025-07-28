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

  @override
  Widget build(BuildContext context) {
    final bus = widget.bus;
    final boardingList = bus.boardingStages;
    final droppingList = bus.dropoffStages;

    return Scaffold(
      appBar: AppBar(
        title: Text(bus.operatorServiceName),
        backgroundColor: const Color(0xFF033564),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Seat Layout
          SrsSeatLayoutWidget(seats: widget.seats),

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
                                  controller: scrollController, // important 👈
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                    child: _buildRouteTab(bus),
                                  ),
                                ),
                                _buildStageList(boardingList),
                                _buildStageList(droppingList),
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
                        Text("₹${seat.row?.toInt() ?? 0}",
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
                          "₹${selectedSeats.fold(0, (sum, s) => sum + (s.row?.toInt() ?? 0))}",
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
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
                const Icon(Icons.location_on,
                    color: Color(0xFF14bde3), size: 28),
                const SizedBox(height: 4),
                const Text("Departure",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(bus.depTime),
              ],
            ),
            const Icon(Icons.directions_bus,
                color: Color(0xFF033564), size: 28),
            Column(
              children: [
                const Icon(Icons.flag, color: Color(0xFF14bde3), size: 28),
                const SizedBox(height: 4),
                const Text("Arrival",
                    style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildStageList(List<StagePoint> stages) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stages.length,
      itemBuilder: (context, index) {
        final stage = stages[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF14bde3)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stage.time,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(stage.stage,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
