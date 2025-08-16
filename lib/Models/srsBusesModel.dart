class SrsBusModel {
  final int id;
  final String depTime;
  final String arrTime;
  final String duration;
  final int availableSeats;
  final String fare;
  final String operatorServiceName;
  final String busType;
  final String tripId; // For seat layout fetch

  SrsBusModel({
    required this.id,
    required this.depTime,
    required this.arrTime,
    required this.duration,
    required this.availableSeats,
    required this.fare,
    required this.operatorServiceName,
    required this.busType,
    required this.tripId,
  });

  factory SrsBusModel.fromJson(Map<String, dynamic> json) {
    return SrsBusModel(
      id: json['id'] ?? 0,
      depTime: json['dep_time'] ?? '',
      arrTime: json['arr_time'] ?? '',
      duration: json['duration'] ?? '',
      availableSeats: json['available_seats'] ?? 0,
      fare: (json['show_fare_screen']?.toString().split('/').first ?? '0').trim(),
      operatorServiceName: json['operator_service_name'] ?? 'Unknown',
      busType: json['bus_type'] ?? 'Not Available',
      tripId: json['trip_id'] ?? '',
    );
  }
}
