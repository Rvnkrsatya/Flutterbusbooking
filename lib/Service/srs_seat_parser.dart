// import '../Models/srs_seat_model.dart';
//
// List<SrsSeat> parseSrsSeats(Map<String, dynamic> response) {
//   final layout = response['result']['bus_layout'];
//   final layoutStr = layout['coach_details'];
//   final availableStr = layout['available'];
//   final ladiesBookedStr = layout['ladies_booked_seats'];
//   final gentsBookedStr = layout['gents_booked_seats'];
//   final ladiesOnlyStr = layout['ladies_seats'];
//   final costStr = layout['cost']?.toString() ?? '';
//
//   // Parse cost map like: LB:550.00,ST:450.00,...
//   Map<String, String> parseCostMap(String costString) {
//     final pairs = costString.split(',');
//     return {
//       for (var pair in pairs)
//         if (pair.contains(':'))
//           pair.split(':')[0].trim(): pair.split(':')[1].split('.').first.trim(),
//     };
//   }
//
//   final seatCostMap = parseCostMap(costStr);
//
//   final availableSeats = availableStr.split(',').map((e) => e.split('|')[0].trim()).toSet();
//   final ladiesBookedSeats = ladiesBookedStr.split(',').map((e) => e.trim()).toSet();
//   final gentsBookedSeats = gentsBookedStr.split(',').map((e) => e.trim()).toSet();
//   final ladiesOnlySeats = ladiesOnlyStr.split(',').map((e) => e.trim()).toSet();
//
//   final List<SrsSeat> seats = [];
//   final layoutLines = layoutStr.split(',');
//
//   for (int row = 0; row < layoutLines.length; row++) {
//     final parts = layoutLines[row].split('-');
//     for (int col = 0; col < parts.length; col++) {
//       final seat = parts[col].trim();
//
//       if (!seat.contains('|') || seat == '.GY' || seat == '--') continue;
//
//       final seatData = seat.split('|');
//       if (seatData.length < 2) continue;
//
//       final seatId = seatData[0].trim();
//       final seatType = seatData[1].trim().toUpperCase();
//
//       final isAvailable = availableSeats.contains(seatId);
//       final isLadiesBooked = ladiesBookedSeats.contains(seatId);
//       final isGentsBooked = gentsBookedSeats.contains(seatId);
//       final isLadiesOnly = ladiesOnlySeats.contains(seatId);
//       final isBooked = isLadiesBooked || isGentsBooked || (!isAvailable);
//       final isUpper = seatId.toLowerCase().endsWith('u');
//       final seatCost = seatCostMap[seatType] ?? '';
//   //
//   //     seats.add(SrsSeat(
//   //       seatId: seatId,
//   //       seatType: seatType,
//   //       position: seatId,
//   //       isAvailable: isAvailable,
//   //       isLadiesOnly: isLadiesOnly,
//   //       isLadiesBooked: isLadiesBooked,
//   //       isGentsBooked: isGentsBooked,
//   //       isBooked: isBooked,
//   //       isUpper: isUpper,
//   //       row: row,
//   //       column: col,
//   //       cost: seatCost, // ✅ add this
//   //     ));
//   //   }
//   // }
//
//   return seats;
// }
