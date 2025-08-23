class SeatLayout {
  final String seatName;
  final bool isAvailable;
  final bool isLadies;
  final String deck; // 'U' or 'L'
  final String seatType; // 'SL' / 'SE' etc.
  final int row;
  final int column;
  final int columnSpan; // For vertical sleepers, 2 means double-height
  final double fare;
  final bool isSelected;
  final int blockType;
  final double serviceTax;

  SeatLayout({
    required this.seatName,
    required this.isAvailable,
    required this.isLadies,
    required this.deck,
    required this.seatType,
    required this.row,
    required this.column,
    required this.columnSpan,
    required this.fare,
    required this.blockType,
    this.isSelected = false,
    required this.serviceTax,
  });


  factory SeatLayout.fromJson(Map<String, dynamic> json) {
    final seatTypeRaw = json['SeatType']?.toString().toUpperCase() ?? '';
    final columnSpan = (seatTypeRaw == 'SL') ? 2 : 1; // SL = Sleeper, vertical

    return SeatLayout(
      seatName: json['SeatNo'] ?? '',
      isAvailable: json['Available'] == 'Y',
      isLadies: json['IsLadiesSeat'] == 'Y',
      deck: (json['UpLowBerth'] ?? 'L').toString().startsWith('U') ? 'U' : 'L',
      seatType: seatTypeRaw,
      row: int.tryParse(json['Row']?.toString() ?? '') ?? 0,
      column: int.tryParse(json['Column']?.toString() ?? '') ?? 0,
      columnSpan: columnSpan,
      fare: double.tryParse(json['SeatRate']?.toString() ?? '') ?? 0,
      blockType: int.tryParse(json['BlockType']?.toString() ?? '0') ?? 0,
      serviceTax: (json['ServiceTax'] ?? 0).toDouble(),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SeatNo': seatName,
      'Available': isAvailable ? 'Y' : 'N',
      'IsLadiesSeat': isLadies ? 'Y' : 'N',
      'UpLowBerth': deck,
      'SeatType': seatType,
      'Row': row,
      'Column': column,
      'ColumnSpan': columnSpan,
      'Fare': fare,
      'BlockType': blockType,
    };
  }

  // Useful for toggling selection in UI
  SeatLayout copyWith({bool? isSelected}) {
    return SeatLayout(
      seatName: seatName,
      isAvailable: isAvailable,
      isLadies: isLadies,
      deck: deck,
      seatType: seatType,
      row: row,
      column: column,
      columnSpan: columnSpan,
      fare: fare,
      isSelected: isSelected ?? this.isSelected,
      blockType: blockType,
      serviceTax: serviceTax,
    );
  }
}
