import 'dart:developer';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_application_yesgobus/Models/VrlBlockSeat_model.dart';
import 'package:flutter_application_yesgobus/Models/SrsBlockSeat_model.dart';
import 'package:flutter_application_yesgobus/Models/SrsBookBusmodel.dart';
import 'package:flutter_application_yesgobus/Models/Checkoutmodel.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../Service/appservice/api_urls.dart';
import '../Service/appservice/apibase.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../screens/PaymentStatusScreen.dart';

class PassengerInfoScreen extends StatefulWidget {
  final String boardingId;
  final String droppingId;
  final String boardingpoint;
  final String droppingpoint;
  final String boardingContact;
  final String droppingContact;

  const PassengerInfoScreen({
    super.key,
    required this.boardingId,
    required this.droppingId,
    required this.boardingpoint,
    required this.droppingpoint,
    required this.boardingContact,
    required this.droppingContact,
  });

  @override
  State<PassengerInfoScreen> createState() => _PassengerInfoScreenState();
}

class _PassengerInfoScreenState extends State<PassengerInfoScreen> {
  String from_city = "", to_city = "", dep = "", arr = "", operator = "", busType = "", type = '';
  String seats = "";
  String journeyDate = "";
  int seatCount = 0;
  int totalPrice = 0;
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  late Razorpay _razorpay;

  List<TextEditingController> firstNameControllers = [];
  List<TextEditingController> lastNameControllers = [];
  List<TextEditingController> ageControllers = [];
  List<String> genderSelections = [];

  List<String> selectedSeats = [];
  List<String> selectedSeatsfare = [];
  List<Map<String, String>> passengerInfoList = [];
  List<String> seatTaxes = [];
  List<String> seatTotalFares = [];
  String email = '';
  String phone = '';
  String referenceNumber_vrl =  '';
  String id_srs =  '';
  String origin_id_srs = '';
  String destination_id_srs = '';
  String user_token = '';
  String user_id = '';
  String Razorpay_Key = '';
  String pnr_number = '';
  String bookingId = '';
  String currency = '';
  String orderId = '';

  @override
  void initState() {
    super.initState();
    _loadJourneyDetails();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _loadJourneyDetails() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      from_city = prefs.getString('fromCity') ?? '';
      to_city = prefs.getString('toCity') ?? '';
      dep = prefs.getString('departureTime') ?? '';
      arr = prefs.getString('arrivalTime') ?? '';
      operator = prefs.getString('operatorName') ?? '';
      busType = prefs.getString('busType') ?? '';
      type = prefs.getString('type') ?? '';
      seats = prefs.getString('selectedSeats') ?? '';
      seatCount = prefs.getInt('seatCount') ?? 0;
      totalPrice = prefs.getInt('totalPrice') ?? 0;

      final dateStr = prefs.getString('selectedDate') ?? '';
      if (dateStr.isNotEmpty) {
        try {
          final date = DateFormat('dd/MM/yyyy').parse(dateStr);
          //journeyDate = DateFormat('dd/MM/yyyy').format(date);
          journeyDate = DateFormat('yyyy-MM-dd').format(date);
        } catch (_) {
          journeyDate = dateStr;
        }
      }

      emailController.text = prefs.getString('user_email') ?? '';
      phoneController.text = prefs.getString('user_phone') ?? '';
      user_token = prefs.getString('token') ?? '';
      user_id = prefs.getString('_id') ?? '';

      print("usertoken : $user_token");
      print("userid : $user_id");

      firstNameControllers = List.generate(seatCount, (_) => TextEditingController());
      lastNameControllers = List.generate(seatCount, (_) => TextEditingController());
      ageControllers = List.generate(seatCount, (_) => TextEditingController());
      genderSelections = List.generate(seatCount, (_) => '');

      selectedSeats = (prefs.getString('selectedSeats') ?? '').split(',').map((e) => e.trim()).toList();
      selectedSeatsfare = (prefs.getString('seatPrices') ?? '').split(',').map((e) => e.trim()).toList();
      seatTaxes = List<String>.from(jsonDecode(prefs.getString('seatTaxes') ?? '[]'));
      seatTotalFares = List<String>.from(jsonDecode(prefs.getString('seatTotalFares') ?? '[]'));

      email = emailController.text;
      phone = phoneController.text;
      referenceNumber_vrl = prefs.getString('referenceNumber') ?? referenceNumber_vrl;
      id_srs = prefs.getString('id_srs') ?? id_srs;
      origin_id_srs = prefs.getString('origin_id_srs') ?? origin_id_srs;
      destination_id_srs = prefs.getString('destination_id_srs') ?? destination_id_srs;

      passengerInfoList = List.generate(seatCount, (index) {
        return {
          "firstName": firstNameControllers[index].text,
          "lastName": lastNameControllers[index].text,
          "age": ageControllers[index].text,
          "gender": genderSelections[index] == "Male" ? "M" : "F",
        };
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = const Color(0xFF033564);
    final lightBlue = const Color(0xFF14bde3);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Passenger Information"),
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCardWithBorder(
              title: "Journey Details",
              icon: Icons.directions_bus_filled,
              borderColor: darkBlue,
              child: _buildJourneyDetailsCard(darkBlue),
            ),
            const SizedBox(height: 16),
            _buildCardWithBorder(
              title: "Contact Details",
              icon: Icons.contact_mail,
              borderColor: darkBlue,
              child: _buildContactDetailsCard(darkBlue),
            ),
            const SizedBox(height: 16),
            _buildCardWithBorder(
              title: "Add Passenger",
              icon: Icons.person,
              borderColor: darkBlue,
              child: _buildPassengerCard(darkBlue),
            ),
            const SizedBox(height: 16),
            _buildCardWithBorder(
              title: "Offer Code",
              icon: Icons.local_offer,
              borderColor: darkBlue,
              child: _buildOfferCodeCard(lightBlue),
            ),
            const SizedBox(height: 16),
            _buildCardWithBorder(
              title: "Fare Summary",
              icon: Icons.receipt_long,
              borderColor: darkBlue,
              child: _buildPriceCard(darkBlue, lightBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWithBorder({
    required String title,
    required IconData icon,
    required Color borderColor,
    required Widget child,
  }) {
    final lightBorderBlue = const Color(0xFFB3CDE8);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: lightBorderBlue, width: 1.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Icon(icon, color: borderColor),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: borderColor)),
              ],
            ),
            const Divider(height: 20),
            child,
          ]),
        ),
      ),
    );
  }

  Widget _buildJourneyDetailsCard(Color darkBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Journey Date: $journeyDate", style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("From: $from_city", style: TextStyle(fontSize: 16, color: darkBlue)),
              Text(dep, style: TextStyle(color: Colors.grey[700])),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text("To: $to_city", style: TextStyle(fontSize: 16, color: darkBlue)),
              Text(arr, style: TextStyle(color: Colors.grey[700])),
            ]),
          ],
        ),
        const Divider(height: 20),
        Text("Bus: $operator", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkBlue)),
        Text(busType, style: TextStyle(color: Colors.grey[700])),
        const SizedBox(height: 8),
        Text("Seats: $seats", style: TextStyle(color: darkBlue)),
      ],
    );
  }

  Widget _buildContactDetailsCard(Color darkBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your ticket and bus details will be sent here."),
        const SizedBox(height: 12),

        // ✅ Email Field
        SizedBox(
          height: 44,
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: "Enter email",
              prefixIcon: Icon(Icons.email, color: darkBlue),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ),

        const SizedBox(height: 12),

        // ✅ Phone Field
        SizedBox(
          height: 44,
          child: TextField(
            controller: phoneController,
            decoration: InputDecoration(
              hintText: "Enter mobile number",
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(Icons.phone, color: darkBlue),
              ),
              prefixText: "+91 ",
              prefixStyle: const TextStyle(fontSize: 16, color: Colors.black87),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            keyboardType: TextInputType.phone,
          ),
        ),
      ],
    );
  }



  Widget _buildPassengerCard(Color darkBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(seatCount, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Passenger ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue)),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: TextField(
                controller: firstNameControllers[index],
                decoration: InputDecoration(
                  labelText: "First Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: TextField(
                controller: lastNameControllers[index],
                decoration: InputDecoration(
                  labelText: "Last Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: ageControllers[index],
                      decoration: InputDecoration(
                        labelText: "Age",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: DropdownButtonFormField<String>(
                      value: genderSelections[index].isNotEmpty ? genderSelections[index] : null,
                      icon: const Icon(Icons.arrow_drop_down),
                      decoration: InputDecoration(
                        labelText: "Gender",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: TextStyle(color: darkBlue),
                      dropdownColor: Colors.white,
                      items: const [
                        DropdownMenuItem(
                          value: "Male",
                          child: Row(children: [Icon(Icons.male, color: Colors.blue), SizedBox(width: 8), Text("Male")]),
                        ),
                        DropdownMenuItem(
                          value: "Female",
                          child: Row(children: [Icon(Icons.female, color: Colors.pink), SizedBox(width: 8), Text("Female")]),
                        ),
                        DropdownMenuItem(
                          value: "Other",
                          child: Row(children: [Icon(Icons.transgender, color: Colors.purple), SizedBox(width: 8), Text("Other")]),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          genderSelections[index] = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }


  Widget _buildOfferCodeCard(Color lightBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Apply Offer Code", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Enter offer code",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: lightBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {},
              child: const Text("Verify"),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildPriceCard(Color darkBlue, Color lightBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Total Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkBlue)),
        const SizedBox(height: 4),
        Text("₹ $totalPrice", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightBlue)),
        const SizedBox(height: 8),
        TextButton(onPressed: () {}, child: const Text("Show Fare Breakdown")),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            print("bustype : $type");
            if (type == "vrl") {
              await blockVrlSeats();
            } else {
              await blockSrsSeats();
            }
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: darkBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text("Pay ₹$totalPrice"),
        ),
      ],
    );
  }


  Future<VrlBlockSeatResponse?> blockVrlSeats() async {
    try {
      final passengerCount = selectedSeats.length;

      // ✅ Use user input for email, phone
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();

      // ✅ Get Passenger 1 full name
      final passengerName = "${firstNameControllers[0].text.trim()} ${lastNameControllers[0].text.trim()}";

      // ✅ Build seatNames string as: "A1,M|A2,F"
      final seatWithGender = List.generate(
        passengerCount,
            (i) => '${selectedSeats[i]},${genderSelections[i] == "Male" ? "M" : "F"}',
      ).join('|');

      final response = await ApiBase.postRequest(
        extendedURL: ApiUrls.vrlblockseat,
        body: {
          "referenceNumber": referenceNumber_vrl,
          "passengerName": passengerName,
          "seatNames": seatWithGender,
          "email": email,
          "phone": phone,
          "pickupID": int.tryParse(widget.boardingId) ?? 0,
          "payableAmount": totalPrice,
          "totalPassengers": passengerCount,
        },
        withToken: true,
      );

      // ✅ Handle API response
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final parsedResponse = VrlBlockSeatApiResponse.fromJson(json);

        if (parsedResponse.data.isNotEmpty && parsedResponse.data.first.status == 1) {
          return parsedResponse.data.first;
        } else {
          print("Seat block failed: ${parsedResponse.data.first.message}");
          return null;
        }
      } else {
        print("API call failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("BlockSeat error: $e");
      return null;
    }
  }

  Future<void> blockSrsSeats() async {
    try {
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();

      print("📥 email: $email");
      print("📥 phone: $phone");
      print("📥 selectedSeats: $selectedSeats");
      print("📥 seatFares: $selectedSeatsfare");
      print("📥 seatCount: $seatCount");
      print("📥 firstNameControllers: ${firstNameControllers.length}");
      print("📥 lastNameControllers: ${lastNameControllers.length}");
      print("📥 ageControllers: ${ageControllers.length}");
      print("📥 genderSelections: $genderSelections");
      print("📥 journeyDate: $journeyDate");
      final seatDetailList = List.generate(seatCount, (index) {
        final title = genderSelections[index] == "Female" ? "Ms" : "Mr";
        return {
          "seat_number": selectedSeats[index],
          //"fare": seatFares[index],
          "fare": selectedSeatsfare[index],
          "title": title,
          "name": "${firstNameControllers[index].text} ${lastNameControllers[index].text}",
          "age": ageControllers[index].text,
          "sex": genderSelections[index] == "Male" ? "M" : "F",
          "is_primary": index == 0 ? "true" : "false",
          "id_card_type": "1",
          "id_card_number": "111111111",
          "id_card_issued_by": "oneone"
        };
      });

      if (firstNameControllers.isEmpty) {
        print("❌ ERROR: firstNameControllers is empty!");
      }


      final srsBlockSeatBody = {
        "book_ticket": {
          "seat_details": {
            "seat_detail": seatDetailList,
          },
          "contact_detail": {
            "mobile_number": phone,
            "emergency_name": firstNameControllers.isNotEmpty ? firstNameControllers[0].text : '',
            "email": email,
          }
        },
        "origin_id": origin_id_srs, // You can pass dynamically if needed
        "destination_id": destination_id_srs, // You can pass dynamically if needed
        "boarding_at": widget.boardingId,
        "drop_of": widget.droppingId,
        "no_of_seats": seatCount.toString(),
        "travel_date": journeyDate, // Make sure this is in correct format
        "customer_company_gst": {
          "name": "Yesgobus",
          "gst_id": "T123DT",
          "address": "Test"
        }
      };

      print("🔗 API URL: ${ApiUrls.srsblockseat}/$id_srs");

      final response = await ApiBase.postRequest(
        extendedURL: '${ApiUrls.srsblockseat}/$id_srs', // Add this to your ApiUrls
        body: srsBlockSeatBody,
        withToken: true,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print("SRS block seat response: $json");

        //pnr_number = json['result']['ticket_details']['pnr_number'];
        final blockSeatRes = SrsBlockSeatResponse.fromJson(json);
        pnr_number = blockSeatRes.ticketDetails.pnrNumber;
        print("✅ Extracted PNR: $pnr_number");

        if (pnr_number != null) {
          print("Extracted PNR: $pnr_number");
          bookSrsTicket(pnr_number); // Pass PNR to booking function
        } else {
          print("PNR not found in response");
        }
        // You can check `status`, `message`, etc. based on the API response here
      } else {
        print("SRS block seat failed: ${response.statusCode}");
      }
    } catch (e) {
      print("SRS block seat error: $e");
    }
  }

  Future<void> bookSrsTicket(String pnrNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final email = emailController.text.trim();
      final phone = phoneController.text.trim();

      // Build seat details list
      final seatDetailList = List.generate(selectedSeats.length, (index) {
        final title = genderSelections[index] == "Female" ? "Ms" : "Mr";
        return {
          "seat_number": selectedSeats[index],
          "fare": selectedSeatsfare[index],
          "title": title,
          "name":
          "${firstNameControllers[index].text} ${lastNameControllers[index].text}",
          "age": ageControllers[index].text,
          "sex": genderSelections[index] == "Male" ? "M" : "F",
          "is_primary": index == 0 ? "true" : "false",
          "id_card_type": "1",
          "id_card_number": "111111111",
          "id_card_issued_by": "oneone"
        };
      });

      final bookBusBody = {
        "srsBlockSeatDetails": {
          "book_ticket": {
            "seat_details": {
              "seat_detail": seatDetailList,
            },
            "contact_detail": {
              "mobile_number": phone,
              "emergency_name": firstNameControllers[0].text,
              "email": email,
            }
          },
          "origin_id": origin_id_srs,
          "destination_id": destination_id_srs,
          "boarding_at": widget.boardingId,
          "drop_of": widget.droppingId,
          "no_of_seats": selectedSeats.length.toString(),
          "travel_date": journeyDate,
          "customer_company_gst": {
            "name": "Yesgobus",
            "gst_id": "T123DT",
            "address": "Test"
          }
        },
        "blockKey": pnrNumber,
        "userId": user_id,
        "totalAmount": totalPrice.toString(),
        "busOperator": operator,
        "busType": busType, // define it or get from previous screen
        "selectedSeats": selectedSeats.join(", "),
        "pickUpTime": dep,     // get this from seat page or api
        "reachTime": arr,       // same
        "cancellationPolicy": "",
        "sourceCity": from_city,
        "destinationCity": to_city,
        "doj": journeyDate,
        "customerName": firstNameControllers[0].text,
        "customerLastName": lastNameControllers[0].text,
        "customerEmail": email,
        "customerPhone": phone,
        "customerAddress": "123 Street, Bangalore",
        "isSrs": true,
        "boardingPoint": widget.boardingpoint,
        "droppingPoint": widget.droppingpoint,
        "driverNumber": widget.boardingContact,
        "agentCode": ""
      };

      print("📦 Booking Body: ${jsonEncode(bookBusBody)}");

      final response = await ApiBase.postRequest(
        extendedURL: ApiUrls.srsbookseat, // Your book bus endpoint
        body: bookBusBody,
        withToken: true,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print("✅ SRS BOOK BUS SUCCESS: $json");
        final bookingRes = SrsBookBusResponse.fromJson(json);
        bookingId = bookingRes.data!.id!; // "_id" from your model
        getkey();
      } else {
        print("❌ Book Bus Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Book Bus Exception: $e");
    }
  }


  Future<void> getkey() async {
    final url = ApiUrls.getkey;
    debugPrint("🟡 getkey - $url");

    final response = await ApiBase.getRequest(extendedURL: url, withToken: true);

    debugPrint("🟠 getkey Response Status: ${response.statusCode}");
    debugPrint("🟠 getkey Response Body: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data != null && data['key'] != null) {
        Razorpay_Key = data['key'];
        debugPrint("✅ Razorpay Key: $Razorpay_Key");
        checkoutApi(context, totalPrice, bookingId!, pnr_number, user_id);
      } else {
        debugPrint("❌ 'key' not found in response.");
      }
    }
  }

  Future checkoutApi(context, int amount, String bookingId, String blockId,String Id) async {
    var body = {
      "amount": amount,
      "bookingId": bookingId,
      "blockId": blockId,
      "Id" :Id
    };
    var response = await ApiBase.postRequest(
        body: body, extendedURL: ApiUrls.checkout, withToken: true);
    log(response.body);
    var data = json.decode(response.body);
    if (data["success"] == true) {
      print("status true");
      CheckoutResponse checkoutmodel = CheckoutResponse.fromJson(data);
      if (checkoutmodel.order != null) {
        int amount = checkoutmodel.order.amount ?? 0;  // Fetch amount
        orderId = checkoutmodel.order.id ?? ""; // Fetch order ID
        currency = checkoutmodel.order.currency ?? "INR"; // Fetch currency

        print("Amount: $amount");
        print("Order ID: $orderId");
        print("Currency: $currency");

        _openCheckout(amount); // Call payment gateway
      } else {
        print("Checkout data is null");
      }

    } else {
      Get.back();
      print("Error $data['message']");
      return "";
    }
  }

  void _openCheckout(int amount) {
    var options = {
      'key': Razorpay_Key,
      'amount': amount,
      'name': 'Yes Go Bus',
      'description': 'Busbooking',
      'currency': "INR",
      'order_id': orderId,
      'prefill': {
        'name': "SHINE GO BUS PVT.LTD",
        'email': "support@yesgobus.com",
        'contact': "9964376733"
      },
      'notes': {
        "address": "Vijaypura Karnataka"
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }


  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Inside _handlePaymentSuccess");

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Successful: ${response.paymentId}"))
    );
    print("Payment Successful: ${response.paymentId}");
    print("Payment Successful: ${response.orderId}");
    print("Payment Successful: ${response.signature}");
    print("Payment Successful: ${user_token}");
    dio.Dio dioClient = dio.Dio(); // Use "dio.Dio" instead of "Dio"

    try {
      dio.Response verifyResponse = await dioClient.post( // Use "dio.Response"
        ApiUrls.verificationApiUrl,
        data: {
          "razorpay_payment_id": response.paymentId,
          "razorpay_order_id": response.orderId,
          "razorpay_signature": response.signature,
        },
        options: dio.Options(headers: {"Authorization": "Bearer $user_token"}),
      );
      print(ApiUrls.verificationApiUrl);

      if (verifyResponse.data["success"]) {
        print("Payment Verified");

        try {
          Get.to(PaymentStatusScreen(bookingId: bookingId));
        } catch (e) {
          Get.snackbar('Error', 'Payment ID is null');
        }
      } else {
        print("Payment Verification Failed");
      }
    } catch (e) {
      print("Error in dio block: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed:"))
    );
    print("Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("External Wallet Selected: ${response.walletName}"))
    );
    print("Payment Failed: ${response.walletName}");
  }



}
