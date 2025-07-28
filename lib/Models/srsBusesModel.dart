class SrsBusModel {
  final int id;
  final String depTime;
  final String arrTime;
  final String duration;
  final int availableSeats;
  final String fare;
  final String operatorServiceName;
  final String busType;

  final List<StagePoint> boardingStages;
  final List<StagePoint> dropoffStages;

  SrsBusModel({
    required this.id,
    required this.depTime,
    required this.arrTime,
    required this.duration,
    required this.availableSeats,
    required this.fare,
    required this.operatorServiceName,
    required this.busType,
    required this.boardingStages,
    required this.dropoffStages,
  });

  factory SrsBusModel.fromJson(Map<String, dynamic> json) {
    List<StagePoint> parseStages(List<dynamic>? raw) {
      if (raw == null) return [];
      return raw.map((e) => StagePoint.fromJson(e)).toList();
    }

    return SrsBusModel(
      id: json['id'] ?? 0,
      depTime: json['dep_time'] ?? '',
      arrTime: json['arr_time'] ?? '',
      duration: json['duration'] ?? '',
      availableSeats: json['available_seats'] ?? 0,
      fare: (json['show_fare_screen']?.toString().split('/').first ?? '0').trim(),
      operatorServiceName: json['operator_service_name'] ?? 'Unknown',
      busType: json['bus_type']?.toString() ?? 'Not Available',
      boardingStages: parseStages(json['boarding_stages']),
      dropoffStages: parseStages(json['dropoff_stages']),
    );
  }
}

class StagePoint {
  final String stage;
  final String time;

  StagePoint({required this.stage, required this.time});

  factory StagePoint.fromJson(Map<String, dynamic> json) {
    return StagePoint(
      stage: json['stage'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
