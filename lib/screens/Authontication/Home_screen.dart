import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Pages/bus_list_page.dart';
import '../../Service/appservice/get_store_data.dart';

import '../../widgets/Navsection/Mybooking.dart';
import '../../widgets/Navsection/ProfileDrawer.dart';
import '../../widgets/Navsection/ProfileScreen.dart';
import '../../widgets/Navsection/nav_bar.dart';
import '../Homesubpage/LocationSelectorScreen.dart';
import '../Homesubpage/OffersSection.dart';
import '../Homesubpage/RateUsSection.dart';
import '../Homesubpage/Tourplace.dart';



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
  List<List<String>> _history = [];

  void _swapCities() {
    setState(() {
      final temp = _fromCity;
      _fromCity = _toCity;
      _toCity = temp;
    });
  }

  Future<void> _storeSearchData() async {
    final prefs = await SharedPreferences.getInstance();
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    // Save the latest search
    await prefs.setString('fromCity', _fromCity);
    await prefs.setString('toCity', _toCity);
    await prefs.setString('selectedDate', formattedDate);

    // Update history list
    final newSearch = [_fromCity, _toCity, formattedDate];
    List<String> savedHistory = prefs.getStringList('recentSearches') ?? [];

    // Add at beginning & remove duplicates
    savedHistory.remove(newSearch.join('|'));
    savedHistory.insert(0, newSearch.join('|'));

    // Keep only last 5
    if (savedHistory.length > 5) savedHistory = savedHistory.sublist(0, 5);

    await prefs.setStringList('recentSearches', savedHistory);

    print("✅ Stored recent search: $newSearch");
  }

  // 🔹 Load Recent Searches
  Future<List<List<String>>> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHistory = prefs.getStringList('recentSearches') ?? [];

    return savedHistory.map((item) => item.split('|')).toList();
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
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
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
    _printUserData();
    // Translate labels (if using Google Translate / translator package)
    _translateLabels(_selectedLanguage);

    // Load recent searches
    loadRecentSearches().then((data) {
      setState(() {
        _history = data;
      });
    });
  }
  Future<void> _printUserData() async {
    await GetStoreData.printUserData(); // uses your class method
  }
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
                _buildHistorySection(_history),
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
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.w,
                ),
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
                                builder:
                                    (_) => const LocationSelectorScreen(
                                      title: "From",
                                    ),
                              ),
                            );
                            if (result != null) {
                              setState(() => _fromCity = result);
                            }
                          },
                          child: Text(
                            " $_fromCity",
                            style: TextStyle(fontSize: 16.sp),
                          ),
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
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.swap_vert,
                            color: Colors.white,
                          ),
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
                                builder:
                                    (_) => const LocationSelectorScreen(
                                      title: "To",
                                    ),
                              ),
                            );
                            if (result != null) {
                              setState(() => _toCity = result);
                            }
                          },
                          child: Text(
                            " $_toCity",
                            style: TextStyle(fontSize: 16.sp),
                          ),
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
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 8.w,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _formatDate(_selectedDate ?? DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Colors.black,
                                ),
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
            onPressed: () async {
              if (_fromCity != 'From' &&
                  _toCity != 'To' &&
                  _selectedDate != null) {
                await _storeSearchData();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BusListPage()),
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

  Widget _buildHistorySection(List<List<String>> history) {
    if (history.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 80.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index]; // ["From", "To", "Date"]

              // Format the date
              String formattedDate = item[2];
              try {
                final date = DateTime.parse(item[2]);
                formattedDate = DateFormat('dd MMM yyyy').format(date);
              } catch (e) {
                // If parsing fails, keep original
              }

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/busList",
                    arguments: {
                      "from": item[0],
                      "to": item[1],
                      "date": item[2],
                    },
                  );
                },
                child: Container(
                  constraints: BoxConstraints(minWidth: 140.w, maxWidth: 220.w),
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFeaf7fd),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFF033564),
                      width: 1.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6.r,
                        offset: Offset(2.w, 4.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              "${item[0]} → ${item[1]}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: Color(0xFF033564),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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
              Get.to(() => const Mybooking());
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
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'My Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Call to Book',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _dayButton(String label, String tag) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedDate =
              tag == 'today'
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
