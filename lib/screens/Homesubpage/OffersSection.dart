import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (_, __) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: OffersScreen(),
      ),
    );
  }
}

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
         child: OffersSection(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home'),
            _buildNavItem(Icons.local_offer, 'Offers'),
            _buildNavItem(Icons.directions_bus, 'Bookings'),
            _buildNavItem(Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  static Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue, size: 24.sp),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.black87),
        ),
      ],
    );
  }
}

class OffersSection extends StatelessWidget {
  OffersSection({super.key});

  final List<Map<String, String>> offers = const [
    {
      "type": "Bus",
      "title": "Enjoy a flat 10% off (Min ₹1000)",
      "validity": "31 Jul",
      "tag": "FIRST",
      "image": "assets/images/blueimg.png",
    },
    {
      "type": "Bus",
      "title": "Save up to ₹50 on bus tickets",
      "validity": "31 Jul",
      "tag": "BUS50",
      "image": "assets/images/pinkicon.png",
    },
    {
      "type": "Train",
      "title": "Get ₹100 off on train booking",
      "validity": "31 Jul",
      "tag": "TRAIN100",
      "image": "assets/images/touroffer.webp",
    },
    {
      "type": "Hotel",
      "title": "Flat 30% off on hotel bookings",
      "validity": "31 Jul",
      "tag": "STAY30",
      "image": "assets/images/bustravell.jpeg",
    },
  ];

  final List<Color> offerColors = [
    Color(0xFFFFF3E0),
    Color(0xFFcdc6ff),
    Color(0xFFE3F2FD),
    Color(0xFFE8F5E9),
  ];
  final List<Color> backgroundColors = [
    Color(0xFFFFF3E0),
    Color(0xFFcdc6ff),
    Color(0xFFE3F2FD),
    Color(0xFFE8F5E9),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Offers", style: TextStyle(
                  fontSize: 20.sp, fontWeight: FontWeight.bold)),
              Text("View all",
                  style: TextStyle(fontSize: 14.sp, color: Colors.blue)),
            ],
          ),
        ),

        // Filter buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: ["All", "Bus", "Tour & Travel"].map((filter) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: filter == "All" ? Colors.pink.shade50 : Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(filter, style: TextStyle(fontSize: 13.sp)),
                ),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: 22.h),

        // Horizontal offer cards
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16.w),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              final bgColor = backgroundColors[index % backgroundColors.length];

              return GestureDetector(
                onTap: () => _showOfferDetails(context, offer, bgColor),
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Container(
                    width: 300.w,
                    decoration: BoxDecoration(
                      color: offerColors[index % offerColors.length],
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(offer["type"]!, style: TextStyle(
                              color: Colors.white, fontSize: 11.sp)),
                        ),
                        SizedBox(height: 8.h),

                        // Title
                        Text(
                          offer["title"]!,
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.h),

                        // Validity
                        Text("Valid till: ${offer["validity"]}",
                            style: TextStyle(fontSize: 14.sp)),

                        const Spacer(),

                        // Tag + image
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30.r),
                                boxShadow: [
                                  BoxShadow(color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.local_offer, size: 16.sp),
                                  SizedBox(width: 4.w),
                                  Text(offer["tag"]!, style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            // Expanded(
                            //   child: Align(
                            //     alignment: Alignment.bottomRight,
                            //     child: Image.asset(
                            //       offer["image"]!,
                            //       height: 100.h,
                            //       fit: BoxFit.contain,
                            //     ),
                            //   ),
                            // ),

                            SizedBox(
                              height: 100.h,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Image.asset(
                                  offer["image"]!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showOfferDetails(BuildContext context, Map<String, String> offer, Color backgroundColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 60.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 🟡 MATCHING BACKGROUND COLOR
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              offer["type"] ?? "",
                              style: TextStyle(color: Colors.white, fontSize: 11.sp),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            offer["title"] ?? "",
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6.h),
                          Text("Valid till: ${offer["validity"]}", style: TextStyle(fontSize: 14.sp)),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30.r),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.local_offer, size: 16.sp),
                                    SizedBox(width: 6.w),
                                    Text(offer["tag"] ?? "", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Image.asset(
                                offer["image"] ?? "",
                                height: 80.h,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Terms & Conditions
                    Text(
                      "Terms & Conditions",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10.h),

                    ..._buildOfferConditions(offer["tag"] ?? ""),

                    SizedBox(height: 30.h),

                    // Copy Code Button
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 14.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r)),
                        ),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: offer["tag"] ?? ""));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Offer code copied!")),
                          );
                        },
                        child: Text("Copy offer code", style: TextStyle(
                            fontSize: 14.sp)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  List<Widget> _buildOfferConditions(String code) {
    return [
      _condition(
          "1. Use code $code to get up to ₹50 discount on bus ticket bookings."),
      _condition("2. Offer available for a limited time."),
      _condition("3. Minimum ticket value ₹200."),
      _condition("4. Applicable once per user."),
      _condition("5. Valid for verified users only."),
      _condition("6. Cashback (if any) will be credited within 48 hours."),
    ];
  }

  Widget _condition(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 13.sp),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
