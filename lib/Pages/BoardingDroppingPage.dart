import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PassengerInfoScreen.dart'; // You need to create this file

class BoardingDroppingPage extends StatefulWidget {
  final String fromLocation;
  final String toLocation;
  final List<Map<String, String>> boardingPoints;
  final List<Map<String, String>> droppingPoints;
  final String? initialBoardingId;
  final String? initialDroppingId;

  const BoardingDroppingPage({
    super.key,
    required this.fromLocation,
    required this.toLocation,
    required this.boardingPoints,
    required this.droppingPoints,
    this.initialBoardingId,
    this.initialDroppingId,
  });

  @override
  State<BoardingDroppingPage> createState() => _BoardingDroppingPageState();
}

class _BoardingDroppingPageState extends State<BoardingDroppingPage> {
  String? selectedBoardingId;
  String? selectedDroppingId;
  String fromcity = '';
  String tocity = '';

  @override
  void initState() {
    super.initState();
    selectedBoardingId = widget.initialBoardingId;
    selectedDroppingId = widget.initialDroppingId;
    loadSharedData();
  }

  Future<Map<String, String>> saveBoardingDroppingInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final boardingPoint = widget.boardingPoints.firstWhere(
          (point) => point['id'] == selectedBoardingId,
      orElse: () => {
        'id': '',
        'location': '',
        'time': '',
        'contact': '',
      },
    );

    final droppingPoint = widget.droppingPoints.firstWhere(
          (point) => point['id'] == selectedDroppingId,
      orElse: () => {
        'id': '',
        'location': '',
        'time': '',
        'contact': '',
      },
    );

    await prefs.setString('boardingId', boardingPoint['id'] ?? '');
    await prefs.setString('boardingLocation', boardingPoint['location'] ?? '');
    await prefs.setString('boardingTime', boardingPoint['time'] ?? '');
    await prefs.setString('boardingContact', boardingPoint['contact'] ?? '');


    await prefs.setString('droppingId', droppingPoint['id'] ?? '');
    await prefs.setString('droppingLocation', droppingPoint['location'] ?? '');
    await prefs.setString('droppingTime', droppingPoint['time'] ?? '');
    await prefs.setString('droppingContact', droppingPoint['contact'] ?? '');

    debugPrint("✅ Boarding/Dropping Info Saved:");
    debugPrint("Boarding: ${boardingPoint['location']} at ${boardingPoint['time']} (ID: ${boardingPoint['id']})");
    debugPrint("Dropping: ${droppingPoint['location']} at ${droppingPoint['time']} (ID: ${droppingPoint['id']})");

    return {
      'boardingPoint': boardingPoint['location'] ?? '',
      'droppingPoint': droppingPoint['location'] ?? '',
      'boardingContact': boardingPoint['contact'] ?? '',
      'droppingContact': droppingPoint['contact'] ?? '',
    };
  }

  Future<void> loadSharedData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      fromcity = prefs.getString('fromCity') ?? '';
      tocity = prefs.getString('toCity') ?? '';
    });

    debugPrint("📦 Loaded from SharedPreferences:");
    debugPrint("From: $fromcity");
    debugPrint("To: $tocity");
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFf2fbfd),
        appBar: AppBar(
          backgroundColor: const Color(0xFF033564),
          foregroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Boarding and Dropping Points",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                "${fromcity} → ${tocity}",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Boarding Point'),
              Tab(text: 'Dropping Point'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Boarding Points
            _buildSelectionList(widget.boardingPoints, true),
            // Dropping Points
            _buildSelectionList(widget.droppingPoints, false),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () async {
              if (selectedBoardingId != null && selectedDroppingId != null) {
                await saveBoardingDroppingInfo(); // ✅ Save before navigation
                final points = await saveBoardingDroppingInfo();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PassengerInfoScreen(
                      boardingId: selectedBoardingId!,
                      droppingId: selectedDroppingId!,
                      boardingpoint: points['boardingPoint'] ?? '',
                      droppingpoint: points['droppingPoint'] ?? '',
                      boardingContact: points['boardingContact'] ?? '',
                      droppingContact: points['droppingContact'] ?? '',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please select both boarding and dropping points"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("Confirm Selection"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF033564),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionList(List<Map<String, String>> points, bool isBoarding) {
    final selectedId = isBoarding ? selectedBoardingId : selectedDroppingId;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.separated(
          itemCount: points.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final point = points[index];
            final isSelected = selectedId == point['id'];

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              color: isSelected ? const Color(0xFFE0F7FA) : Colors.transparent,
              child: ListTile(
                leading: Icon(
                  isBoarding ? Icons.directions_bus : Icons.location_on,
                  color: const Color(0xFF14bde3),
                ),
                title: Text(
                  point['location'] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(point['time'] ?? ""),
                trailing: Radio<String>(
                  value: point['id'] ?? "",
                  groupValue: selectedId,
                  onChanged: (value) {
                    setState(() {
                      if (isBoarding) {
                        selectedBoardingId = value;
                      } else {
                        selectedDroppingId = value;
                      }
                    });
                  },
                  activeColor: const Color(0xFF14bde3),
                ),
                onTap: () {
                  setState(() {
                    if (isBoarding) {
                      selectedBoardingId = point['id'];
                    } else {
                      selectedDroppingId = point['id'];
                    }
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
