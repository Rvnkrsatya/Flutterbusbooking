import 'dart:convert';
import 'package:flutter/material.dart';
import '../Models/vrlBusesModel.dart';
import '../Models/srsBusesModel.dart';
import '../Models/srs_seat_model.dart';
import '../Models/VRL_seat_layout_model.dart';
import '../Pages/srs_seat_layout_page.dart';
import '../Pages/vrl_seat_layout_page.dart';

import '../Service/appservice/api_urls.dart';
import '../Service/appservice/apibase.dart';
import '../Service/srs_seat_parser.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // at the top of the file


class BusListPage extends StatefulWidget {
  final String fromCity;
  final String toCity;
  final DateTime selectedDate;

  const BusListPage({
    super.key,
    required this.fromCity,
    required this.toCity,
    required this.selectedDate,
  });

  // const BusListPage({
  //   super.key,
  //   required this.fromCity,
  //   required this.toCity,
  //   required this.selectedDate,
  // });
  @override
  State<BusListPage> createState() => _BusListPageState();
}

class _BusListPageState extends State<BusListPage> {
  List<vrlBusesModel> vrlBuses = [];
  List<SrsBusModel> srsBuses = [];
  bool isLoading = true;
  String? error;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    //_logBusDetails();
    loadBusData();
  }
  void _logBusDetails() {
    debugPrint("🚌 Navigated to BusListPage");
    debugPrint("From City: ${widget.fromCity}");
    debugPrint("To City: ${widget.toCity}");
    debugPrint("Selected Date: ${widget.selectedDate.toIso8601String()}");
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
    debugPrint("🔵 VRL Request - From: ${widget.fromCity}, To: ${widget.toCity}, Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}");

    final response = await ApiBase.postRequest(
      extendedURL: ApiUrls.vrlbusdetails,
      body: {
        "sourceCity": widget.fromCity.toLowerCase().trim(),
        "destinationCity": widget.toCity.toLowerCase().trim(),
        "doj": DateFormat('yyyy-MM-dd').format(selectedDate),
      },
      withToken: true,
    );

    debugPrint("🟢 VRL Response Status: ${response.statusCode}");
    debugPrint("🟢 VRL Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      vrlBuses = data.map<vrlBusesModel>((e) => vrlBusesModel.fromJson(e)).toList();
    }
  }


  // Future<void> fetchVRLBuses() async {
  //   final response = await ApiBase.postRequest(
  //     extendedURL: ApiUrls.vrlbusdetails,
  //     body: {
  //       "sourceCity": "hubballi",
  //       "destinationCity": "bangalore",
  //       "doj": "2025-07-28"
  //     },
  //     withToken: true,
  //   );
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body)['data'];
  //     vrlBuses =
  //         data.map<vrlBusesModel>((e) => vrlBusesModel.fromJson(e)).toList();
  //   }
  // }


  Future<void> fetchSRSBuses() async {
    debugPrint("🟡 SRS Request - From: ${widget.fromCity}, To: ${widget.toCity}, Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}");

    final response = await ApiBase.getRequest(
      extendedURL: "${ApiUrls.srsbusdetails}?source=${widget.fromCity.toLowerCase().trim()}&destination=${widget.toCity.toLowerCase().trim()}&doj=${DateFormat('yyyy-MM-dd').format(selectedDate)}",
    );

    debugPrint("🟠 SRS Response Status: ${response.statusCode}");
    debugPrint("🟠 SRS Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      srsBuses = data.map<SrsBusModel>((e) => SrsBusModel.fromJson(e)).toList();
    }
  }


  // Future<void> fetchSRSBuses() async {
  //   final response =
  //       await ApiBase.getRequest(extendedURL: ApiUrls.srsbusdetails);
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     srsBuses = data.map<SrsBusModel>((e) => SrsBusModel.fromJson(e)).toList();
  //   }
  // }

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



  Future<List<SrsSeat>> getSRSSeatLayout(String tripId) async {
    final response = await ApiBase.getRequest(
      extendedURL: "${ApiUrls.getSrsSeatLayout}$tripId",
    );

    final result = jsonDecode(response.body)['result'];
    final layout = result['bus_layout'];

    final coachDetails = layout['coach_details'].toString().split(',');

    final availableList = layout['available']
        .toString()
        .split(',')
        .map((e) => e.split('|')[0].trim())
        .toSet();

    final ladiesList = layout['ladies_seats']
        .toString()
        .split(',')
        .map((e) => e.trim())
        .toSet();

    final gentsBookedSet = layout['gents_booked_seats']
        .toString()
        .split(',')
        .map((e) => e.trim())
        .toSet();

    final ladiesBookedSet = layout['ladies_booked_seats']
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
        if (!seatInfo.contains('|') || seatInfo == '.GY' || seatInfo == '--') continue;

        final seat = SrsSeat.fromLayout(
          seatInfo: seatInfo,
          availableSet: availableList,
          ladiesSet: ladiesList,
          gentsBookedSet: gentsBookedSet,
          ladiesBookedSet: ladiesBookedSet,
          row: row,
          col: col,
          seatCostMap: seatCostMap, // ✅ Pass cost map here
        );

        seats.add(seat);
      }
    }

    return seats;
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
          .where((bus) =>
              bus.nonAcSleeperRate != null &&
              bus.nonAcSleeperRate.toString().trim().isNotEmpty)
          .map((bus) => {
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
              }),
      ...srsBuses
          .where((bus) =>
              bus.fare != null &&
              bus.fare.toString().trim().isNotEmpty &&
              bus.fare.toString().toLowerCase() != 'null')
          .map((bus) => {
                'type': 'srs',
                'id': bus.id,
                'dep': bus.depTime,
                'arr': bus.arrTime,
                'seats': bus.availableSeats.toString(),
                'fare': bus.fare,
                'operator': bus.operatorServiceName,
                'busType': bus.busType.toString(),
                'rating': (random.nextDouble() + 4).clamp(4.0, 5.0),
                'ratingCount': random.nextInt(65) + 37,
              }),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF033564),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.fromCity} → ${widget.toCity}", style: const TextStyle(fontSize: 18)),

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
      body: isLoading
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
                            final date =
                                DateTime.now().add(Duration(days: index));
                            final isSelected = selectedDate.year == date.year &&
                                selectedDate.month == date.month &&
                                selectedDate.day == date.day;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDate = date;
                                });
                                final formatted =
                                    DateFormat('yyyy-MM-dd').format(date);
                                print("Selected date: $formatted");
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF14bde3)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: const Color(
                                              0xFF033564)), // Only show border for unselected
                                ),
                                child: Text(
                                  "${_getWeekday(date.weekday)}, ${_formatShortDate(date)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isSelected
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
                              bus['dep'].toString(), bus['arr'].toString());
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                  color: Color(0xFFdce6ec), width: 1),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                if (bus['type'] == 'vrl') {
                                  final layout = await getVRLSeatLayout(
                                      bus['referenceNumber'].toString());
                                  /*Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  VrlSeatLayoutPage(seats: layout)),
                        );*/
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VrlSeatLayoutPage(
                                        seats: layout,
                                        bus: vrlBuses.firstWhere((b) =>
                                            b.referenceNumber ==
                                            bus['referenceNumber']),
                                        allPrices: vrlBuses
                                            .firstWhere((b) =>
                                                b.referenceNumber ==
                                                bus['referenceNumber'])
                                            .allPrices,
                                      ),
                                    ),
                                  );
                                } else {
                                  final layout = await getSRSSeatLayout(
                                      bus['id'].toString());
                                  final parsedBus = SrsBusModel.fromJson(bus);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            SrsSeatLayoutPage(seats: layout, bus: parsedBus,)),
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
                                                  fontWeight: FontWeight.w600),
                                              children: [
                                                TextSpan(
                                                  text: 'YesGo',
                                                  style: TextStyle(
                                                      color: Color(0xFF14bde3)),
                                                ),
                                                TextSpan(
                                                  text: 'Bus',
                                                  style: TextStyle(
                                                      color: Colors.black),
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
                                                color: Colors.black87),
                                          ),
                                          Text(
                                            "${bus['busType']}",
                                            style: const TextStyle(
                                                color: Colors.black87),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          ),
                                          Text(
                                            "${bus['operator']}",
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star,
                                                color: Colors.amber, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              (bus['rating'] as double)
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "(${bus['ratingCount']})",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54),
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
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFe3f7fa),
                                            borderRadius:
                                                BorderRadius.circular(6),
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
    final now = DateTime.now();
    final weekday = _getWeekday(now.weekday);
    final day = now.day.toString().padLeft(2, '0');
    final month = _getMonthAbbr(now.month);
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
      'Dec'
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
          "Error occurred after processing. Processed DEP was: '$dep', Processed ARR was: '$arr'");
      print("Stacktrace: $stacktrace");
      return "Duration N/A";
    }
  }
}
