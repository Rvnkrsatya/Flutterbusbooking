import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Mybooking extends StatelessWidget {
  const Mybooking({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Upcoming, Completed, Cancelled
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Bookings', style: TextStyle(fontSize: 20.sp)),
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
        body: TabBarView(
          children: [
            // Replace with your booking lists or API data
            BookingList(status: 'upcoming'),
            BookingList(status: 'completed'),
            BookingList(status: 'cancelled'),
          ],
        ),
      ),
    );
  }
}

class BookingList extends StatelessWidget {
  final String status;

  const BookingList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Dummy UI — Replace with actual booking item widgets
    return ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.all(12.w),
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: ListTile(
            leading: Icon(Icons.directions_bus, color: Color(0xFF033564)),
            title: Text('${status.capitalize()} Booking ${index + 1}', style: TextStyle(fontSize: 16.sp)),
            subtitle: Text('Date: 25 July 2025\nFrom: Karwar → Bangalore'),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18.sp),
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
