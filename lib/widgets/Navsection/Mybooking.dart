import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Service/appservice/api_urls.dart';
import '../../Service/appservice/apibase.dart';
import '../../screens/CancelTicketPage.dart';
import '../../screens/TicketScreen.dart';

 // for date parsing


class Mybooking extends StatefulWidget {
  const Mybooking({super.key});

  @override
  State<Mybooking> createState() => _MybookingState();
}

class _MybookingState extends State<Mybooking> {
  List<dynamic> upcomingBookings = [];
  List<dynamic> completedBookings = [];
  List<dynamic> cancelledBookings = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('_id');
      // final userId = "64f9eae480a5869e9ea0c8af" ;
       print("🔵 Fetching bookings for userId: $userId");
      //
      // final response = await ApiBase.getRequest(
      //   extendedURL: "busBooking/getAllBookings/$userId", withToken: true,
      // );
      // final userId = "64f9eae480a5869e9ea0c8af";
      final apiLink = "busBooking/getAllBookings/$userId";

      print("🔵 Fetching bookings for userId: $userId");
      print("🌐 API Link: ${ApiUrls.baseUrl}$apiLink");

      final response = await ApiBase.getRequest(
        extendedURL: apiLink,
        withToken: true,
      );
      debugPrint('[API CALL] PATCH: $response');

      print("🟢 Response Status Code: ${response.statusCode}");
      print("🟢 Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);
      final bookings = jsonResponse['data'] as List;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      upcomingBookings = [];
      completedBookings = [];
      cancelledBookings = [];

      for (var booking in bookings) {
        final doj = DateFormat("yyyy-MM-dd").parse(booking["doj"]);
        final dojDate = DateTime(doj.year, doj.month, doj.day);
        final status = booking["bookingStatus"];

        if (status == "cancelled") {
          cancelledBookings.add(booking);
        } else if (status == "paid") {
          if (dojDate.isBefore(today)) {
            completedBookings.add(booking);
          } else {
            upcomingBookings.add(booking);
          }
        }
      }
      print("✅ Upcoming: ${upcomingBookings.length}, Completed: ${completedBookings.length}, Cancelled: ${cancelledBookings.length}");

      setState(() {}); // Refresh UI
    } catch (e) {
      print("❌ Error fetching bookings: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Bookings', style: TextStyle(fontSize: 20.sp,color: Colors.white)),
          backgroundColor: const Color(0xFF033564),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.h),
            child: Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Color(0xFF033564),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF14bde3),
                indicatorWeight: 3.h,
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
            ),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            BookingList(bookings: upcomingBookings, bookingType: 'upcoming'),
            BookingList(bookings: completedBookings, bookingType: 'completed'),
            BookingList(bookings: cancelledBookings, bookingType: 'cancelled'),
          ],
        ),

      ),
    );
  }
}


class BookingList extends StatelessWidget {
  final List<dynamic> bookings;
  final String bookingType;

  const BookingList({super.key, required this.bookings,required this.bookingType,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(child: Text("No bookings found."));
    }

    return ListView.builder(
      itemCount: bookings.length,
      padding: EdgeInsets.all(12.w),
      itemBuilder: (context, index) {
        final booking = bookings[index];

        return Card(
          elevation: 3,
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListTile(
            leading: Icon(Icons.directions_bus, color: const Color(0xFF033564)),
            title: Text(
              "${booking['sourceCity']} → ${booking['destinationCity']}",
              style: TextStyle(fontSize: 17.sp, fontWeight : FontWeight.bold,color: const Color(0xFF033564)),
            ),
            subtitle: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 15.sp, color: Colors.black),
                children: [
                  TextSpan(
                    text:
                    'Date: ${formatDoj(booking['doj'])}\n${formatTime(booking['pickUpTime'])} → ${formatTime(booking['reachTime'])}',
                  ),

                  TextSpan(
                    text: '\n${booking['busOperator']}',
                  ),
                ],
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18.sp),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    side: const BorderSide(color: Color(0xFF14bde3), width: 1.5),
                  ),
                  backgroundColor: Colors.white,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${booking['sourceCity']} → ${booking['destinationCity']}\n",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF033564),
                                    ),
                                  ),
                                  TextSpan(
                                    text: formatDoj(booking['doj']),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF033564),
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          Divider(color: Colors.grey.shade300),

                          // Bus Info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${formatTime(booking['pickUpTime'])} → ${formatTime(booking['reachTime'])}",
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                booking['busOperator'],
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              Text(
                                booking['busType'],
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              SizedBox(height: 16.h),
                            ],
                          ),

                          // Button section
                          if (bookingType == 'upcoming') ...[
                            Wrap(
                              spacing: 10.w,
                              runSpacing: 10.h,
                              alignment: WrapAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TicketScreen(bookingId: booking['_id']),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF033564),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                    ),
                                    child: const Text("View Ticket", textAlign: TextAlign.center),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CancelTicketPage(
                                            bookingData: {
                                              "_id": booking["_id"],
                                              "isVrl": booking["isVrl"],
                                              "isSrs": booking["isSrs"],
                                              "opPNR": booking["opPNR"],
                                              "blockKey": booking["blockKey"],
                                              "selectedSeats": booking["selectedSeats"],
                                              "tid": booking["tid"],
                                              "razorpay_payment_id": booking["razorpay_payment_id"],
                                              "userId": booking["userId"], // needed for isAgent check
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("Cancel Ticket", textAlign: TextAlign.center),
                                  ),

                                ),
                              ],
                            ),

                          ] else ...[
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TicketScreen(bookingId: booking['_id']),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF033564),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: const Text("View Ticket"),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );

            },


          ),
        );
      },
    );
  }

  String formatDoj(String rawDate) {
    try {
      DateTime date = DateTime.parse(rawDate);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return rawDate; // fallback
    }
  }

  String formatTime(String time24) {
    try {
      final parsedTime = DateFormat("HH:mm").parse(time24);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      return time24; // fallback if parsing fails
    }
  }

}

//
// class BookingList extends StatelessWidget {
//   final List<dynamic> bookings;
//
//   const BookingList({super.key, required this.bookings});
//
//   @override
//   Widget build(BuildContext context) {
//     if (bookings.isEmpty) {
//       return Center(child: Text("No bookings found."));
//     }
//
//     return ListView.builder(
//       itemCount: bookings.length,
//       padding: EdgeInsets.all(12.w),
//       itemBuilder: (context, index) {
//         final booking = bookings[index];
//         return Card(
//           elevation: 3,
//           margin: EdgeInsets.only(bottom: 12.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           child: ListTile(
//             leading: Icon(Icons.directions_bus, color: Color(0xFF033564)),
//             title: Text( "${booking['sourceCity']} → ${booking['destinationCity']}", style: TextStyle(fontSize: 17.sp,color: Color(0xFF033564))),
//
//             subtitle: RichText(
//               text: TextSpan(
//                 style: TextStyle(fontSize: 15.sp, color: Colors.black),
//                 children: [
//                   TextSpan(
//                     text: 'PNR: ${booking['opPNR']}\nDate: ${formatDoj(booking['doj'])}',
//                     style: TextStyle(color: Colors.black), // Remaining text in black
//                   ),
//                   TextSpan(
//                     text: '\n${booking['busOperator']}',
//                     style: TextStyle(color: Colors.black), // Make operator name blue
//                   ),
//
//                 ],
//               ),
//             ),
//
//             trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18.sp),
//           ),
//         );
//       },
//     );
//   }
//
//   String formatDoj(String rawDate) {
//     try {
//       DateTime date = DateTime.parse(rawDate);
//       return DateFormat('dd-MM-yyyy').format(date);
//     } catch (e) {
//       return rawDate; // fallback
//     }
//   }
// }
