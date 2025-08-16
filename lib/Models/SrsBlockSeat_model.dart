class SrsBlockSeatResponse {
  final TicketDetails ticketDetails;

  SrsBlockSeatResponse({required this.ticketDetails});

  factory SrsBlockSeatResponse.fromJson(Map<String, dynamic> json) {
    return SrsBlockSeatResponse(
      ticketDetails: TicketDetails.fromJson(json['result']['ticket_details']),
    );
  }
}

class TicketDetails {
  final String pnrNumber;
  final String operatorPnr;
  final int tentativeTimeInMillisec;
  final String tentativeExpiryTime;
  final List<SeatFareDetail> seatFareDetails;

  TicketDetails({
    required this.pnrNumber,
    required this.operatorPnr,
    required this.tentativeTimeInMillisec,
    required this.tentativeExpiryTime,
    required this.seatFareDetails,
  });

  factory TicketDetails.fromJson(Map<String, dynamic> json) {
    var fareDetailsJson = json['seat_fare_details'] as List;
    List<SeatFareDetail> fareDetails = fareDetailsJson
        .map((e) => SeatFareDetail.fromJson(e['seat_detail']))
        .toList();

    return TicketDetails(
      pnrNumber: json['pnr_number'],
      operatorPnr: json['operator_pnr'],
      tentativeTimeInMillisec: json['tentative_time_in_millisec'],
      tentativeExpiryTime: json['tentative_expiry_time'],
      seatFareDetails: fareDetails,
    );
  }
}

class SeatFareDetail {
  final String seatNumber;
  final int fare;
  final int serviceTax;
  final int convenienceCharge;
  final int offerDiscount;
  final int discount;
  final int additionalFare;

  SeatFareDetail({
    required this.seatNumber,
    required this.fare,
    required this.serviceTax,
    required this.convenienceCharge,
    required this.offerDiscount,
    required this.discount,
    required this.additionalFare,
  });

  factory SeatFareDetail.fromJson(Map<String, dynamic> json) {
    return SeatFareDetail(
      seatNumber: json['seat_number'],
      fare: json['fare'],
      serviceTax: json['service_tax'],
      convenienceCharge: json['convenience_charge'],
      offerDiscount: json['offer_discount'],
      discount: json['discount'],
      additionalFare: json['additional_fare'],
    );
  }
}
