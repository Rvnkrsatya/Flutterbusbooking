class SrsSeat {
  final String seatId;
  final String seatType;
  final String position;
  final bool isAvailable;
  final bool isLadiesOnly;
  final bool isLadiesBooked;
  final bool isGentsBooked;
  final bool isBooked;
  final bool isUpper;
  bool isSelected;
  final int row;
  final int column;
  final String cost;
  final String originId;
  final String destinationId;

  SrsSeat({
    required this.seatId,
    required this.seatType,
    required this.position,
    required this.isAvailable,
    required this.isLadiesOnly,
    required this.isLadiesBooked,
    required this.isGentsBooked,
    required this.isBooked,
    required this.isUpper,
    required this.row,
    required this.column,
    required this.cost,
    required this.originId,
    required this.destinationId,
    this.isSelected = false,
  });

  factory SrsSeat.fromLayout({
    required String seatInfo,
    required Set<String> availableSet,
    required Set<String> ladiesSet,
    Set<String>? gentsBookedSet,
    Set<String>? ladiesBookedSet,
    required int row,
    required int col,
    required Map<String, String> seatCostMap,
    required String originId,
    required String destinationId,
  }) {
    final seatParts = seatInfo.split('|');
    if (seatParts.length < 2) {
      throw ArgumentError('Invalid seatInfo format: $seatInfo');
    }

    final seatName = seatParts[0].trim();
    final seatType = seatParts[1].trim().toUpperCase();

    final isUpper = ['SUB', 'UB', 'DUB'].contains(seatType);
    final isAvailable = availableSet.contains(seatName);
    final isLadiesOnly = ladiesSet.contains(seatName);
    final isLadiesBooked = ladiesBookedSet?.contains(seatName) ?? false;
    final isGentsBooked = gentsBookedSet?.contains(seatName) ?? false;
    final isBooked = isLadiesBooked || isGentsBooked || !isAvailable;
    final seatCost = seatCostMap[seatType] ?? '';

    return SrsSeat(
      seatId: seatName,
      seatType: seatType,
      position: seatName,
      isAvailable: isAvailable,
      isLadiesOnly: isLadiesOnly,
      isLadiesBooked: isLadiesBooked,
      isGentsBooked: isGentsBooked,
      isBooked: isBooked,
      isUpper: isUpper,
      row: row,
      column: col,
      cost: seatCost,
      originId: originId,
      destinationId: destinationId,
    );
  }
}

class StagePointseat {
  final String id;
  final String time;
  final String fullAddress;
  final String stage;
  final String contact;
  final String city;
  final String seq;

  StagePointseat({
    required this.id,
    required this.time,
    required this.fullAddress,
    required this.stage,
    required this.contact,
    required this.city,
    required this.seq,
  });

  factory StagePointseat.fromRaw(String raw) {
    final parts = raw.split('|');
    return StagePointseat(
      id: parts.length > 0 ? parts[0] : '',
      time: parts.length > 1 ? parts[1] : '',
      fullAddress: parts.length > 2 ? parts[2] : '',
      stage: parts.length > 3 ? parts[3] : '',
      contact: parts.length > 4 ? parts[4] : '',
      city: parts.length > 5 ? parts[5] : '',
      seq: parts.length > 6 ? parts[6] : '',
    );
  }

  static List<StagePointseat> parseStageList(String raw) {
    if (raw.isEmpty) return [];
    return raw
        .split('~')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map(StagePointseat.fromRaw)
        .toList();
  }

  Map<String, String> toMap() {
    return {
      "id": id,
      "time": time,
      "location": stage,
      "fullAddress": fullAddress,
      "stage": stage,
      "contact": contact,
      "city": city,
      "seq": seq,
    };
  }
}

class SrsSeatLayoutResponse {
  final List<SrsSeat> seats;
  final List<StagePointseat> boardingStages;
  final List<StagePointseat> droppingStages;
  final String originId;
  final String destinationId;

  SrsSeatLayoutResponse({
    required this.seats,
    required this.boardingStages,
    required this.droppingStages,
    required this.originId,
    required this.destinationId,
  });

  factory SrsSeatLayoutResponse.fromJson(Map<String, dynamic> json) {
    return SrsSeatLayoutResponse(
      originId: json['origin_id']?.toString() ?? '',
      destinationId: json['destination_id']?.toString() ?? '',
      boardingStages: StagePointseat.parseStageList(json['boarding_stages'] ?? ''),
      droppingStages: StagePointseat.parseStageList(json['dropoff_stages'] ?? ''),
      seats: [], // You will need to build the list using SrsSeat.fromLayout() externally
    );
  }
}
