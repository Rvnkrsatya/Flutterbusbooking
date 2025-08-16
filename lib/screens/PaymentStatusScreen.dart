import 'package:flutter/material.dart';
import 'package:flutter_application_yesgobus/Service/appservice/apibase.dart';
import 'package:flutter_application_yesgobus/screens/Home_screen.dart';
import 'package:flutter_application_yesgobus/screens/TicketScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/png_asset_constant.dart';

class PaymentStatusScreen extends StatefulWidget {
  final String bookingId;

  PaymentStatusScreen({required this.bookingId});

  @override
  _PaymentStatusScreenState createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  String bookingStatus = 'loading'; // loading, pending, success, failed
  String error = '';
  Map<String, dynamic>? bookingDetails;

  @override
  void initState() {
    super.initState();
    print("Entered payment status screen");
    checkBookingStatus();
  }

  void _startBookingStatusCheck() {
    Future.delayed(Duration(seconds: 2), () {
      checkBookingStatus();
      //_startBookingStatusCheck(); // Recursively call again
    });
  }

  Future<void> checkBookingStatus() async {
    try {
      final response = await ApiBase.getRequest(
          extendedURL: "busBooking/getBookingById/${widget.bookingId}", withToken: false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("getbookingid data $data");
        final status = data['data']['bookingStatus'];
        print("getbookingid status $status");

        setState(() {
          if (status == 'paid') {
            bookingStatus = 'success';
            bookingDetails = data['data'];
          } else if (status == 'pending') {
            bookingStatus = 'pending';
          } else {
            bookingStatus = 'failed';
            bookingDetails = data['data'];
          }
        });
        _startBookingStatusCheck();
      } else {
        setState(() {
          error = 'Failed to fetch booking status. Please try again.';
          print(error);
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to fetch booking status. Please try again.';
        print(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment Status')),
      body: Center(
        child: bookingStatus == 'loading'
            ? buildLoading()
            : bookingStatus == 'pending'
            ? buildPending()
            : bookingStatus == 'success'
            ? buildSuccess()
            : buildFailed(),
      ),
    );
  }

  Widget buildLoading() {
    return buildStatusCard(
      title: 'Checking Payment Status...',
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Pass style separately
      description: 'Please wait while we retrieve your booking details.',
      image: PngAssetPath.paymentpending,
    );
  }

  Widget buildPending() {
    return buildStatusCard(
      title: 'Payment Successful!',
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Pass style separately
      description: 'Booking In Progress...',
      subtitle: 'We are processing your booking. Please wait...',
      image: PngAssetPath.paymentsuccess,
    );
  }

  Widget buildSuccess() {
    return buildStatusCard(
      title: 'Seat Booked Successfully!',
      titleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      description: 'Your Ticket Details:',
      subtitle: 'Booking ID: ${widget.bookingId}\nThank you for booking with us!',
      image: PngAssetPath.bookingsuccess,
      button: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Align buttons horizontally
        children: [
          // ✅ View Ticket Button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicketScreen(bookingId: widget.bookingId),
                ),
              );
            },
            child: Text('View Ticket'),
          ),

          SizedBox(width: 10), // Space between buttons

          // ✅ Home Button
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) => false, // Clears all previous routes
              );
            },
            child: Text('Home'),
          ),
        ],
      ),
    );
  }

  Widget buildFailed() {
    return buildStatusCard(
      title: 'Booking Failed',
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Pass style separately
      description: 'The system is currently experiencing technical difficulties.',
      subtitle: 'Please try again later.',
      image: PngAssetPath.paymentfailed,
      button: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /*  ElevatedButton(
            onPressed: checkBookingStatus,
            child: Text('Retry'),
          ),*/
          SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Text('Back to Homepage'),
          ),
        ],
      ),
    );
  }
  Widget buildStatusCard({
    required String title,
    required TextStyle titleStyle,
    required String description,
    String? subtitle,
    String? image,
    Widget? button,
  }) {
    return Container(
      width: double.infinity, // Ensures it takes the full width
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centers content on the screen
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (image != null)
            Image.asset(image, width: 150, height: 150), // Increased size for better visibility
          SizedBox(height: 20),
          Text(title, style: titleStyle, textAlign: TextAlign.center), // Centered text
          SizedBox(height: 10),
          Text(description, textAlign: TextAlign.center),
          if (subtitle != null) ...[
            SizedBox(height: 10),
            Text(subtitle, textAlign: TextAlign.center),
          ],
          if (button != null) ...[
            SizedBox(height: 20),
            button,
          ],
        ],
      ),
    );
  }
}
