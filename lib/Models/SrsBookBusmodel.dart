class SrsBookBusResponse {
  final int? status;
  final String? message;
  final BookingData? data;

  SrsBookBusResponse({this.status, this.message, this.data});

  factory SrsBookBusResponse.fromJson(Map<String, dynamic> json) {
    return SrsBookBusResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? BookingData.fromJson(json['data']) : null,
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

class BookingData {
  final String? userId;
  final String? sourceCity;
  final String? destinationCity;
  final String? doj;
  final String? boardingPoint;
  final String? droppingPoint;
  final String? busOperator;
  final String? busType;
  final String? selectedSeats;
  final String? customerName;
  final String? customerLastName;
  final String? customerEmail;
  final String? customerPhone;
  final int? totalAmount;
  final String? bookingStatus;
  final String? pickUpTime;
  final String? reachTime;
  final String? cancellationPolicy;
  final String? sentBookingRemainer;
  final String? getJourneyFeedback;
  final String? blockKey;
  final bool? isVrl;
  final bool? isSrs;
  final String? driverNumber;
  final SrsBlockSeatDetails? srsBlockSeatDetails;
  final String? agentCode;
  final String? id;
  final List<dynamic>? blockSeatPaxDetails;
  final List<dynamic>? reservationSchema;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  BookingData({
    this.userId,
    this.sourceCity,
    this.destinationCity,
    this.doj,
    this.boardingPoint,
    this.droppingPoint,
    this.busOperator,
    this.busType,
    this.selectedSeats,
    this.customerName,
    this.customerLastName,
    this.customerEmail,
    this.customerPhone,
    this.totalAmount,
    this.bookingStatus,
    this.pickUpTime,
    this.reachTime,
    this.cancellationPolicy,
    this.sentBookingRemainer,
    this.getJourneyFeedback,
    this.blockKey,
    this.isVrl,
    this.isSrs,
    this.driverNumber,
    this.srsBlockSeatDetails,
    this.agentCode,
    this.id,
    this.blockSeatPaxDetails,
    this.reservationSchema,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      userId: json['userId'],
      sourceCity: json['sourceCity'],
      destinationCity: json['destinationCity'],
      doj: json['doj'],
      boardingPoint: json['boardingPoint'],
      droppingPoint: json['droppingPoint'],
      busOperator: json['busOperator'],
      busType: json['busType'],
      selectedSeats: json['selectedSeats'],
      customerName: json['customerName'],
      customerLastName: json['customerLastName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      totalAmount: json['totalAmount'],
      bookingStatus: json['bookingStatus'],
      pickUpTime: json['pickUpTime'],
      reachTime: json['reachTime'],
      cancellationPolicy: json['cancellationPolicy'],
      sentBookingRemainer: json['sentBookingRemainer'],
      getJourneyFeedback: json['getJourneyFeedback'],
      blockKey: json['blockKey'],
      isVrl: json['isVrl'],
      isSrs: json['isSrs'],
      driverNumber: json['driverNumber'],
      srsBlockSeatDetails: json['srsBlockSeatDetails'] != null
          ? SrsBlockSeatDetails.fromJson(json['srsBlockSeatDetails'])
          : null,
      agentCode: json['agentCode'],
      id: json['_id'],
      blockSeatPaxDetails: json['blockSeatPaxDetails'],
      reservationSchema: json['reservationSchema'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
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
      'srsBlockSeatDetails': srsBlockSeatDetails?.toJson(),
      'agentCode': agentCode,
      '_id': id,
      'blockSeatPaxDetails': blockSeatPaxDetails,
      'reservationSchema': reservationSchema,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}

class SrsBlockSeatDetails {
  final BookTicket? bookTicket;
  final String? originId;
  final String? destinationId;
  final String? boardingAt;
  final String? dropOf;
  final int? noOfSeats;
  final String? travelDate;
  final CustomerCompanyGst? customerCompanyGst;
  final String? id;

  SrsBlockSeatDetails({
    this.bookTicket,
    this.originId,
    this.destinationId,
    this.boardingAt,
    this.dropOf,
    this.noOfSeats,
    this.travelDate,
    this.customerCompanyGst,
    this.id,
  });

  factory SrsBlockSeatDetails.fromJson(Map<String, dynamic> json) {
    return SrsBlockSeatDetails(
      bookTicket: json['book_ticket'] != null
          ? BookTicket.fromJson(json['book_ticket'])
          : null,
      originId: json['origin_id'],
      destinationId: json['destination_id'],
      boardingAt: json['boarding_at'],
      dropOf: json['drop_of'],
      noOfSeats: json['no_of_seats'],
      travelDate: json['travel_date'],
      customerCompanyGst: json['customer_company_gst'] != null
          ? CustomerCompanyGst.fromJson(json['customer_company_gst'])
          : null,
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_ticket': bookTicket?.toJson(),
      'origin_id': originId,
      'destination_id': destinationId,
      'boarding_at': boardingAt,
      'drop_of': dropOf,
      'no_of_seats': noOfSeats,
      'travel_date': travelDate,
      'customer_company_gst': customerCompanyGst?.toJson(),
      '_id': id,
    };
  }
}

class BookTicket {
  final SeatDetails? seatDetails;
  final ContactDetail? contactDetail;
  final String? id;

  BookTicket({this.seatDetails, this.contactDetail, this.id});

  factory BookTicket.fromJson(Map<String, dynamic> json) {
    return BookTicket(
      seatDetails: json['seat_details'] != null
          ? SeatDetails.fromJson(json['seat_details'])
          : null,
      contactDetail: json['contact_detail'] != null
          ? ContactDetail.fromJson(json['contact_detail'])
          : null,
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seat_details': seatDetails?.toJson(),
      'contact_detail': contactDetail?.toJson(),
      '_id': id,
    };
  }
}

class SeatDetails {
  final List<SeatDetail>? seatDetail;

  SeatDetails({this.seatDetail});

  factory SeatDetails.fromJson(Map<String, dynamic> json) {
    return SeatDetails(
      seatDetail: json['seat_detail'] != null
          ? List<SeatDetail>.from(
          json['seat_detail'].map((x) => SeatDetail.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seat_detail': seatDetail?.map((x) => x.toJson()).toList(),
    };
  }
}

class SeatDetail {
  final String? seatNumber;
  final String? fare;
  final String? title;
  final String? name;
  final String? age;
  final String? sex;
  final bool? isPrimary;
  final String? idCardType;
  final String? idCardNumber;
  final String? idCardIssuedBy;
  final String? id;

  SeatDetail({
    this.seatNumber,
    this.fare,
    this.title,
    this.name,
    this.age,
    this.sex,
    this.isPrimary,
    this.idCardType,
    this.idCardNumber,
    this.idCardIssuedBy,
    this.id,
  });

  factory SeatDetail.fromJson(Map<String, dynamic> json) {
    return SeatDetail(
      seatNumber: json['seat_number'],
      fare: json['fare'],
      title: json['title'],
      name: json['name'],
      age: json['age'],
      sex: json['sex'],
      isPrimary: json['is_primary'],
      idCardType: json['id_card_type'],
      idCardNumber: json['id_card_number'],
      idCardIssuedBy: json['id_card_issued_by'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seat_number': seatNumber,
      'fare': fare,
      'title': title,
      'name': name,
      'age': age,
      'sex': sex,
      'is_primary': isPrimary,
      'id_card_type': idCardType,
      'id_card_number': idCardNumber,
      'id_card_issued_by': idCardIssuedBy,
      '_id': id,
    };
  }
}

class ContactDetail {
  final String? mobileNumber;
  final String? emergencyName;
  final String? email;
  final String? id;

  ContactDetail({this.mobileNumber, this.emergencyName, this.email, this.id});

  factory ContactDetail.fromJson(Map<String, dynamic> json) {
    return ContactDetail(
      mobileNumber: json['mobile_number'],
      emergencyName: json['emergency_name'],
      email: json['email'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobile_number': mobileNumber,
      'emergency_name': emergencyName,
      'email': email,
      '_id': id,
    };
  }
}

class CustomerCompanyGst {
  final String? name;
  final String? gstId;
  final String? address;
  final String? id;

  CustomerCompanyGst({this.name, this.gstId, this.address, this.id});

  factory CustomerCompanyGst.fromJson(Map<String, dynamic> json) {
    return CustomerCompanyGst(
      name: json['name'],
      gstId: json['gst_id'],
      address: json['address'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gst_id': gstId,
      'address': address,
      '_id': id,
    };
  }
}
