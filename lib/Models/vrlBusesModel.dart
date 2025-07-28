import 'dart:convert';
import 'dart:developer';

class vrlBusesModel {
  final int companyID;
  final String companyName;
  final int fromCityId;
  final String fromCityName;
  final int toCityId;
  final String toCityName;
  final int routeID;
  final int routeTimeID;
  final String routeName;
  final String routeTime;
  final int kilometer;
  final String cityTime;
  final String arrivalTime;
  final int busType;
  final String busTypeName;
  final String bookingDate;
  final int arrangementID;
  final String arrangementName;
  final double acSeatRate;
  final double acSleeperRate;
  final double acSlumberRate;
  final double nonAcSeatRate;
  final double nonAcSleeperRate;
  final double nonAcSlumberRate;
  final String boardingPoints;
  final String droppingPoints;
  final int emptySeats;
  final String referenceNumber;
  final double acSeatServiceTax;
  final double acSlpServiceTax;
  final double acSlmbServiceTax;
  final double nonAcSeatServiceTax;
  final double nonAcSlpServiceTax;
  final double nonAcSlmbServiceTax;
  final double acSeatSurcharges;
  final double acSlpSurcharges;
  final double acSlmbSurcharges;
  final double nonAcSeatSurcharges;
  final double nonAcSlpSurcharges;
  final double nonAcSlmbSurcharges;
  final String approxArrival;
  final int isApiCommission;
  final String cityTime24;
  final int busSeatType;
  final int discountType;
  final double discountRate;
  final int allowReSchedule;
  final double reScheduleCharge;
  final int stopReScheduleMinutes;
  final int reScheduleChargeType;
  final int isSocialDistanceMaintain;
  final int socialDistanceType;
  final int isSameDay;
  final int routeCategory;
  final int advanceBookingDays;
  final String serviceStartDate;
  final String serviceEndDate;
  final String routeAmenities;
  final double gstOnRescheduleCharge;
  final String type;
  final double lowestPrice;
  final List<int> allPrices;

  vrlBusesModel({
    required this.companyID,
    required this.companyName,
    required this.fromCityId,
    required this.fromCityName,
    required this.toCityId,
    required this.toCityName,
    required this.routeID,
    required this.routeTimeID,
    required this.routeName,
    required this.routeTime,
    required this.kilometer,
    required this.cityTime,
    required this.arrivalTime,
    required this.busType,
    required this.busTypeName,
    required this.bookingDate,
    required this.arrangementID,
    required this.arrangementName,
    required this.acSeatRate,
    required this.acSleeperRate,
    required this.acSlumberRate,
    required this.nonAcSeatRate,
    required this.nonAcSleeperRate,
    required this.nonAcSlumberRate,
    required this.boardingPoints,
    required this.droppingPoints,
    required this.emptySeats,
    required this.referenceNumber,
    required this.acSeatServiceTax,
    required this.acSlpServiceTax,
    required this.acSlmbServiceTax,
    required this.nonAcSeatServiceTax,
    required this.nonAcSlpServiceTax,
    required this.nonAcSlmbServiceTax,
    required this.acSeatSurcharges,
    required this.acSlpSurcharges,
    required this.acSlmbSurcharges,
    required this.nonAcSeatSurcharges,
    required this.nonAcSlpSurcharges,
    required this.nonAcSlmbSurcharges,
    required this.approxArrival,
    required this.isApiCommission,
    required this.cityTime24,
    required this.busSeatType,
    required this.discountType,
    required this.discountRate,
    required this.allowReSchedule,
    required this.reScheduleCharge,
    required this.stopReScheduleMinutes,
    required this.reScheduleChargeType,
    required this.isSocialDistanceMaintain,
    required this.socialDistanceType,
    required this.isSameDay,
    required this.routeCategory,
    required this.advanceBookingDays,
    required this.serviceStartDate,
    required this.serviceEndDate,
    required this.routeAmenities,
    required this.gstOnRescheduleCharge,
    required this.type,
    required this.lowestPrice,
    required this.allPrices,
  });

  factory vrlBusesModel.fromJson(Map<String, dynamic> json) {
    try {
      return vrlBusesModel(
        companyID: json['CompanyID'] ?? 0,
        companyName: json['CompanyName'] ?? '',
        fromCityId: json['FromCityId'] ?? 0,
        fromCityName: json['FromCityName'] ?? '',
        toCityId: json['ToCityId'] ?? 0,
        toCityName: json['ToCityName'] ?? '',
        routeID: json['RouteID'] ?? 0,
        routeTimeID: json['RouteTimeID'] ?? 0,
        routeName: json['RouteName'] ?? '',
        routeTime: json['RouteTime'] ?? '',
        kilometer: json['Kilometer'] ?? 0,
        cityTime: json['CityTime'] ?? '',
        arrivalTime: json['ArrivalTime'] ?? '',
        busType: json['BusType'] ?? 0,
        busTypeName: json['BusTypeName'] ?? '',
        bookingDate: json['BookingDate'] ?? '',
        arrangementID: json['ArrangementID'] ?? 0,
        arrangementName: json['ArrangementName'] ?? '',
        acSeatRate: (json['AcSeatRate'] as num?)?.toDouble() ?? 0.0,
        acSleeperRate: (json['AcSleeperRate'] as num?)?.toDouble() ?? 0.0,
        acSlumberRate: (json['AcSlumberRate'] as num?)?.toDouble() ?? 0.0,
        nonAcSeatRate: (json['NonAcSeatRate'] as num?)?.toDouble() ?? 0.0,
        nonAcSleeperRate: (json['NonAcSleeperRate'] as num?)?.toDouble() ?? 0.0,
        nonAcSlumberRate: (json['NonAcSlumberRate'] as num?)?.toDouble() ?? 0.0,
        boardingPoints: json['BoardingPoints'] ?? '',
        droppingPoints: json['DroppingPoints'] ?? '',
        emptySeats: json['EmptySeats'] ?? 0,
        referenceNumber: json['ReferenceNumber'] ?? '',
        acSeatServiceTax: (json['AcSeatServiceTax'] as num?)?.toDouble() ?? 0.0,
        acSlpServiceTax: (json['AcSlpServiceTax'] as num?)?.toDouble() ?? 0.0,
        acSlmbServiceTax: (json['AcSlmbServiceTax'] as num?)?.toDouble() ?? 0.0,
        nonAcSeatServiceTax: (json['NonAcSeatServiceTax'] as num?)?.toDouble() ?? 0.0,
        nonAcSlpServiceTax: (json['NonAcSlpServiceTax'] as num?)?.toDouble() ?? 0.0,
        nonAcSlmbServiceTax: (json['NonAcSlmbServiceTax'] as num?)?.toDouble() ?? 0.0,
        acSeatSurcharges: (json['AcSeatSurcharges'] as num?)?.toDouble() ?? 0.0,
        acSlpSurcharges: (json['AcSlpSurcharges'] as num?)?.toDouble() ?? 0.0,
        acSlmbSurcharges: (json['AcSlmbSurcharges'] as num?)?.toDouble() ?? 0.0,
        nonAcSeatSurcharges: (json['NonAcSeatSurcharges'] as num?)?.toDouble() ?? 0.0,
        nonAcSlpSurcharges: (json['NonAcSlpSurcharges'] as num?)?.toDouble() ?? 0.0,
        nonAcSlmbSurcharges: (json['NonAcSlmbSurcharges'] as num?)?.toDouble() ?? 0.0,
        approxArrival: json['ApproxArrival'] ?? '',
        isApiCommission: json['IsAPICommission'] ?? 0,
        cityTime24: json['CityTime24'] ?? '',
        busSeatType: json['BusSeatType'] ?? 0,
        discountType: json['DiscountType'] ?? 0,
        discountRate: (json['DiscountRate'] as num?)?.toDouble() ?? 0.0,
        allowReSchedule: json['AllowReSchedule'] ?? 0,
        reScheduleCharge: (json['ReScheduleCharge'] as num?)?.toDouble() ?? 0.0,
        stopReScheduleMinutes: json['StopReScheduleMinutes'] ?? 0,
        reScheduleChargeType: json['ReScheduleChargeType'] ?? 0,
        isSocialDistanceMaintain: json['IsSocialDistanceMaintain'] ?? 0,
        socialDistanceType: json['SocialDistanceType'] ?? 0,
        isSameDay: json['IsSameDay'] ?? 0,
        routeCategory: json['RouteCategory'] ?? 0,
        advanceBookingDays: json['AdvanceBookingDays'] ?? 0,
        serviceStartDate: json['ServiceStartDate'] ?? '',
        serviceEndDate: json['ServiceEndDate'] ?? '',
        routeAmenities: json['RouteAmenities'] ?? '',
        gstOnRescheduleCharge: (json['GSTONRescheduleCharge'] as num?)?.toDouble() ?? 0.0,
        type: json['type'] ?? '',
        lowestPrice: (json['lowestPrice'] as num?)?.toDouble() ?? 0.0,
        allPrices: (json['allPrices'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ?? [],

      );
    } catch (e) {
      log("vrlBusesModel parsing error: $e");
      log("Offending JSON: $json");
      rethrow;
    }
  }
}
