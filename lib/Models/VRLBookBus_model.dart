class BookBusResponse {
  final int status;
  final String message;
  final BookBusData? data;

  BookBusResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory BookBusResponse.fromJson(Map<String, dynamic> json) {
    return BookBusResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? BookBusData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class BookBusData {
  final String userId;
  final String sourceCity;
  final String destinationCity;
  final String doj;
  final String boardingPoint;
  final String droppingPoint;
  final String busOperator;
  final String busType;
  final String selectedSeats;
  final String customerName;
  final String customerLastName;
  final String customerEmail;
  final String customerPhone;
  final List<ReservationSchema> reservationSchema;
  final num totalAmount;
  final String bookingStatus;
  final String pickUpTime;
  final String reachTime;
  final String cancellationPolicy;
  final String sentBookingRemainer;
  final String getJourneyFeedback;
  final String blockKey;
  final bool isVrl;
  final bool isSrs;
  final String driverNumber;
  final String agentCode;
  final String id; // _id from API
  final List<dynamic> blockSeatPaxDetails;
  final String createdAt;
  final String updatedAt;
  final int v;

  BookBusData({
    required this.userId,
    required this.sourceCity,
    required this.destinationCity,
    required this.doj,
    required this.boardingPoint,
    required this.droppingPoint,
    required this.busOperator,
    required this.busType,
    required this.selectedSeats,
    required this.customerName,
    required this.customerLastName,
    required this.customerEmail,
    required this.customerPhone,
    required this.reservationSchema,
    required this.totalAmount,
    required this.bookingStatus,
    required this.pickUpTime,
    required this.reachTime,
    required this.cancellationPolicy,
    required this.sentBookingRemainer,
    required this.getJourneyFeedback,
    required this.blockKey,
    required this.isVrl,
    required this.isSrs,
    required this.driverNumber,
    required this.agentCode,
    required this.id,
    required this.blockSeatPaxDetails,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory BookBusData.fromJson(Map<String, dynamic> json) {
    return BookBusData(
      userId: json['userId'] ?? '',
      sourceCity: json['sourceCity'] ?? '',
      destinationCity: json['destinationCity'] ?? '',
      doj: json['doj'] ?? '',
      boardingPoint: json['boardingPoint'] ?? '',
      droppingPoint: json['droppingPoint'] ?? '',
      busOperator: json['busOperator'] ?? '',
      busType: json['busType'] ?? '',
      selectedSeats: json['selectedSeats'] ?? '',
      customerName: json['customerName'] ?? '',
      customerLastName: json['customerLastName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      reservationSchema: (json['reservationSchema'] as List<dynamic>?)
          ?.map((e) => ReservationSchema.fromJson(e))
          .toList() ??
          [],
      totalAmount: json['totalAmount'] ?? 0,
      bookingStatus: json['bookingStatus'] ?? '',
      pickUpTime: json['pickUpTime'] ?? '',
      reachTime: json['reachTime'] ?? '',
      cancellationPolicy: json['cancellationPolicy'] ?? '',
      sentBookingRemainer: json['sentBookingRemainer'] ?? '',
      getJourneyFeedback: json['getJourneyFeedback'] ?? '',
      blockKey: json['blockKey'] ?? '',
      isVrl: json['isVrl'] ?? false,
      isSrs: json['isSrs'] ?? false,
      driverNumber: json['driverNumber'] ?? '',
      agentCode: json['agentCode'] ?? '',
      id: json['_id'] ?? '',
      blockSeatPaxDetails: json['blockSeatPaxDetails'] ?? [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sourceCity': sourceCity,
      'destinationCity': destinationCity,
      'doj': doj,
      'boardingPoint': boardingPoint,
      'droppingPoint': droppingPoint,
      'busOperator': busOperator,
      'busType': busType,
      'selectedSeats': selectedSeats,
      'customerName': customerName,
      'customerLastName': customerLastName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'reservationSchema': reservationSchema.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'bookingStatus': bookingStatus,
      'pickUpTime': pickUpTime,
      'reachTime': reachTime,
      'cancellationPolicy': cancellationPolicy,
      'sentBookingRemainer': sentBookingRemainer,
      'getJourneyFeedback': getJourneyFeedback,
      'blockKey': blockKey,
      'isVrl': isVrl,
      'isSrs': isSrs,
      'driverNumber': driverNumber,
      'agentCode': agentCode,
      '_id': id,
      'blockSeatPaxDetails': blockSeatPaxDetails,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}

class ReservationSchema {
  final String referenceNumber;
  final String passengerName;
  final String seatNames;
  final String email;
  final String phone;
  final int pickUpID;
  final int dropID;
  final num payableAmount;
  final int totalPassengers;
  final int discount;
  final String seatDetails;
  final List<PaxDetail> paxDetails;
  final int gstState;
  final String gstCompanyName;
  final String gstRegNo;
  final String apipnrNo;
  final String id; // _id from reservationSchema

  ReservationSchema({
    required this.referenceNumber,
    required this.passengerName,
    required this.seatNames,
    required this.email,
    required this.phone,
    required this.pickUpID,
    required this.dropID,
    required this.payableAmount,
    required this.totalPassengers,
    required this.discount,
    required this.seatDetails,
    required this.paxDetails,
    required this.gstState,
    required this.gstCompanyName,
    required this.gstRegNo,
    required this.apipnrNo,
    required this.id,
  });

  factory ReservationSchema.fromJson(Map<String, dynamic> json) {
    return ReservationSchema(
      referenceNumber: json['referenceNumber'] ?? '',
      passengerName: json['passengerName'] ?? '',
      seatNames: json['seatNames'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      pickUpID: json['pickUpID'] ?? 0,
      dropID: json['dropID'] ?? 0,
      payableAmount: json['payableAmount'] ?? 0,
      totalPassengers: json['totalPassengers'] ?? 0,
      discount: json['discount'] ?? 0,
      seatDetails: json['seatDetails'] ?? '',
      paxDetails: (json['paxDetails'] as List<dynamic>?)
          ?.map((e) => PaxDetail.fromJson(e))
          .toList() ??
          [],
      gstState: json['gstState'] ?? 0,
      gstCompanyName: json['gstCompanyName'] ?? '',
      gstRegNo: json['gstRegNo'] ?? '',
      apipnrNo: json['apipnrNo'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referenceNumber': referenceNumber,
      'passengerName': passengerName,
      'seatNames': seatNames,
      'email': email,
      'phone': phone,
      'pickUpID': pickUpID,
      'dropID': dropID,
      'payableAmount': payableAmount,
      'totalPassengers': totalPassengers,
      'discount': discount,
      'seatDetails': seatDetails,
      'paxDetails': paxDetails.map((e) => e.toJson()).toList(),
      'gstState': gstState,
      'gstCompanyName': gstCompanyName,
      'gstRegNo': gstRegNo,
      'apipnrNo': apipnrNo,
      '_id': id,
    };
  }
}

class PaxDetail {
  final String seatName;
  final String paxName;
  final String mobileNo;
  final int paxAge;
  final num baseFare;
  final num gstFare;
  final num totalFare;
  final int idProofId;
  final String idProofDetails;
  final String id; // _id from paxDetails

  PaxDetail({
    required this.seatName,
    required this.paxName,
    required this.mobileNo,
    required this.paxAge,
    required this.baseFare,
    required this.gstFare,
    required this.totalFare,
    required this.idProofId,
    required this.idProofDetails,
    required this.id,
  });

  factory PaxDetail.fromJson(Map<String, dynamic> json) {
    return PaxDetail(
      seatName: json['seatName'] ?? '',
      paxName: json['paxName'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      paxAge: json['paxAge'] ?? 0,
      baseFare: json['baseFare'] ?? 0,
      gstFare: json['gstFare'] ?? 0,
      totalFare: json['totalFare'] ?? 0,
      idProofId: json['idProofId'] ?? 0,
      idProofDetails: json['idProofDetails'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seatName': seatName,
      'paxName': paxName,
      'mobileNo': mobileNo,
      'paxAge': paxAge,
      'baseFare': baseFare,
      'gstFare': gstFare,
      'totalFare': totalFare,
      'idProofId': idProofId,
      'idProofDetails': idProofDetails,
      '_id': id,
    };
  }
}