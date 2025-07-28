class Bus {
  final String id;
  final String operatorName;
  final String departureTime;
  final String arrivalTime;
  final String busType;
  final double fare;
  final bool isVrl;
  final bool isSrs;
  final bool isSeatSeller;
  final String referenceNumber;

  Bus({
    required this.id,
    required this.operatorName,
    required this.departureTime,
    required this.arrivalTime,
    required this.busType,
    required this.fare,
    required this.referenceNumber,
    this.isVrl = false,
    this.isSrs = false,
    this.isSeatSeller = false,
  });
}
