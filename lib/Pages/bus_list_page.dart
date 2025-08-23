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
import 'dart:math';

import '../utils/city_mapping.dart'; // at the top of the file

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
  String? _srsSourceCityId;
  String? _srsDestinationCityId;
  String? _vrlSourceCityId;
  String? _vrlDestinationCityId;
  String? originId;
  String? destinationId;
  String? vrlsourcecityname;
  String? vrldestinationcityname;
  List<String> boardingPointsList = [];
  List<String> droppingPointsList = [];
  List<String> busOperatorsList = [];

  Set<String> selectedBoardingPoints = {};
  Set<String> selectedDroppingPoints = {};
  Set<String> selectedOperators = {};
  Set<String> selectedBusTypes = {};
  RangeValues selectedPriceRange = const RangeValues(0, 4000);

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
      _srsSourceCityId = prefs.getString("srsSourceCityId") ?? "";
      _srsDestinationCityId = prefs.getString("srsDestinationCityId") ?? "";
      _vrlSourceCityId = prefs.getString("vrlSourceCityId") ?? "";
      _vrlDestinationCityId = prefs.getString("vrlDestinationCityId") ?? "";
      originId = prefs.getString("srsSourceCityName"); // origin_id
      destinationId = prefs.getString("srsDestinationCityName");
      print('🚌 _srsSourceCityId: $_srsSourceCityId');
      print('🚌 _srsDestinationCityId: $_srsDestinationCityId');
      print('📅 _vrlSourceCityId: $_vrlSourceCityId');
      print('📅 _vrlDestinationCityId: $_vrlDestinationCityId');
      print('📅 srsSourceCityName: $originId');
      print('📅 srsDestinationCityName: $destinationId');

      print('🚌 From: $_fromCity');
      print('🚌 To: $_toCity');
      print('📅 Date: $_selectedDate');
      loadBusData();
    });
  }

  Future<void> loadBusData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 🚌 VRL IDs
      final vrlSourceId = prefs.getString("vrlSourceCityId");
      final vrlDestId = prefs.getString("vrlDestinationCityId");

      // 🚌 SRS IDs
      final srsSourceId = prefs.getString("srsSourceCityId");
      final srsDestId = prefs.getString("srsDestinationCityId");
      final destinationId = prefs.getString("srsSourceCityName");
      final srsDestName = prefs.getString("srsDestinationCityName");

      final travelDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.parse(_selectedDate!));

      // Case 1: Both have IDs → V3
      if (vrlSourceId != null &&
          vrlDestId != null &&
          srsSourceId != null &&
          srsDestId != null) {
        debugPrint("🟢 Both IDs found → Using V3 APIs for VRL + SRS");

        await Future.wait([
          fetchVRLBusesv3(),
          fetchSRSBusesv3(),
          fetchSrsFiltersv3(),
        ]);
      }
      else if (srsSourceId != null && srsDestId != null) {
        debugPrint("🟠 Only SRS IDs found → SRS v3 + VRL v2 (city mapping)");

         final sourceCity = normalizeCity(_fromCity ?? "");
        final destinationCity   = normalizeCity(_toCity ?? "");

        await Future.wait([
          fetchVRLBusesv2(),
          fetchSRSBusesv3(),
          fetchSrsFiltersv3(),
        ]);
      }
      // Case 3: Only VRL IDs exist
      else if (vrlSourceId != null && vrlDestId != null) {
        debugPrint("🟠 Only VRL IDs found → VRL v3 + SRS v2 (city mapping)");

        final sourceCity = normalizeCity(_fromCity ?? "");
        final destinationCity   = normalizeCity(_toCity ?? "");

        await Future.wait([
          fetchVRLBusesv3(),
          fetchSRSBusesv2(),
           // fetchSrsFilters(),
        ]);
      }
      // Case 4: No IDs → fallback to V2 + mapping
      else {
        debugPrint("🟡 No IDs found → Using V2 APIs with city mapping");

        final sourceCity = normalizeCity(_fromCity ?? "");
        final destinationCity   = normalizeCity(_toCity ?? "");

        await Future.wait([
          fetchVRLBusesv2(),
          fetchSRSBusesv2(),
           // fetchSrsFilters(),
        ]);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchVRLBusesv2() async {
    debugPrint("🔵 VRL v2 Request: $_fromCity → $_toCity ($_selectedDate)");

    DateTime? journeyDate;
    try {
      journeyDate = DateTime.parse(_selectedDate ?? "");
    } catch (e) {
      debugPrint("❌ Invalid date: $_selectedDate");
      return;
    }

    final doj = DateFormat('yyyy-MM-dd').format(journeyDate);

    // Step 1: expand synonyms
    final sourceSynonyms =
        cityMapping[_fromCity?.toLowerCase().trim() ?? ""] ?? [_fromCity ?? ""];
    final destSynonyms =
        cityMapping[_toCity?.toLowerCase().trim() ?? ""] ?? [_toCity ?? ""];

    debugPrint("🔍 Trying source variations: $sourceSynonyms");
    debugPrint("🔍 Trying destination variations: $destSynonyms");

    bool success = false;

    // Step 2: try all combinations
    for (final src in sourceSynonyms) {
      for (final dst in destSynonyms) {
        final body = {
          "sourceCity": src,
          "destinationCity": dst,
          "doj": doj,
          "fromLocation": _fromCity,
          "toLocation": _toCity,
        };

        debugPrint("📤 Trying VRL v2 body: $body");

        try {
          final response = await ApiBase.postRequest(
            extendedURL: ApiUrls.vrlbusdetailsV2,
            body: body,
            withToken: true,
          );

          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            if (decoded['data'] != null &&
                (decoded['data'] as List).isNotEmpty) {
              setState(() {
                vrlBuses =
                    (decoded['data'] as List)
                        .map((e) => vrlBusesModel.fromJson(e))
                        .toList();
              });
              debugPrint("✅ Found buses with $src → $dst : ${vrlBuses.length}");
              success = true;
              break; // stop inner loop
            }
          } else {
            debugPrint("⚠️ Failed with $src → $dst : ${response.body}");
          }
        } catch (e) {
          debugPrint("❌ Exception for $src → $dst : $e");
        }
      }
      if (success) break; // stop outer loop
    }

    if (!success) {
      debugPrint("🚫 No buses found for any synonym combination");
    }
  }

  Future<void> fetchVRLBusesv3() async {
    debugPrint("🔵 VRL v3 Request: $_fromCity → $_toCity ($_selectedDate)");

    DateTime? journeyDate;
    try {
      journeyDate = DateTime.parse(_selectedDate ?? "");
    } catch (e) {
      debugPrint("❌ Invalid date: $_selectedDate");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final vrlSourceId = prefs.getString("vrlSourceCityId") ?? "";
    final vrlDestId = prefs.getString("vrlDestinationCityId") ?? "";

    try {
      final response = await ApiBase.postRequest(
        extendedURL: ApiUrls.vrlbusdetailsv3,
        body: {
          "sourceCity": _fromCity?.toLowerCase().trim(),
          "destinationCity": _toCity?.toLowerCase().trim(),
          "doj": DateFormat('yyyy-MM-dd').format(journeyDate),
          "vrlSourceCityId": vrlSourceId,
          "vrlDestinationCityId": vrlDestId,
        },
        withToken: true,
      );

      debugPrint("🟢 VRL v3 Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['data'] != null) {
          final List<dynamic> data = decoded['data'];
          setState(() {
            vrlBuses =
                data
                    .map<vrlBusesModel>((e) => vrlBusesModel.fromJson(e))
                    .toList();
          });
          debugPrint("✅ VRL v3 buses: ${vrlBuses.length}");
          return; // success
        }
      }

      // ❌ fallback
      debugPrint("⚠️ VRL v3 failed → trying v2...");
      await fetchVRLBusesv2();
    } catch (e) {
      debugPrint("❌ VRL v3 exception: $e");
      debugPrint("⚠️ fallback to v2...");
      await fetchVRLBusesv2();
    }
  }

  Future<bool> fetchSRSBusesv3() async {
    final prefs = await SharedPreferences.getInstance();

    final originId = prefs.getString("srsSourceCityName");
    final destinationId = prefs.getString("srsDestinationCityName");
    final fromLocation = prefs.getString("srsSourceCityId");
    final toLocation = prefs.getString("srsDestinationCityId");
    final travelDate = prefs.getString("selectedDate");

    if (originId == null ||
        destinationId == null ||
        fromLocation == null ||
        toLocation == null ||
        travelDate == null) {
      debugPrint("⚠️ Missing params in SharedPreferences for SRS v3");
      debugPrint("➡️ Falling back to SRS v2 due to missing params");
      await fetchSRSBusesv2();
      return false;
    }

    final url =
        "${ApiUrls.srsbusdetailsv3}/$originId/$destinationId/$travelDate/$fromLocation/$toLocation";

    debugPrint("🟡 Calling SRS v3 API → $url");

    try {
      final response = await ApiBase.getRequest(
        extendedURL: url,
        withToken: false,
      );

      debugPrint("🟠 SRS v3 Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            srsBuses =
                data.map<SrsBusModel>((e) => SrsBusModel.fromJson(e)).toList();
          });
          debugPrint("✅ SRS v3 buses loaded: ${srsBuses.length}");
          return true;
        } else {
          debugPrint("⚠️ SRS v3 returned empty → fallback to v2");
          await Future.wait([fetchSRSBusesv2(), fetchSrsFiltersV2()]);
        }
      } else {
        debugPrint("⚠️ SRS v3 failed → fallback to v2");
        await fetchSRSBusesv2();
      }
    } catch (e) {
      debugPrint("❌ SRS v3 exception: $e → fallback to v2");
      await fetchSRSBusesv2();
    }

    return false;
  }

  Future<void> fetchSrsFiltersV2() async {
    final prefs = await SharedPreferences.getInstance();

    // Load required params from SharedPreferences
    final sourceCity = prefs.getString("vrlSourceCityName"); // mapped city
    final destinationCity = prefs.getString(
      "vrlDestinationCityName",
    ); // mapped city
    final fromLocation = prefs.getString("srsSourceCityName"); // user input
    final toLocation = prefs.getString("srsDestinationCityName"); // user input
    final doj = prefs.getString("selectedDate"); // yyyy-MM-dd

    if (sourceCity == null ||
        destinationCity == null ||
        fromLocation == null ||
        toLocation == null ||
        doj == null) {
      debugPrint("⚠️ Missing params for SRS Filters V2");
      return;
    }

    // Construct URL
    final url =
        "${ApiUrls.srsFiltersV2}?sourceCity=$sourceCity&destinationCity=$destinationCity&doj=$doj&fromLocation=$fromLocation&toLocation=$toLocation";

    debugPrint("🟡 Calling SRS Filters V2 API → $url");

    try {
      final response = await ApiBase.getRequest(
        extendedURL: url,
        withToken: false, // adjust if your API needs token
      );

      debugPrint("🟠 Status: ${response.statusCode}");
      debugPrint("🟠 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("✅ Parsed Filters: $data");
        // TODO: store data in state or return it
      } else {
        debugPrint("❌ Failed to fetch filters. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching SRS Filters V2: $e");
    }
  }

  Future<bool> fetchSRSBusesv2() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final fromLocation = _fromCity ?? "";
      final toLocation = _toCity ?? "";

      // Normalize cities for API
      String originId = normalizeCity(fromLocation);
      String destinationId = normalizeCity(toLocation);

      final travelDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.parse(_selectedDate!));

      final url =
          "${ApiUrls.srsSchedulesV2}/$originId/$destinationId/$travelDate/$fromLocation/$toLocation";

      debugPrint("🟡 Calling SRS v2 API → $url");

      final response = await ApiBase.getRequest(
        extendedURL: url,
        withToken: false,
      );

      debugPrint("🟠 SRS v2 raw status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> busesJson = [];

        if (decoded is List) {
          // ✅ Direct list response
          busesJson = decoded;
        } else if (decoded is Map && decoded["data"] != null) {
          // ✅ Wrapped response with { status, data }
          busesJson = decoded["data"];
        }

        if (busesJson.isNotEmpty) {
          setState(() {
            srsBuses =
                busesJson.map((json) => SrsBusModel.fromJson(json)).toList();
          });
          debugPrint(
            "✅ Found buses with $originId → $destinationId : ${srsBuses.length}",
          );
          return true;
        } else {
          debugPrint("⚠️ SRS v2 returned empty list");
        }
      } else {
        debugPrint("❌ SRS v2 failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ SRS v2 exception: $e");
    }

    return false;
  }

  Future<void> fetchSrsFiltersv3() async {
    final prefs = await SharedPreferences.getInstance();

    // Load required params from SharedPreferences
    final sourceCity = prefs.getString("srsSourceCityName");
    final destinationCity = prefs.getString("srsDestinationCityName");
    final travelDate = prefs.getString("selectedDate"); // yyyy-MM-dd
    final srsSourceCityId = prefs.getString("srsSourceCityId");
    final srsDestinationCityId = prefs.getString("srsDestinationCityId");

    if (sourceCity == null ||
        destinationCity == null ||
        travelDate == null ||
        srsSourceCityId == null ||
        srsDestinationCityId == null) {
      debugPrint("⚠️ Missing params in SharedPreferences for filters");
      return;
    }

    // Construct URL with correct query params
    final url =
        "${ApiUrls.srsFiltersV3}?sourceCity=$sourceCity&destinationCity=$destinationCity&doj=$travelDate&srsSourceCityId=$srsSourceCityId&srsDestinationCityId=$srsDestinationCityId";

    debugPrint("🟡 Calling SRS Filters v3 API → $url");

    try {
      final response = await ApiBase.getRequest(
        extendedURL: url,
        withToken: true,
      );

      // 🟠 Log response
      debugPrint("🟠 SRS Filters v3 Status: ${response.statusCode}");
      debugPrint("🟠 SRS Filters v3 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle filters data (e.g. store in state)
        debugPrint("✅ Parsed Filters: $data");
        final List<dynamic> boarding = data["boardingPoints"] ?? [];
        final List<dynamic> dropping = data["droppingPoints"] ?? [];
        final List<dynamic> operators = data["busPartners"] ?? [];
        setState(() {
          boardingPointsList =
              boarding
                  .map((e) => (e["stage"] ?? "").toString().trim())
                  .where((name) => name.isNotEmpty)
                  .toSet()
                  .toList();

          droppingPointsList =
              dropping
                  .map((e) => (e["stage"] ?? "").toString().trim())
                  .where((name) => name.isNotEmpty)
                  .toSet()
                  .toList();

          busOperatorsList = operators.map((e) => e.toString().trim()).toList();
        });

        debugPrint("✅ Boarding Points: $boardingPointsList");
        debugPrint("✅ Dropping Points: $droppingPointsList");
        debugPrint("✅ Bus Operators: $busOperatorsList");
      }
    } catch (e) {
      debugPrint("❌ Error fetching SRS Filters: $e");
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
      extendedURL: "${ApiUrls.getSrsSeatLayout}$tripId",
      withToken: false,
    );

    final result = jsonDecode(response.body)['result'];
    final layout = result['bus_layout'];

    final coachDetails = layout['coach_details'].toString().split(',');

    final String boardingRaw = layout['boarding_stages'] ?? '';
    final String droppingRaw = layout['dropoff_stages'] ?? '';

    final List<StagePointseat> boardingStages = StagePointseat.parseStageList(
      boardingRaw,
    );
    final List<StagePointseat> droppingStages = StagePointseat.parseStageList(
      droppingRaw,
    );

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
          destinationId:
              result['destination_id']?.toString() ?? '', // 👈 And here
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
              'fare': double.tryParse(bus.nonAcSleeperRate.toString()) ?? 0,
              'operator': 'VRL Travels',
              'busType': bus.busTypeName.toString(),
              'boardingPoints': bus.boardingPoints ?? [], // if available
              'droppingPoints': bus.droppingPoints ?? [], // if available
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
              'fare': double.tryParse(bus.fare.toString()) ?? 0,
              'operator': bus.operatorServiceName ?? '',
              'busType': bus.busType.toString(),
              'rating': (random.nextDouble() + 4).clamp(4.0, 5.0),
              'ratingCount': random.nextInt(65) + 37,
            },
          ),
    ];
    final filteredBuses =
        allBuses.where((bus) {
          // Operator filter
          if (selectedOperators.isNotEmpty &&
              !selectedOperators.any(
                (op) =>
                    op.toLowerCase() ==
                    ((bus['operator'] ?? '') as String).toLowerCase(),
              )) {
            return false;
          }

          // Bus Type filter
          if (selectedBusTypes.isNotEmpty &&
              !selectedBusTypes.any(
                (type) => type.toLowerCase() == (bus['busType'] ?? ''),
              )) {
            return false;
          }

          // Price range filter
          final fare = (bus['fare'] as double);
          if (fare < selectedPriceRange.start ||
              fare > selectedPriceRange.end) {
            return false;
          }

          // Boarding Point filter
          if (selectedBoardingPoints.isNotEmpty) {
            final boarding =
                (bus['boardingPoints'] as List<String>)
                    .map((e) => e.toLowerCase())
                    .toList();
            if (!selectedBoardingPoints.any(
              (bp) => boarding.contains(bp.toLowerCase()),
            )) {
              return false;
            }
          }

          // Dropping Point filter
          if (selectedDroppingPoints.isNotEmpty) {
            final dropping =
                (bus['droppingPoints'] as List<String>)
                    .map((e) => e.toLowerCase())
                    .toList();
            if (!selectedDroppingPoints.any(
              (dp) => dropping.contains(dp.toLowerCase()),
            )) {
              return false;
            }
          }

          return true;
        }).toList();
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
          // Filters Row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.tune, color: Color(0xFF033564), size: 24),
                      SizedBox(width: 4),
                    ],
                  ),
                  const SizedBox(width: 12), // spacing after Filters icon
                  _buildFilterButton(
                    "Boarding Point",
                    Icons.directions_bus,
                        () {
                      _showBoardingFilter(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton("Dropping Point", Icons.place, () {
                    _showDroppingFilter(context);
                  }),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    "Bus Operator",
                    Icons.bus_alert,
                        () {
                      _showBusOperatorFilter(context);
                    },
                  ),
                  // const SizedBox(width: 8),
                  // _buildFilterButton("Bus Type", Icons.directions, () {
                  //   _showBusTypeFilter(context);
                  // }),
                  const SizedBox(width: 8),
                  _buildFilterButton("Price", Icons.currency_rupee, () {
                    _showPriceFilter(context);
                  }),
                ],
              ),
            ),
          ),
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
              itemCount: filteredBuses.length,
              itemBuilder: (context, index) {
                final bus = filteredBuses[index];
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
                      await prefs.setString(
                        'busType',
                        bus['busType'].toString(),
                      );
                      await prefs.setString(
                        'type',
                        bus['type'].toString(),
                      );
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
                        await prefs.setString(
                          'referenceNumber',
                          bus['referenceNumber'].toString(),
                        );
                        print(
                          "Reference Number: ${bus['referenceNumber']}",
                        );

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
                        final SrsSeatLayoutResponse response =
                        await getSRSSeatLayout(
                          bus['id'].toString(),
                        );
                        final parsedBus = bus['bus'] as SrsBusModel;
                        await prefs.setString(
                          'id_srs',
                          bus['id'].toString(),
                        );
                        await prefs.setString(
                          'origin_id_srs',
                          response.originId,
                        ); // ✅ Save origin_id
                        await prefs.setString(
                          'destination_id_srs',
                          response.destinationId,
                        ); // ✅ Save destination_id

                        print("Reference Number (SRS): ${bus['id']}");
                        print("Origin ID: ${response.originId}");
                        print(
                          "Destination ID: ${response.destinationId}",
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => SrsSeatLayoutPage(
                              seats: response.seats,
                              bus: parsedBus,
                              boardingStages:
                              response.boardingStages,
                              dropoffStages:
                              response.droppingStages,
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
    );  }





  Widget _buildFilterButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _showBoardingFilter(BuildContext context) {
    Set<String> selected = {...selectedBoardingPoints};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Set<String> selected = {};
            String searchQuery = "";

            List<String> filteredPoints =
            boardingPointsList
                .where(
                  (point) => point.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
                .toList();

            return FractionallySizedBox(
              heightFactor: 0.75, // 👈 only 3/4th screen
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// --- Header Row ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Boarding Point",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF033564), // dark blue heading
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF033564),
                          ), // dark blue close icon
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    /// --- Search Bar ---
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blue.shade700,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // <-- Curved border
                          borderSide: BorderSide(
                            color: Colors.lightBlue.shade300,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // <-- Same curve when focused
                          borderSide: BorderSide(
                            color: Colors.lightBlue.shade400,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    /// --- Boarding Points List ---
                    Expanded(
                      child: ListView(
                        children:
                        filteredPoints.map((point) {
                          return CheckboxListTile(
                            title: Text(point),
                            value: selected.contains(point),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selected.add(point);
                                } else {
                                  selected.remove(point);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    /// --- Buttons Row ---
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => selected.clear());
                            },
                            child: const Text("Clear All"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF14bde3),
                            ),
                            onPressed: () {
                              Navigator.pop(context, selected.toList());
                            },
                            child: const Text(
                              "Apply",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          selectedBoardingPoints =
              result.toSet(); // ✅ Save globally for filtering
        });
      }
    });
  }

  void _showDroppingFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Set<String> selected = {};
            String searchQuery = "";

            List<String> filteredPoints =
            droppingPointsList
                .where(
                  (point) => point.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
                .toList();
            return FractionallySizedBox(
              heightFactor: 0.75, // 👈 only 3/4th screen
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// --- Header Row ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Dropping Point",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF033564), // dark blue heading
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF033564),
                          ), // dark blue close icon
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    /// --- Search Bar ---
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blue.shade700,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // <-- Curved border
                          borderSide: BorderSide(
                            color: Colors.lightBlue.shade300,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // <-- Same curve when focused
                          borderSide: BorderSide(
                            color: Colors.lightBlue.shade400,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    /// --- Boarding Points List ---
                    Expanded(
                      child: ListView(
                        children:
                        filteredPoints.map((point) {
                          return CheckboxListTile(
                            title: Text(point),
                            value: selected.contains(point),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selected.add(point);
                                } else {
                                  selected.remove(point);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    /// --- Buttons Row ---
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => selected.clear());
                            },
                            child: const Text("Clear All"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF14bde3),
                            ),
                            onPressed: () {
                              Navigator.pop(context, selected.toList());
                            },
                            child: const Text(
                              "Apply",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          selectedDroppingPoints =
              result.toSet(); // ✅ Save globally for filtering
        });
      }
    });
  }

  void _showBusOperatorFilter(BuildContext context) {
    Set<String> selected = {...selectedOperators};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setState) {
            List<String> filteredOperators =
            busOperatorsList
                .where(
                  (op) =>
                  op.toLowerCase().contains(searchQuery.toLowerCase()),
            )
                .toList();

            return FractionallySizedBox(
              heightFactor: 0.75,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Select Bus Operator",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF033564),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF033564),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blue.shade700,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.lightBlue.shade300,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.lightBlue.shade400,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredOperators.length,
                        itemBuilder: (context, index) {
                          final op = filteredOperators[index];
                          return CheckboxListTile(
                            title: Text(op),
                            value: selected.contains(op),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selected.add(op);
                                } else {
                                  selected.remove(op);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => selected.clear());
                            },
                            child: const Text("Clear All"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF14bde3),
                            ),
                            onPressed: () {
                              Navigator.pop(context, selected.toList());
                            },
                            child: const Text(
                              "Apply",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          selectedOperators = result.toSet(); // ✅ Save globally for filtering
        });
      }
    });
  }

  void _showBusTypeFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final busTypes = [
          {"label": "Seater", "icon": Icons.airline_seat_recline_normal},
          {"label": "Sleeper", "icon": Icons.bed},
          {"label": "AC", "icon": Icons.ac_unit},
          {"label": "Non-AC", "icon": Icons.airline_seat_recline_normal},
        ];

        Set<String> selected = {};

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Title & Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bus Type",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF033564), // Dark Blue
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF033564)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // List of bus types
                  ...busTypes.map((bus) {
                    return ListTile(
                      leading: Icon(
                        bus["icon"] as IconData,
                        color: Colors.lightBlue, // Light Blue Icon
                      ),
                      title: Text(bus["label"] as String),
                      trailing: Checkbox(
                        value: selected.contains(bus["label"]),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              selected.add(bus["label"] as String);
                            } else {
                              selected.remove(bus["label"]);
                            }
                          });
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Buttons (full width)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selected.clear();
                            });
                          },
                          child: const Text("Clear"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF033564,
                            ), // Dark Blue
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, selected.toList());
                          },
                          child: const Text("Apply"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showPriceFilter(BuildContext context) async {
    final result = await showModalBottomSheet<RangeValues>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        RangeValues tempRange = selectedPriceRange;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title + close icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Price Range",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF033564),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price values displayed dynamically
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${tempRange.start.toInt()}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "₹${tempRange.end.toInt()}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Range slider
                  RangeSlider(
                    values: tempRange,
                    min: 0,
                    max: 4000,
                    divisions: 30,
                    activeColor: const Color(0xFF14bde3),
                    inactiveColor: Colors.grey.shade300,
                    onChanged: (newRange) {
                      setState(() => tempRange = newRange);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF033564),
                            side: const BorderSide(color: Color(0xFF033564)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            setState(() => tempRange = const RangeValues(0, 4000));
                          },
                          child: const Text("Clear All"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14bde3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, tempRange);
                          },
                          child: const Text(
                            "Apply",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() {
        selectedPriceRange = result;
      });
    }
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
