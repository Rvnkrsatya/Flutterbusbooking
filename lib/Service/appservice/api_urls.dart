

class ApiUrls {
  static const String baseUrl = "https://apis.yesgobus.com/api/";
  // static const String baseUrl = "https://test.yesgobus.com/api/";  //testing
  // static const String baseUrl ="https://1fa37e437c21.ngrok-free.app/api/";
  static String searchCity(String query) =>
      "${baseUrl}busBooking/searchCity/$query";

  // static String updateProfile(String Id) =>
  //     "${baseUrl}user/updateProfile/$Id";
  //
  // static String deleteProfile(String Id) =>
  //     "${baseUrl}user/$Id";
  static const String updateProfile = "https://apis.yesgobus.com/api/user/updateProfile";
  static const String deleteProfile = "https://apis.yesgobus.com/api/user";
  // Auth Endpoints
  static const String signIn = "${baseUrl}user/signin";
  static const String verifyOtp = "${baseUrl}user/verify_login_otp";
  static const String googleSignIn = "${baseUrl}user/googleSignIn";
  static String logout(String userId) => '$baseUrl/logout?userId=$userId';
  // (Optional) Placeholder for unused or upcoming endpoints
  static const String signUp = "${baseUrl}user/signup";
  static const String verifyOtpsign = '${baseUrl}user/verify_signup_otp';
  static const String getQueries = "${baseUrl}query/getQueries";
  static const String createQuery = "${baseUrl}query/createQuery";
  // static const String vrlbusdetails = "busBooking/getVrlBusDetails";
  static const String getbookingbyid = "busBooking/getBookingById";

  static const String getVrlSeatLayout = "busBooking/sendVrlRequest/GetSeatArrangementDetailsV3";
  static const String getSrsSeatLayout = "busBooking/getSrsSeatDetails/";
  static const String vrlblockseat = "busBooking/sendVrlRequest/BlockSeatV2";
  static const String vrlbookseat = "busBooking/bookBus";
  static const String srsblockseat = "busBooking/getSrsBlockSeat";
  static const String srsbookseat = "busBooking/bookBus";
  static const String getkey = "getkey";
  static const String checkout = "payment/v2/checkout";
  static const String verificationApiUrl = "https://apis.yesgobus.com/api/payment/v2/paymentverification";
  // static const String getbookingbyid = "busBooking/getBookingById";
  static const String checkagent = "agent/isAgent";
  static const String agentbusbooking = "agent/busbooking";
  static const String srsFiltersV3 =  "busBooking/getSrsFiltersV3";
  static const String srsFiltersV2 =  "busBooking/getSrsFiltersV2";

  static const String srsSchedulesV2 = "busBooking/getSrsSchedulesV2";
  static const String vrlbusdetailsV2 = "busBooking/getVrlBusDetailsV2";
  static const String vrlbusdetailsv3 = "busBooking/getVrlBusDetailsV3";

  static const String srsbusdetailsv3 = "busBooking/getSrsSchedulesV3";

}

















// class ApiUrl {
//   /// base url
//   static const String baseUrl = "https://apis.yesgobus.com/api/"; //live
//   //static const String baseUrl = "https://dev.yesgobus.co.in/api/";  //testing
//   static const String loginUrl = "user/login"; // not used
//   static const String signupUrl = "user/signup"; // not used
//   static const String packageUrl = "package/packages"; // done
//   static const String getDestinationUrl = "package/get_destinations"; //done
//   static const String getindiaDestinationUrl = "destination/country?country=India"; //done
//   static const String getinternationalDestinationUrl = "destination/international"; //done
//   static const String itenaryPlansUrl = "booking/itinerary_plans"; // done
//   static const String preBookingApiUrl = "booking/book_hotel"; // done
//   //static const String bookingUpdateApiUrl = "booking/update_booking"; //done
//   static const String bookingUpdateApiUrl = "packageBooking"; //done
//   static const String promocodeApiUrl = "coupon/apply_coupon_code"; // under Checking
//   static const String addToWishlistUrl = "package/add_to_wishlist"; // done
//   static const String getWishlistUrl = "package/get_user_wishlist";
//   static const String customerReviewUrl = "feedback/get_feedback"; //done
//   static const String addReviewUrl = "feedback/add_feedback";
//   static const String todaysOffersUrl = "offers/get_offers"; // done
//   static const String addBookingQueryUrl = "booking/add_booking_query";
//   static const String myTripUrl = "booking/get_user_booking";
//   static const String getbookingbyid = "busBooking/getBookingById";
//   static const String deleteAccountUrl = "user/delete_account";
//
//   static const String checkoutApiUrl = "payment/v2/checkout";
//   static const String verificationApiUrl = "https://apis.yesgobus.com/api/payment/v2/paymentverification";
//   static const String verificationApiUrl_tt = "https://apis.yesgobus.com/api/payment/v2/travel/verify";
//   static const String getbookingbyidApiUrl = "busBooking/getBookingById/";
//   static const String checkoutApiUrl_tt = "payment/v2/travel/checkout";
//   static const String sendemailApiUrl = "booking/query";
//
//
// }
//
//
//
// // class ApiUrl {
// //   /// base url
// //   static const String baseUrl = "https://apis.yesgobus.com/api/"; //live
// //   //static const String baseUrl = "https://dev.yesgobus.co.in/api/";  //testing
// //   static const String loginUrl = "user/login"; // not used
// //   static const String signupUrl = "user/signup"; // not used
// //   static const String packageUrl = "package/packages"; // done
// //   static const String getDestinationUrl = "package/get_destinations"; //done
// //   static const String itenaryPlansUrl = "booking/itinerary_plans"; // done
// //   static const String preBookingApiUrl = "booking/book_hotel"; // done
// //   static const String bookingUpdateApiUrl = "booking/update_booking"; //done
// //   static const String promocodeApiUrl = "coupon/apply_coupon_code"; // under Checking
// //   static const String addToWishlistUrl = "package/add_to_wishlist"; // done
// //   static const String getWishlistUrl = "package/get_user_wishlist";
// //   static const String customerReviewUrl = "feedback/get_feedback"; //done
// //   static const String addReviewUrl = "feedback/add_feedback";
// //   static const String todaysOffersUrl = "offers/get_offers"; // done
// //   static const String addBookingQueryUrl = "booking/add_booking_query";
// //   static const String myTripUrl = "booking/get_user_booking";
// //   static const String getbookingbyid = "busBooking/getBookingById";
// //   static const String deleteAccountUrl = "user/delete_account";
// //   static const String checkoutApiUrl = "payment/v2/checkout";
// //   static const String verificationApiUrl = "https://apis.yesgobus.com/api/payment/v2/paymentverification";
// //   //static const String verificationApiUrl = "https://dev.yesgobus.co.in/api/payment/v2/paymentverification";
// //   static const String getbookingbyidApiUrl = "busBooking/getBookingById/";
// //
// // }
