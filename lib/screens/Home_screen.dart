import 'package:flutter/material.dart';
import 'package:flutter_application_yesgobus/screens/Tourplace.dart';
import 'package:get/get.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Pages/bus_list_page.dart';
import '../widgets/ProfileScreen.dart';
import '../widgets/nav_bar.dart';
import 'LocationSelectorScreen.dart';
import '../widgets/ProfileDrawer.dart';
import 'OffersSection.dart';
import 'RateUsSection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final translator = GoogleTranslator();

  String _fromCity = 'From';
  String _toCity = 'To';
  DateTime? _selectedDate = DateTime.now();
  String _selectedLanguage = 'en';
  String _selectedDayTag = 'today';

  final Color darkBlue = const Color(0xFF033564);
  final Color lightBlue = const Color(0xFF14bde3);

  String tBusTicket = 'Bus Ticket';
  String tFrom = '';
  String tTo = '';
  String tSearch = 'Search Buses';
  int _selectedIndex = 0;

  void _swapCities() {
    setState(() {
      final temp = _fromCity;
      _fromCity = _toCity;
      _toCity = temp;
    });
  }

  void _pickDateFromCalendar() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('en', 'GB'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: darkBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkBlue,
            ),
            dialogTheme: const DialogTheme(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _weekdayString(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${_weekdayString(date.weekday)}, ${date.day}-${months[date.month - 1]}";
  }

  Future<void> _translateLabels(String langCode) async {
    final labels = ['Bus Ticket', 'From', 'To', 'Search Buses'];
    final translated = await Future.wait(
      labels.map((text) => translator.translate(text, to: langCode)),
    );

    setState(() {
      tBusTicket = translated[0].text;
      tFrom = translated[1].text;
      tTo = translated[2].text;
      tSearch = translated[3].text;
    });
  }

  @override
  void initState() {
    super.initState();
    _translateLabels(_selectedLanguage);
  }

  @override




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const NavBar(),
      drawer: const ProfileDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                SizedBox(height: 10.h),
                _buildHistorySection(),
                SizedBox(height: 20.h),
                RateUsSection(),
                SizedBox(height: 20.h),
                OffersSection(),
                SizedBox(height: 30.h),
                Tourplace(),
                SizedBox(height: 20.h),

              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF033564),
            Color(0xFF1E4D78),
            Color(0xFF3A6590),
            Color(0xFF5A86A8),
            Color(0xFF86A9C0),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.r),
          bottomRight: Radius.circular(40.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tBusTicket,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: Colors.white,
                icon: const Icon(Icons.language, color: Colors.white),
                underline: const SizedBox(),
                style: TextStyle(color: Colors.black, fontSize: 16.sp),
                onChanged: (String? newLang) {
                  if (newLang != null) {
                    setState(() => _selectedLanguage = newLang);
                    _translateLabels(newLang);
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                  DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
                  DropdownMenuItem(value: 'ml', child: Text('മലയാളം')),
                  DropdownMenuItem(value: 'te', child: Text('తెలుగు')),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildSearchCard(),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.w),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.black),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LocationSelectorScreen(title: "From"),
                              ),
                            );
                            if (result != null) {
                              setState(() => _fromCity = result);
                            }
                          },
                          child: Text(" $_fromCity", style: TextStyle(fontSize: 16.sp)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey)),
                      SizedBox(width: 2.w),
                      GestureDetector(
                        onTap: _swapCities,
                        child: Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                          child: const Icon(Icons.swap_vert, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      const Icon(Icons.flag, color: Colors.black),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LocationSelectorScreen(title: "To"),
                              ),
                            );
                            if (result != null) {
                              setState(() => _toCity = result);
                            }
                          },
                          child: Text(" $_toCity", style: TextStyle(fontSize: 16.sp)),
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 1.2.h, color: Colors.grey),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDateFromCalendar,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _formatDate(_selectedDate ?? DateTime.now()),
                                  style: TextStyle(fontSize: 16.sp, color: Colors.black),
                                ),
                                SizedBox(width: 10.w),
                                const Icon(Icons.calendar_today, size: 18, color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _dayButton('Today', 'today'),
                      SizedBox(width: 6.w),
                      _dayButton('Tomorrow', 'tomorrow'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            onPressed: () {
              if (_fromCity != 'From' && _toCity != 'To' && _selectedDate != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusListPage(
                      fromCity: _fromCity,
                      toCity: _toCity,
                      selectedDate: _selectedDate!,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select From, To and Date')),
                );
              }
            },

            // onPressed: () {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       content: Text(
            //         "Searching buses from $_fromCity to $_toCity on ${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year}",
            //       ),
            //     ),
            //   );
            // },
            child: Text(
              tSearch,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(2.r),
            bottomRight: Radius.circular(2.r),
          ),
          child: Image.asset(
            'assets/images/ind_image.png',
            width: double.infinity,
            height: 70.h,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }


  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'History',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 70.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                width: 130.w,
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFeaf7fd),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFF033564)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Karwar  Hubli",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: const Color(0xFF033564),
                        )),
                    SizedBox(height: 1.h),
                    Text("24 July 25",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF033564),
                        )),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, -2.h),
            blurRadius: 6.r,
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: darkBlue,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/busBooking');
              break;
            case 2:
              launchCallNow('1800123456');
              break;
            case 3:
              Get.to(() => const ProfileScreen());
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'Bus Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Call to Book'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _dayButton(String label, String tag) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedDate = tag == 'today'
              ? DateTime.now()
              : DateTime.now().add(const Duration(days: 1));
          _selectedDayTag = tag;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedDayTag == tag ? darkBlue : Colors.white,
        foregroundColor: _selectedDayTag == tag ? Colors.white : darkBlue,
        side: BorderSide(color: darkBlue),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      child: Text(label, style: TextStyle(fontSize: 14.sp)),
    );
  }
}

void launchCallNow(String phoneNumber) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    throw 'Could not launch $phoneUri';
  }
}






















//
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.white,
//     appBar: const NavBar(),
//     drawer: const ProfileDrawer(),
//     body: SingleChildScrollView(
//       child: Column(
//         children: [
//           ClipPath(
//             child: Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                   colors: [
//                     const Color(0xFF033564),
//                     const Color(0xFF1E4D78),
//                     const Color(0xFF3A6590),
//                     const Color(0xFF5A86A8),
//                     const Color(0xFF86A9C0),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(40.r),
//                   bottomRight: Radius.circular(40.r),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         tBusTicket,
//                         style: TextStyle(
//                           fontSize: 20.sp,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       DropdownButton<String>(
//                         value: _selectedLanguage,
//                         dropdownColor: Colors.white,
//                         icon: const Icon(Icons.language, color: Colors.white),
//                         underline: const SizedBox(),
//                         style: TextStyle(color: Colors.white, fontSize: 16.sp),
//                         onChanged: (String? newLang) {
//                           if (newLang != null) {
//                             setState(() => _selectedLanguage = newLang);
//                             _translateLabels(newLang);
//                           }
//                         },
//                         items: const [
//                           DropdownMenuItem(value: 'en', child: Text('English')),
//                           DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
//                           DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
//                           DropdownMenuItem(value: 'ml', child: Text('മലയാളം')),
//                           DropdownMenuItem(value: 'te', child: Text('తెలుగు')),
//                         ],
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 4.h),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(16.r),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//                       child: Container(
//                         padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16.r),
//                           border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.w),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 const Icon(Icons.location_on, color: Colors.black),
//                                 SizedBox(width: 4.w),
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () async {
//                                       final result = await Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => const LocationSelectorScreen(title: "From"),
//                                         ),
//                                       );
//                                       if (result != null) {
//                                         setState(() => _fromCity = result);
//                                       }
//                                     },
//                                     child: Text(" $_fromCity", style: TextStyle(fontSize: 16.sp)),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 1.h),
//                             Row(
//                               children: [
//                                 Expanded(child: Divider(color: Colors.grey)),
//                                 SizedBox(width: 2.w),
//                                 GestureDetector(
//                                   onTap: _swapCities,
//                                   child: Container(
//                                     width: 30.w,
//                                     height: 30.w,
//                                     decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
//                                     child: const Icon(Icons.swap_vert, color: Colors.white),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 1.h),
//                             Row(
//                               children: [
//                                 const Icon(Icons.flag, color: Colors.black),
//                                 SizedBox(width: 4.w),
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () async {
//                                       final result = await Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => const LocationSelectorScreen(title: "To"),
//                                         ),
//                                       );
//                                       if (result != null) {
//                                         setState(() => _toCity = result);
//                                       }
//                                     },
//                                     child: Text(" $_toCity", style: TextStyle(fontSize: 16.sp)),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Divider(thickness: 1.2.h, color: Colors.grey),
//                             SizedBox(height: 1.h),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: _pickDateFromCalendar,
//                                     child: Container(
//                                       padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white.withOpacity(0.2),
//                                         borderRadius: BorderRadius.circular(8.r),
//                                         border: Border.all(color: Colors.grey.shade300),
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           Text(
//                                             _formatDate(_selectedDate ?? DateTime.now()),
//                                             style: TextStyle(fontSize: 16.sp, color: Colors.black),
//                                           ),
//                                           SizedBox(width: 10.w),
//                                           const Icon(Icons.calendar_today, size: 18, color: Colors.black),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 8.w),
//                                 _dayButton('Today', 'today'),
//                                 SizedBox(width: 6.w),
//                                 _dayButton('Tomorrow', 'tomorrow'),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10.h),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         elevation: 0,
//                       ),
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               "Searching buses from $_fromCity to $_toCity on ${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year}",
//                             ),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         tSearch,
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18.sp,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 1.h),
//                   ClipRRect(
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(2.r),
//                       bottomRight: Radius.circular(2.r),
//                     ),
//                     child: Image.asset(
//                       'assets/images/ind_image.png',
//                       width: double.infinity,
//                       height: 70.h,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12.w),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'History',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black.withOpacity(0.7),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 8.h),
//           SizedBox(
//             height: 70.h,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               padding: EdgeInsets.symmetric(horizontal: 12.w),
//               child: Row(
//                 children: List.generate(10, (index) {
//                   return Container(
//                     width: 130.w,
//                     margin: EdgeInsets.only(right: 12.w),
//                     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFeaf7fd),
//                       borderRadius: BorderRadius.circular(12.r),
//                       border: Border.all(color: const Color(0xFF033564)),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("Karwar  Hubli",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14.sp,
//                               color: const Color(0xFF033564),
//                             )),
//                         SizedBox(height: 1.h),
//                         Text("24 July 25",
//                             style: TextStyle(
//                               fontSize: 13.sp,
//                               color: const Color(0xFF033564),
//                             )),
//                       ],
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           ),
//           SizedBox(height: 10.h),
//           OffersSection(),
//         ],
//       ),
//     ),
//     bottomNavigationBar: Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             offset: Offset(0, -2.h),
//             blurRadius: 6.r,
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: darkBlue,
//         unselectedItemColor: Colors.black,
//         backgroundColor: Colors.white,
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//
//           switch (index) {
//             case 0:
//               break;
//             case 1:
//               Navigator.pushNamed(context, '/busBooking');
//               break;
//             case 2:
//               launchCallNow('1800123456');
//               break;
//             case 3:
//               Get.to(() => const ProfileScreen());
//               break;
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'Bus Booking'),
//           BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Call to Book'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     ),
//   );
// }
