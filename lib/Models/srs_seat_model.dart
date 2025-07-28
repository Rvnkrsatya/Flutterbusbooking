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
  final String cost; // 💰 New field

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
    required this.cost, // 💰 add to constructor
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
    required Map<String, String> seatCostMap, // 💰 New map (e.g., {'LB': '550', 'ST': '450'})
  }) {
    final seatParts = seatInfo.split('|');
    if (seatParts.length < 2) {
      throw ArgumentError('Invalid seatInfo format: $seatInfo');
    }

    final seatId = seatParts[0].trim(); // e.g., 1U
    final seatType = seatParts[1].trim().toUpperCase(); // e.g., SUB
    final isUpper = seatId.toLowerCase().endsWith('u');
    final isAvailable = availableSet.contains(seatId);
    final isLadiesOnly = ladiesSet.contains(seatId);
    final isLadiesBooked = ladiesBookedSet?.contains(seatId) ?? false;
    final isGentsBooked = gentsBookedSet?.contains(seatId) ?? false;
    final isBooked = isLadiesBooked || isGentsBooked || !isAvailable;

    final seatCost = seatCostMap[seatType] ?? ''; // 💰 Fallback to '0' if not found

    return SrsSeat(
      seatId: seatId,
      seatType: seatType,
      position: seatId,
      isAvailable: isAvailable,
      isLadiesOnly: isLadiesOnly,
      isLadiesBooked: isLadiesBooked,
      isGentsBooked: isGentsBooked,
      isBooked: isBooked,
      isUpper: isUpper,
      row: row,
      column: col,
      cost: seatCost, // 💰 Assign cost
    );
  }
}
