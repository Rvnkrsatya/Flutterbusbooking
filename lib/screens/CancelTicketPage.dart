import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/appservice/apibase.dart';
import '../Service/appservice/api_urls.dart';

class CancelTicketPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const CancelTicketPage({super.key, required this.bookingData});

  @override
  State<CancelTicketPage> createState() => _CancelTicketPageState();
}

class _CancelTicketPageState extends State<CancelTicketPage> {
  bool _loading = false;
  String token = "";

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  Future<void> cancelTicket() async {
    setState(() => _loading = true);

    try {
      final booking = widget.bookingData;

      // Step 1: Check if user is agent
      final agentRes = await ApiBase.getRequest(
        extendedURL: "agent/isAgent/${booking['userId']}",
        withToken: true,
      );
      final isAgent = jsonDecode(agentRes.body)["isAgent"] ?? false;

      // Step 2: Prepare request body for unified API
      final cancelBody = {
        "bookingId": booking["_id"],
        "blockId": booking["blockKey"],
        "userId": booking["userId"],
        "amount": booking["totalAmount"].toString(),
        "ticket_number": booking["opPNR"] ?? booking["tid"] ?? "",
        "seat_numbers": booking["selectedSeats"],
        "isagent": isAgent.toString(),
        "isVrl": booking["isVrl"] ?? false,
        "isSrs": booking["isSrs"] ?? false,
      };

      final apiUrl =
          "${ApiUrls.baseUrl}busBooking/cancelBusBooking";

      // Step 3: Logging
      log("🔵 [API CALL] POST → $apiUrl");
      log("📦 Request Body: ${jsonEncode(cancelBody)}");

      // Step 4: Hit new API
      final cancelRes = await ApiBase.postRequest(
        extendedURL: "busBooking/cancelBusBooking",
        body: cancelBody,
        withToken: true,
      );

      log("🟢 Response Status Code: ${cancelRes.statusCode}");
      log("🟢 Raw Response Body: ${cancelRes.body}");

      final response = jsonDecode(cancelRes.body);

      if (response["status"] != 200) {
        throw response["message"] ?? "Cancellation failed";
      }

      Fluttertoast.showToast(
          msg: response["message"] ?? "Booking cancelled successfully");
      Navigator.pop(context, true);

    } catch (e) {
      log("❌ Error: $e");
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cancel Ticket")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: cancelTicket,
          child: const Text("Confirm Cancellation"),
        ),
      ),
    );
  }
}
