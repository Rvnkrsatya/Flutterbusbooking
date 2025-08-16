import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/vrlBusesModel.dart';
import '../Models/srsBusesModel.dart';
import '../Models/srs_seat_model.dart';
import '../Models/VRL_seat_layout_model.dart';
import '../Pages/srs_seat_layout_page.dart';
import '../Pages/vrl_seat_layout_page.dart';

import '../Service/appservice/api_urls.dart';
import '../Service/appservice/apibase.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // at the top of the file

class BusListPage extends StatefulWidget {
  const BusListPage({super.key});

  @override
  State<BusListPage> createState() => _BusListPageState();
}

class _BusListPageState extends State<BusListPage> {
  List<vrlBusesModel> vrlBuses = [];
  List<SrsBusModel> srsBuses = [];
  bool isLoading = true;
  String? error;
  String? _fromCity;
  String? _toCity;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fromCity = prefs.getString("fromCity") ?? "";
      _toCity = prefs.getString("toCity") ?? "";
      _selectedDate = prefs.getString("selectedDate") ?? "";
      print('🚌 From: $_fromCity');
      print('🚌 To: $_toCity');
      print('📅 Date: $_selectedDate');
      loadBusData();
    });
  }

  Future<void> loadBusData() async {
    try {
      await Future.wait([fetchVRLBuses(), fetchSRSBuses()]);
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchVRLBuses() async {
    debugPrint(
      "🔵 VRL Request - From: $_fromCity, To: $_toCity, Date: $_selectedDate",
    );
    DateTime? journeyDate;
    try {
      journeyDate = DateTime.parse(_selectedDate ?? "");
    } catch (e) {
      debugPrint("❌ Invalid date format: $_selectedDate");
      return;
    }

    final response = await ApiBase.postRequest(
      extendedURL: ApiUrls.vrlbusdetails,
      body: {
        "sourceCity": _fromCity?.toLowerCase().trim(),
        "destinationCity": _toCity?.toLowerCase().trim(),
        "doj": DateFormat('yyyy-MM-dd').format(journeyDate),
      },
      withToken: true,
    );

    debugPrint("🟢 VRL Response Status: ${response.statusCode}");
    debugPrint("🟢 VRL Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      vrlBuses =
          data.map<vrlBusesModel>((e) => vrlBusesModel.fromJson(e)).toList();
    }
  }

  Future<void> fetchSRSBuses() async {
    DateTime? journeyDate;
    try {
      journeyDate = DateTime.parse(_selectedDate ?? "");
    } catch (e) {
      debugPrint("❌ Invalid date format: $_selectedDate");
      return;
    }
    final url =
        "${ApiUrls.srsbusdetails}/${_fromCity?.toLowerCase().trim()}/${_toCity?.toLowerCase().trim()}/${DateFormat('yyyy-MM-dd').format(journeyDate)}";

    debugPrint("🟡 SRS Request - $url");

    final response = await ApiBase.getRequest(extendedURL: url, withToken: false);

    debugPrint("🟠 SRS Response Status: ${response.statusCode}");
    debugPrint("🟠 SRS Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      srsBuses = data.map<SrsBusModel>((e) => SrsBusModel.fromJson(e)).toList();
    }
  }

  Future<List<SeatLayout>> getVRLSeatLayout(String referenceNumber) async {
    final response = await ApiBase.postRequest(
      extendedURL: ApiUrls.getVrlSeatLayout,
      body: {"referenceNumber": referenceNumber},
      withToken: true,
    );
    final data = jsonDecode(response.body);
    return (data['data']?['ITSSeatDetails'] as List)
        .map<SeatLayout>((e) => SeatLayout.fromJson(e))
        .toList();
  }

  Future<SrsSeatLayoutResponse> getSRSSeatLayout(String tripId) async {
    final response = await ApiBase.getRequest(
      extendedURL: "${ApiUrls.getSrsSeatLayout}$tripId", withToken: false,
    );

    final result = jsonDecode(response.body)['result'];
    final layout = result['bus_layout'];

    final coachDetails = layout['coach_details'].toString().split(',');

    final String boardingRaw = layout['boarding_stages'] ?? '';
    final String droppingRaw = layout['dropoff_stages'] ?? '';

    final List<StagePointseat> boardingStages = StagePointseat.parseStageList(boardingRaw);
    final List<StagePointseat> droppingStages = StagePointseat.parseStageList(droppingRaw);

    print("📥 Raw Boarding: $boardingRaw");
    print("📥 Raw Dropping: $droppingRaw");

    for (var b in boardingStages) {
      print("📍 Boarding → ${b.stage} at ${b.time}");
    }
    for (var d in droppingStages) {
      print("📍 Dropping → ${d.stage} at ${d.time}");
    }

    final availableList =
    layout['available']
        .toString()
        .split(',')
        .map((e) => e.split('|')[0].trim())
        .toSet();

    final ladiesList =
    layout['ladies_seats']
        .toString()
        .split(',')
        .map((e) => e.trim())
        .toSet();

    final gentsBookedSet =
    layout['gents_booked_seats']
        .toString()
        .split(',')
        .map((e) => e.trim())
        .toSet();

    final ladiesBookedSet =
    layout['ladies_booked_seats']
        .toString()
        .split(',')
        .map((e) => e.trim())
        .toSet();

    // Parse cost string
    final costString = result['cost']?.toString() ?? '';
    print("Parsed seatCostMap: $costString");
    final Map<String, String> seatCostMap = parseCostMap(costString);
    print("Parsed seatCostMap: $seatCostMap");
    List<SrsSeat> seats = [];

    for (int row = 0; row < coachDetails.length; row++) {
      final block = coachDetails[row].trim();
      if (block.isEmpty) continue;

      final parts = block.split('-');
      for (int col = 0; col < parts.length; col++) {
        final seatInfo = parts[col].trim();
        if (!seatInfo.contains('|') || seatInfo == '.GY' || seatInfo == '--')
          continue;

        final seat = SrsSeat.fromLayout(
          seatInfo: seatInfo,
          availableSet: availableList,
          ladiesSet: ladiesList,
          gentsBookedSet: gentsBookedSet,
          ladiesBookedSet: ladiesBookedSet,
          row: row,
          col: col,
          seatCostMap: seatCostMap, // ✅ Pass cost map here
          originId: result['origin_id']?.toString() ?? '', // 👈 Pass here
          destinationId: result['destination_id']?.toString() ?? '', // 👈 And here
        );

        seats.add(seat);
      }
    }

    return SrsSeatLayoutResponse(
      seats: seats,
      boardingStages: boardingStages,
      droppingStages: droppingStages,
      originId: result['origin_id']?.toString() ?? '',
      destinationId: result['destination_id']?.toString() ?? '',
    );
  }

  Map<String, String> parseCostMap(String costString) {
    final pairs = costString.split(',');
    return {
      for (var pair in pairs)
        if (pair.contains(':'))
          pair.split(':')[0].trim(): pair.split(':')[1].trim().split('.').first,
    };
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final allBuses = [
      ...vrlBuses
          .where(
            (bus) =>
        bus.nonAcSleeperRate != null &&
            bus.nonAcSleeperRate.toString().trim().isNotEmpty,
      )
          .map(
            (bus) => {
          'type': 'vrl',
          'referenceNumber': bus.referenceNumber,
          'dep': bus.cityTime,
          'arr': bus.arrivalTime,
          'seats': bus.emptySeats.toString(),
          'fare': bus.nonAcSleeperRate.toString(),
          'operator': 'VRL Travels',
          'busType': bus.busTypeName.toString(),
          'rating': (random.nextDouble() + 4).clamp(4.0, 5.0),
          'ratingCount': random.nextInt(65) + 37,
        },
      ),
      ...srsBuses
          .where(
            (bus) =>
        bus.fare != null &&
            bus.fare.toString().trim().isNotEmpty &&
            bus.fare.toString().toLowerCase() != 'null',
      )
          .map(
            (bus) => {
          'type': 'srs',
          'id': bus.id,
          'bus': bus,
          'dep': bus.depTime,
          'arr': bus.arrTime,
          'seats': bus.availableSeats.toString(),
          'fare': bus.fare,
          'operator': bus.operatorServiceName,
          'busType': bus.busType.toString(),
          'rating': (random.nextDouble() + 4).clamp(4.0, 5.0),
          'ratingCount': random.nextInt(65) + 37,
        },
      ),
    ];
    if (_selectedDate == null) {
      // You can show a loader or placeholder while date loads
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF033564),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // Also make back icon white
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$_fromCity → $_toCity",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white, // 👈 Make title white
                fontWeight: FontWeight.bold,
              ),
            ),
            // const Text("Hubli → Bangalore", style: TextStyle(fontSize: 18)),
            Text(
              "Total Buses: ${allBuses.length}",
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                _formattedTodayDateLong(),
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF14bde3),
                ),
              ),
            ),
          ),
        ],
      ),
      body:
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Error: $error"))
          : Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 70, maxHeight: 80),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: List.generate(7, (index) {
                  //DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(_selectedDate!);
                  DateTime parsedDate = DateFormat(
                    'yyyy-MM-dd',
                  ).parse(_selectedDate!);
                  final date = parsedDate.add(Duration(days: index));
                  final isSelected =
                      parsedDate.year == date.year &&
                          parsedDate.month == date.month &&
                          parsedDate.day == date.day;

                  return GestureDetector(
                    onTap: () async {
                      final formattedDate = DateFormat(
                        'yyyy-MM-dd',
                      ).format(date);

                      setState(() {
                        _selectedDate =
                            formattedDate; // 1️⃣ Update the local state
                      });

                      // 2️⃣ Save to SharedPreferences
                      SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                      await prefs.setString(
                        'selectedDate',
                        formattedDate,
                      );

                      // 3️⃣ Call the API to fetch updated data
                      await loadBusData();

                      // 4️⃣ Debug print
                      print("📅 Selected date: $formattedDate");
                    },

                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                        isSelected
                            ? const Color(0xFF14bde3)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border:
                        isSelected
                            ? null
                            : Border.all(
                          color: const Color(0xFF033564),
                        ),
                      ),
                      child: Text(
                        "${_getWeekday(date.weekday)}, ${_formatShortDate(date)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color:
                          isSelected
                              ? Colors.white
                              : const Color(0xFF033564),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allBuses.length,
              itemBuilder: (context, index) {
                final bus = allBuses[index];
                final duration = calculateDuration(
                  bus['dep'].toString(),
                  bus['arr'].toString(),
                );
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Color(0xFFdce6ec),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                      await prefs.setString(
                        'departureTime',
                        bus['dep'].toString(),
                      );
                      await prefs.setString(
                        'arrivalTime',
                        bus['arr'].toString(),
                      );
                      await prefs.setString('busType', bus['busType'].toString(),);
                      await prefs.setString('type', bus['type'].toString());
                      await prefs.setString(
                        'operatorName',
                        bus['operator'].toString(),
                      );


                      print("🚌 Saved to SharedPreferences:");
                      print("Departure: ${bus['dep']}");
                      print("Arrival: ${bus['arr']}");
                      print("BusType: ${bus['busType']}");
                      print("Operator: ${bus['operator']}");

                      if (bus['type'] == 'vrl') {
                        print("bustypemine $bus['type']");
                        print("Bus type: ${bus['type']}");
                        await prefs.setString('referenceNumber', bus['referenceNumber'].toString());
                        print("Reference Number: ${bus['referenceNumber']}");

                        final layout = await getVRLSeatLayout(
                          bus['referenceNumber'].toString(),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => VrlSeatLayoutPage(
                              seats: layout,
                              bus: vrlBuses.firstWhere(
                                    (b) =>
                                b.referenceNumber ==
                                    bus['referenceNumber'],
                              ),
                              allPrices:
                              vrlBuses
                                  .firstWhere(
                                    (b) =>
                                b.referenceNumber ==
                                    bus['referenceNumber'],
                              )
                                  .allPrices,
                            ),
                          ),
                        );
                      } else {
                        final SrsSeatLayoutResponse response = await getSRSSeatLayout(bus['id'].toString());
                        final parsedBus = bus['bus'] as SrsBusModel;
                        await prefs.setString('id_srs', bus['id'].toString());
                        await prefs.setString('origin_id_srs', response.originId);         // ✅ Save origin_id
                        await prefs.setString('destination_id_srs', response.destinationId); // ✅ Save destination_id

                        print("Reference Number (SRS): ${bus['id']}");
                        print("Origin ID: ${response.originId}");
                        print("Destination ID: ${response.destinationId}");

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SrsSeatLayoutPage(
                              seats: response.seats,
                              bus: parsedBus,
                              boardingStages: response.boardingStages,
                              dropoffStages: response.droppingStages,
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'YesGo',
                                        style: TextStyle(
                                          color: Color(0xFF14bde3),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Bus',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "${bus['dep']} → ${bus['arr']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Available Seats: ${bus['seats']}",
                                  style: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "${bus['busType']}",
                                  style: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                                Text(
                                  "${bus['operator']}",
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (bus['rating'] as double)
                                        .toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "(${bus['ratingCount']})",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "₹${bus['fare']}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "onwards",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFe3f7fa),
                                  borderRadius: BorderRadius.circular(
                                    6,
                                  ),
                                ),
                                child: Text(
                                  "🕒 $duration",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formattedTodayDateLong() {
    if (_selectedDate == null) return "";

    // Parse the saved string date (e.g., '2025-08-07') to DateTime
    final parsedDate = DateFormat('yyyy-MM-dd').parse(_selectedDate!);
    final weekday = _getWeekday(parsedDate.weekday);
    final day = parsedDate.day.toString().padLeft(2, '0');
    final month = _getMonthAbbr(parsedDate.month);
    return "$weekday, $day-$month";
  }

  String _formatShortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _getMonthAbbr(date.month);
    return "$day-$month";
  }

  String _getWeekday(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[(weekday - 1) % 7];
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1) % 12];
  }

  String calculateDuration(String dep, String arr) {
    try {
      dep = dep.replaceAll(RegExp(r'\s+'), ' ').trim();
      arr = arr.replaceAll(RegExp(r'\s+'), ' ').trim();
      dep = dep.replaceAll(RegExp(r'[^0-9:AMPamp\s]'), '');
      arr = arr.replaceAll(RegExp(r'[^0-9:AMPamp\s]'), '');
      dep = dep.trim();
      arr = arr.trim();
      DateTime depTime;
      DateTime arrTime;
      if (dep.toLowerCase().contains('am') ||
          dep.toLowerCase().contains('pm')) {
        List<String> depParts = dep.split(' ');
        List<String> timeParts = depParts[0].split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        String ampm = depParts[1].toLowerCase();

        if (ampm == 'pm' && hour != 12) {
          hour += 12;
        } else if (ampm == 'am' && hour == 12) {
          hour = 0;
        }
        depTime = DateTime(2000, 1, 1, hour, minute);

        List<String> arrParts = arr.split(' ');
        List<String> arrTimeParts = arrParts[0].split(':');
        int arrHour = int.parse(arrTimeParts[0]);
        int arrMinute = int.parse(arrTimeParts[1]);
        String arrAmpm = arrParts[1].toLowerCase();

        if (arrAmpm == 'pm' && arrHour != 12) {
          arrHour += 12;
        } else if (arrAmpm == 'am' && arrHour == 12) {
          arrHour = 0;
        }
        arrTime = DateTime(2000, 1, 1, arrHour, arrMinute);
      } else {
        final format24 = DateFormat.Hm();
        depTime = format24.parse(dep);
        arrTime = format24.parse(arr);
      }

      if (arrTime.isBefore(depTime)) {
        arrTime = arrTime.add(const Duration(days: 1));
      }

      final duration = arrTime.difference(depTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);

      return "${hours}h ${minutes}m";
    } catch (e, stacktrace) {
      print(
        "Error occurred after processing. Processed DEP was: '$dep', Processed ARR was: '$arr'",
      );
      print("Stacktrace: $stacktrace");
      return "Duration N/A";
    }
  }


}















// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../Models/vrlBusesModel.dart';
// import '../Models/srsBusesModel.dart';
// import '../Models/srs_seat_model.dart';
// import '../Models/VRL_seat_layout_model.dart';
// import '../Pages/srs_seat_layout_page.dart';
// import '../Pages/vrl_seat_layout_page.dart';
// import '../Service/appservice/api_urls.dart';
// import '../Service/appservice/apibase.dart';
// import '../utils/city_mapping.dart';
//
// class BusListPage extends StatefulWidget {
//   const BusListPage({super.key});
//
//   @override
//   State<BusListPage> createState() => _BusListPageState();
// }
//
// class _BusListPageState extends State<BusListPage> {
//   // Data
//   final List<vrlBusesModel> vrlBuses = [];
//   final List<SrsBusModel> srsBuses = [];
//
//   // UI
//   bool isLoading = true;
//   String? error;
//
//   // Inputs
//   String? _fromCity;
//   String? _toCity;
//   String? _selectedDate;
//
//   // Optional IDs (preferred route if present)
//   String? _sourceId;
//   String? _destinationId;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedData();
//   }
//
//   Future<void> _loadSavedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     _fromCity = prefs.getString("fromCity") ?? "";
//     _toCity = prefs.getString("toCity") ?? "";
//     _selectedDate = prefs.getString("selectedDate") ?? "";
//
//     // These keys are typical; adjust if your app stores different keys
//     _sourceId = prefs.getString("sourceId") ??
//         prefs.getString("fromId") ??
//         prefs.getString("origin_id_srs") ??
//         "";
//     _destinationId = prefs.getString("destinationId") ??
//         prefs.getString("toId") ??
//         prefs.getString("destination_id_srs") ??
//         "";
//
//     print("📌 Loaded from SharedPreferences");
//     print("   • fromCity        : $_fromCity");
//     print("   • toCity          : $_toCity");
//     print("   • selectedDate    : $_selectedDate");
//     print("   • sourceId        : $_sourceId");
//     print("   • destinationId   : $_destinationId");
//
//     await _loadWithStrategy();
//   }
//
//   Future<void> _loadWithStrategy() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//       vrlBuses.clear();
//       srsBuses.clear();
//     });
//
//     try {
//       // 1) Try by IDs (exact match preferred)
//       final triedIds = await _tryByIds();
//
//       // 2) If still empty, try v2 (city names with mapping)
//       if (vrlBuses.isEmpty && srsBuses.isEmpty) {
//         print("🔁 No results via IDs. Trying v2 APIs with mapped city names...");
//         await _tryByCityNames(version: 2);
//       }
//
//       // 3) If still empty, try v3 (city names with mapping)
//       if (vrlBuses.isEmpty && srsBuses.isEmpty) {
//         print("🔁 Still no results. Trying v3 APIs with mapped city names...");
//         await _tryByCityNames(version: 3);
//       }
//
//       if (vrlBuses.isEmpty && srsBuses.isEmpty) {
//         print("🚫 No buses found after all strategies.");
//       } else {
//         print("✅ Done. VRL: ${vrlBuses.length}, SRS: ${srsBuses.length}");
//       }
//     } catch (e, st) {
//       print("❌ Unexpected error in _loadWithStrategy: $e");
//       print(st);
//       error = e.toString();
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   // --------------------------
//   // Strategy 1: Try with IDs
//   // --------------------------
//   Future<bool> _tryByIds() async {
//     final date = _parseDateSafe(_selectedDate);
//     if (date == null) {
//       print("⚠ Invalid selectedDate. Skipping ID strategy.");
//       return false;
//     }
//
//     final srcId = (_sourceId ?? "").trim();
//     final dstId = (_destinationId ?? "").trim();
//
//     if (srcId.isEmpty || dstId.isEmpty) {
//       print("ℹ️ Missing sourceId/destinationId. Skipping ID strategy.");
//       return false;
//     }
//
//     print("🎯 Trying ID strategy:");
//     print("   • sourceId      : $srcId");
//     print("   • destinationId : $dstId");
//     print("   • date          : ${DateFormat('yyyy-MM-dd').format(date)}");
//
//     await Future.wait([
//       _fetchVRLByIds(srcId, dstId, date),
//       _fetchSRSByIds(srcId, dstId, date),
//     ]);
//
//     final any = vrlBuses.isNotEmpty || srsBuses.isNotEmpty;
//     print("   → ID strategy result: ${any ? 'FOUND' : 'NONE'}");
//     return any;
//   }
//
//   Future<void> _fetchVRLByIds(String srcId, String dstId, DateTime date) async {
//     final body = {
//       "sourceId": srcId,
//       "destinationId": dstId,
//       "doj": DateFormat('yyyy-MM-dd').format(date),
//     };
//     print("➡ VRL ById POST ${ApiUrls.vrlbusdetailsById}");
//     print("   Body: $body");
//
//     final res = await ApiBase.postRequest(
//       extendedURL: ApiUrls.vrlbusdetailsById,
//       body: body,
//       withToken: true,
//     );
//
//     print("⬅ VRL ById Status: ${res.statusCode}");
//     if (res.statusCode == 200) {
//       final data = (jsonDecode(res.body)['data'] ?? []) as List;
//       print("✅ VRL ById buses: ${data.length}");
//       vrlBuses.addAll(data.map((e) => vrlBusesModel.fromJson(e)).toList());
//     } else {
//       print("❌ VRL ById Error: ${res.body}");
//     }
//   }
//
//   Future<void> _fetchSRSByIds(String srcId, String dstId, DateTime date) async {
//     final url =
//         "${ApiUrls.srsbusdetailsById}/$srcId/$dstId/${DateFormat('yyyy-MM-dd').format(date)}";
//     print("➡ SRS ById GET $url");
//
//     final res = await ApiBase.getRequest(
//       extendedURL: url,
//       withToken: false,
//     );
//
//     print("⬅ SRS ById Status: ${res.statusCode}");
//     if (res.statusCode == 200) {
//       final data = (jsonDecode(res.body) ?? []) as List;
//       print("✅ SRS ById buses: ${data.length}");
//       srsBuses.addAll(data.map((e) => SrsBusModel.fromJson(e)).toList());
//     } else {
//       print("❌ SRS ById Error: ${res.body}");
//     }
//   }
//
//   // ------------------------------------------------
//   // Strategy 2 & 3: Try by city names + mapping
//   // version=2 -> use v2 endpoints; version=3 -> use v3
//   // ------------------------------------------------
//   Future<void> _tryByCityNames({required int version}) async {
//     final date = _parseDateSafe(_selectedDate);
//     if (date == null) {
//       print("⚠ Invalid selectedDate. Skipping version $version city-name strategy.");
//       return;
//     }
//
//     final fromVariants = getMappedCities(_fromCity);
//     final toVariants = getMappedCities(_toCity);
//
//     print("🗺 City mapping for version $version");
//     print("   • fromCity='$_fromCity' → $fromVariants");
//     print("   • toCity  ='$_toCity'   → $toVariants");
//
//     if (fromVariants.isEmpty || toVariants.isEmpty) {
//       print("⚠ No mapping variants available. Skipping version $version.");
//       return;
//     }
//
//     // Call both operators for every mapped pair
//     for (final from in fromVariants) {
//       for (final to in toVariants) {
//         print("🚍 Try v$version: $from → $to");
//         await Future.wait([
//           _fetchVRLByCity(version: version, from: from, to: to, date: date),
//           _fetchSRSByCity(version: version, from: from, to: to, date: date),
//         ]);
//       }
//     }
//   }
//
//   Future<void> _fetchVRLByCity({
//     required int version,
//     required String from,
//     required String to,
//     required DateTime date,
//   }) async {
//     final body = {
//       "sourceCity": from.toLowerCase().trim(),
//       "destinationCity": to.toLowerCase().trim(),
//       "doj": DateFormat('yyyy-MM-dd').format(date),
//     };
//     final url = version == 2 ? ApiUrls.vrlbusdetailsV2 : ApiUrls.vrlbusdetailsV3;
//
//     print("➡ VRL v$version POST $url");
//     print("   Body: $body");
//
//     final res = await ApiBase.postRequest(
//       extendedURL: url,
//       body: body,
//       withToken: true,
//     );
//
//     print("⬅ VRL v$version Status: ${res.statusCode}");
//     if (res.statusCode == 200) {
//       final data = (jsonDecode(res.body)['data'] ?? []) as List;
//       print("✅ VRL v$version buses: ${data.length}");
//       vrlBuses.addAll(data.map((e) => vrlBusesModel.fromJson(e)).toList());
//     } else {
//       print("❌ VRL v$version Error: ${res.body}");
//     }
//   }
//
//   Future<void> _fetchSRSByCity({
//     required int version,
//     required String from,
//     required String to,
//     required DateTime date,
//   }) async {
//     final urlBase =
//     version == 2 ? ApiUrls.srsbusdetailsV2 : ApiUrls.srsbusdetailsV3;
//     final url =
//         "$urlBase/${from.toLowerCase().trim()}/${to.toLowerCase().trim()}/${DateFormat('yyyy-MM-dd').format(date)}";
//
//     print("➡ SRS v$version GET $url");
//
//     final res = await ApiBase.getRequest(
//       extendedURL: url,
//       withToken: false,
//     );
//
//     print("⬅ SRS v$version Status: ${res.statusCode}");
//     if (res.statusCode == 200) {
//       final data = (jsonDecode(res.body) ?? []) as List;
//       print("✅ SRS v$version buses: ${data.length}");
//       srsBuses.addAll(data.map((e) => SrsBusModel.fromJson(e)).toList());
//     } else {
//       print("❌ SRS v$version Error: ${res.body}");
//     }
//   }
//
//   // --------------------------
//   // Seat layout (unchanged)
//   // --------------------------
//   Future<List<SeatLayout>> getVRLSeatLayout(String referenceNumber) async {
//     print("🧩 Fetching VRL seat layout for referenceNumber=$referenceNumber");
//     final res = await ApiBase.postRequest(
//       extendedURL: ApiUrls.getVrlSeatLayout,
//       body: {"referenceNumber": referenceNumber},
//       withToken: true,
//     );
//     print("⬅ VRL seat layout status: ${res.statusCode}");
//     final data = jsonDecode(res.body);
//     return (data['data']?['ITSSeatDetails'] as List)
//         .map<SeatLayout>((e) => SeatLayout.fromJson(e))
//         .toList();
//   }
//
//   Future<SrsSeatLayoutResponse> getSRSSeatLayout(String tripId) async {
//     final url = "${ApiUrls.getSrsSeatLayout}$tripId";
//     print("🧩 Fetching SRS seat layout: $url");
//
//     final response =
//     await ApiBase.getRequest(extendedURL: url, withToken: false);
//
//     print("⬅ SRS seat layout status: ${response.statusCode}");
//     final result = jsonDecode(response.body)['result'];
//     final layout = result['bus_layout'];
//
//     final boardingStages =
//     StagePointseat.parseStageList(layout['boarding_stages'] ?? '');
//     final droppingStages =
//     StagePointseat.parseStageList(layout['dropoff_stages'] ?? '');
//
//     final availableList = layout['available']
//         .toString()
//         .split(',')
//         .map((e) => e.split('|')[0].trim())
//         .toSet();
//
//     final ladiesList =
//     layout['ladies_seats'].toString().split(',').map((e) => e.trim()).toSet();
//
//     final gentsBookedSet = layout['gents_booked_seats']
//         .toString()
//         .split(',')
//         .map((e) => e.trim())
//         .toSet();
//
//     final ladiesBookedSet = layout['ladies_booked_seats']
//         .toString()
//         .split(',')
//         .map((e) => e.trim())
//         .toSet();
//
//     final seatCostMap = parseCostMap(result['cost']?.toString() ?? '');
//     final List<SrsSeat> seats = [];
//
//     final coachDetails = layout['coach_details'].toString().split(',');
//     for (int row = 0; row < coachDetails.length; row++) {
//       final block = coachDetails[row].trim();
//       if (block.isEmpty) continue;
//
//       final parts = block.split('-');
//       for (int col = 0; col < parts.length; col++) {
//         final seatInfo = parts[col].trim();
//         if (!seatInfo.contains('|') || seatInfo == '.GY' || seatInfo == '--') {
//           continue;
//         }
//
//         seats.add(SrsSeat.fromLayout(
//           seatInfo: seatInfo,
//           availableSet: availableList,
//           ladiesSet: ladiesList,
//           gentsBookedSet: gentsBookedSet,
//           ladiesBookedSet: ladiesBookedSet,
//           row: row,
//           col: col,
//           seatCostMap: seatCostMap,
//           originId: result['origin_id']?.toString() ?? '',
//           destinationId: result['destination_id']?.toString() ?? '',
//         ));
//       }
//     }
//
//     return SrsSeatLayoutResponse(
//       seats: seats,
//       boardingStages: boardingStages,
//       droppingStages: droppingStages,
//       originId: result['origin_id']?.toString() ?? '',
//       destinationId: result['destination_id']?.toString() ?? '',
//     );
//   }
//
//   Map<String, String> parseCostMap(String costString) {
//     final pairs = costString.split(',');
//     return {
//       for (var pair in pairs)
//         if (pair.contains(':'))
//           pair.split(':')[0].trim(): pair.split(':')[1].trim().split('.').first,
//     };
//   }
//
//   // --------------------------
//   // Helpers
//   // --------------------------
//   DateTime? _parseDateSafe(String? str) {
//     if (str == null || str.isEmpty) return null;
//     try {
//       return DateTime.parse(str);
//     } catch (_) {
//       try {
//         return DateFormat('dd-MM-yyyy').parse(str);
//       } catch (e) {
//         print("⚠ Date parsing failed for '$str'");
//         return null;
//       }
//     }
//   }
//
//   String _formattedTodayDateLong() {
//     if (_selectedDate == null || _selectedDate!.isEmpty) return "";
//     final parsedDate = _parseDateSafe(_selectedDate!);
//     if (parsedDate == null) return "";
//     final weekday = _getWeekday(parsedDate.weekday);
//     final day = parsedDate.day.toString().padLeft(2, '0');
//     final month = _getMonthAbbr(parsedDate.month);
//     return "$weekday, $day-$month";
//   }
//
//   String _formatShortDate(DateTime date) {
//     final day = date.day.toString().padLeft(2, '0');
//     final month = _getMonthAbbr(date.month);
//     return "$day-$month";
//   }
//
//   String _getWeekday(int weekday) {
//     const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return weekdays[(weekday - 1) % 7];
//   }
//
//   String _getMonthAbbr(int month) {
//     const months = [
//       'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',
//     ];
//     return months[(month - 1) % 12];
//   }
//
//   String calculateDuration(String dep, String arr) {
//     try {
//       dep = dep.replaceAll(RegExp(r'\s+'), ' ').trim();
//       arr = arr.replaceAll(RegExp(r'\s+'), ' ').trim();
//       dep = dep.replaceAll(RegExp(r'[^0-9:AMPamp\s]'), '');
//       arr = arr.replaceAll(RegExp(r'[^0-9:AMPamp\s]'), '');
//       DateTime depTime;
//       DateTime arrTime;
//
//       if (dep.toLowerCase().contains('am') || dep.toLowerCase().contains('pm')) {
//         List<String> dp = dep.split(' ');
//         List<String> dpt = dp[0].split(':');
//         int dh = int.parse(dpt[0]);
//         int dm = int.parse(dpt[1]);
//         String dAMPM = dp[1].toLowerCase();
//         if (dAMPM == 'pm' && dh != 12) dh += 12;
//         if (dAMPM == 'am' && dh == 12) dh = 0;
//         depTime = DateTime(2000, 1, 1, dh, dm);
//
//         List<String> ap = arr.split(' ');
//         List<String> apt = ap[0].split(':');
//         int ah = int.parse(apt[0]);
//         int am = int.parse(apt[1]);
//         String aAMPM = ap[1].toLowerCase();
//         if (aAMPM == 'pm' && ah != 12) ah += 12;
//         if (aAMPM == 'am' && ah == 12) ah = 0;
//         arrTime = DateTime(2000, 1, 1, ah, am);
//       } else {
//         final f = DateFormat.Hm();
//         depTime = f.parse(dep);
//         arrTime = f.parse(arr);
//       }
//
//       if (arrTime.isBefore(depTime)) {
//         arrTime = arrTime.add(const Duration(days: 1));
//       }
//
//       final d = arrTime.difference(depTime);
//       return "${d.inHours}h ${d.inMinutes.remainder(60)}m";
//     } catch (e) {
//       return "Duration N/A";
//     }
//   }
//
//   // --------------------------
//   // UI
//   // --------------------------
//   @override
//   Widget build(BuildContext context) {
//     final random = Random();
//     final allBuses = [
//       ...vrlBuses
//           .where((b) =>
//       b.nonAcSleeperRate != null &&
//           b.nonAcSleeperRate.toString().trim().isNotEmpty)
//           .map((bus) => {
//         'type': 'vrl',
//         'referenceNumber': bus.referenceNumber,
//         'dep': bus.cityTime,
//         'arr': bus.arrivalTime,
//         'seats': bus.emptySeats.toString(),
//         'fare': bus.nonAcSleeperRate.toString(),
//         'operator': 'VRL Travels',
//         'busType': bus.busTypeName.toString(),
//         'rating': (random.nextDouble() + 4).clamp(4.0, 5.0),
//         'ratingCount': random.nextInt(65) + 37,
//       }),
//       ...srsBuses
//           .where((b) =>
//       b.fare != null &&
//           b.fare.toString().trim().isNotEmpty &&
//           b.fare.toString().toLowerCase() != 'null')
//           .map((bus) => {
//         'type': 'srs',
//         'id': bus.id,
//         'bus': bus,
//         'dep': bus.depTime,
//         'arr': bus.arrTime,
//         'seats': bus.availableSeats.toString(),
//         'fare': bus.fare,
//         'operator': bus.operatorServiceName,
//         'busType': bus.busType.toString(),
//         'rating': (random.nextDouble() + 4).clamp(4.0, 5.0),
//         'ratingCount': random.nextInt(65) + 37,
//       }),
//     ];
//
//     if (_selectedDate == null || _selectedDate!.isEmpty) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF033564),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "$_fromCity → $_toCity",
//               style: const TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               "Total Buses: ${allBuses.length}",
//               style: const TextStyle(fontSize: 13, color: Colors.white70),
//             ),
//           ],
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Center(
//               child: Text(
//                 _formattedTodayDateLong(),
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontStyle: FontStyle.italic,
//                   color: Color(0xFF14bde3),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error != null
//           ? Center(child: Text("Error: $error"))
//           : Column(
//         children: [
//           ConstrainedBox(
//             constraints:
//             const BoxConstraints(minHeight: 70, maxHeight: 80),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Row(
//                 children: List.generate(7, (index) {
//                   final parsedDate =
//                       _parseDateSafe(_selectedDate!) ?? DateTime.now();
//                   final date =
//                   parsedDate.add(Duration(days: index));
//                   final isSelected = parsedDate.year == date.year &&
//                       parsedDate.month == date.month &&
//                       parsedDate.day == date.day;
//
//                   return GestureDetector(
//                     onTap: () async {
//                       final formattedDate =
//                       DateFormat('yyyy-MM-dd').format(date);
//
//                       setState(() => _selectedDate = formattedDate);
//
//                       final prefs =
//                       await SharedPreferences.getInstance();
//                       await prefs.setString(
//                           'selectedDate', formattedDate);
//
//                       print("📅 Selected date changed to $formattedDate");
//                       await _loadWithStrategy();
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 6, vertical: 10),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? const Color(0xFF14bde3)
//                             : Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                         border: isSelected
//                             ? null
//                             : Border.all(
//                           color: const Color(0xFF033564),
//                         ),
//                       ),
//                       child: Text(
//                         "${_getWeekday(date.weekday)}, ${_formatShortDate(date)}",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 13,
//                           color: isSelected
//                               ? Colors.white
//                               : const Color(0xFF033564),
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: allBuses.length,
//               itemBuilder: (context, index) {
//                 final bus = allBuses[index];
//                 final duration = calculateDuration(
//                   bus['dep'].toString(),
//                   bus['arr'].toString(),
//                 );
//
//                 return Card(
//                   color: Colors.white,
//                   margin: const EdgeInsets.symmetric(
//                       horizontal: 12, vertical: 8),
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     side: const BorderSide(
//                       color: Color(0xFFdce6ec),
//                       width: 1,
//                     ),
//                   ),
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(12),
//                     onTap: () async {
//                       final prefs =
//                       await SharedPreferences.getInstance();
//
//                       await prefs.setString(
//                           'departureTime', bus['dep'].toString());
//                       await prefs.setString(
//                           'arrivalTime', bus['arr'].toString());
//                       await prefs.setString(
//                           'busType', bus['busType'].toString());
//                       await prefs.setString(
//                           'type', bus['type'].toString());
//                       await prefs.setString('operatorName',
//                           bus['operator'].toString());
//
//                       print("🚌 Saved selection:");
//                       print("   • dep: ${bus['dep']}");
//                       print("   • arr: ${bus['arr']}");
//                       print("   • busType: ${bus['busType']}");
//                       print("   • operator: ${bus['operator']}");
//
//                       if (bus['type'] == 'vrl') {
//                         final ref = bus['referenceNumber'].toString();
//                         await prefs.setString(
//                             'referenceNumber', ref);
//                         print("   • VRL referenceNumber: $ref");
//
//                         final layout =
//                         await getVRLSeatLayout(ref);
//
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => VrlSeatLayoutPage(
//                               seats: layout,
//                               bus: vrlBuses.firstWhere((b) =>
//                               b.referenceNumber == ref),
//                               allPrices: vrlBuses
//                                   .firstWhere((b) =>
//                               b.referenceNumber == ref)
//                                   .allPrices,
//                             ),
//                           ),
//                         );
//                       } else {
//                         final parsedBus = bus['bus'] as SrsBusModel;
//                         final tripId = bus['id'].toString();
//                         print("   • SRS tripId: $tripId");
//
//                         final response =
//                         await getSRSSeatLayout(tripId);
//
//                         await prefs.setString('id_srs', tripId);
//                         await prefs.setString('origin_id_srs',
//                             response.originId);
//                         await prefs.setString('destination_id_srs',
//                             response.destinationId);
//
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => SrsSeatLayoutPage(
//                               seats: response.seats,
//                               bus: parsedBus,
//                               boardingStages: response.boardingStages,
//                               dropoffStages: response.droppingStages,
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment:
//                         MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 RichText(
//                                   text: const TextSpan(
//                                     style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w600),
//                                     children: [
//                                       TextSpan(
//                                         text: 'YesGo',
//                                         style: TextStyle(
//                                             color:
//                                             Color(0xFF14bde3)),
//                                       ),
//                                       TextSpan(
//                                         text: 'Bus',
//                                         style: TextStyle(
//                                             color: Colors.black),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Text(
//                                   "${bus['dep']} → ${bus['arr']}",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 15,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   "Available Seats: ${bus['seats']}",
//                                   style: const TextStyle(
//                                       color: Colors.black87),
//                                 ),
//                                 Text(
//                                   "${bus['busType']}",
//                                   style: const TextStyle(
//                                       color: Colors.black87),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                   softWrap: true,
//                                 ),
//                                 Text(
//                                   "${bus['operator']}",
//                                   style: const TextStyle(
//                                     color: Colors.black87,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Column(
//                             crossAxisAlignment:
//                             CrossAxisAlignment.end,
//                             children: [
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Icon(
//                                     Icons.star,
//                                     color: Colors.amber,
//                                     size: 16,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     (bus['rating'] as double)
//                                         .toStringAsFixed(1),
//                                     style: const TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     "(${bus['ratingCount']})",
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.black54,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 6),
//                               Text(
//                                 "₹${bus['fare']}",
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               const Text(
//                                 "onwards",
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.black54,
//                                 ),
//                               ),
//                               const SizedBox(height: 6),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFe3f7fa),
//                                   borderRadius:
//                                   BorderRadius.circular(6),
//                                 ),
//                                 child: Text(
//                                   "🕒 $duration",
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
