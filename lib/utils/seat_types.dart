class SeatType {
  final int width;
  final int length;
  final int zIndex;

  const SeatType({
    required this.width,
    required this.length,
    required this.zIndex,
  });
}

const Map<String, SeatType> seatTypes = {
  "SS": SeatType(width: 1, length: 1, zIndex: 0),
  "SL": SeatType(width: 2, length: 2, zIndex: 0),
  "LB": SeatType(width: 2, length: 2, zIndex: 0),
  "UB": SeatType(width: 2, length: 2, zIndex: 1),
  // Add the rest of the seat types here...
};
