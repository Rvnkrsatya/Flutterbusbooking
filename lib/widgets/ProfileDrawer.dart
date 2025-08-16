import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_application_yesgobus/widgets/ContactUsScreen.dart';
import 'package:flutter_application_yesgobus/widgets/Mybooking.dart';
import 'package:flutter_application_yesgobus/widgets/TermsScreen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Pages/bus_list_page.dart';
import '../screens/LoginPage.dart';
import '../Service/appservice/api_urls.dart';
import '../Service/appservice/get_store_data.dart';
import 'Privacy.dart';
import 'ProfileScreen.dart';


class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({super.key});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  String userName = 'Guest';
  String userPhone = 'No number';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_fullName') ?? 'Guest';
      userPhone = prefs.getString('user_phone') ?? 'No number';
      userId = prefs.getString('userId') ?? '';
    });
  }

  Future<void> _handleLogout() async {
    print("Logging out user...");

    try {
      // final url = Uri.parse('https://apis.yesgobus.com/api/user/logout?userId=$userId');
      final url = Uri.parse(ApiUrls.logout(userId));

      final response = await dio.Dio().get(url.toString());

      if (response.statusCode == 200) {
        print("Logout API Response: ${response.data}");
      } else {
        print("Logout failed");
      }
    } catch (e) {
      print("Logout exception: $e");
    }

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login page
    Get.offAll(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 🔵 Header with gradient
          ClipPath(
            clipper: DoubleWaveClipper(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 65, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF033564), Color(0xFF033564)],
                ),
              ),
              child:
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close drawer first
                  Future.delayed(const Duration(milliseconds: 250), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  });
                },
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 36, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userPhone,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Drawer Options
          const DrawerButtonItem(icon: Icons.home, label: 'Home'),
          DrawerButtonItem(
            icon: Icons.bus_alert,
            label: 'Bus booking',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BusListPage(),
                ),
              );
            },
          ),

          DrawerButtonItem(
            icon: Icons.work_history,
            label: 'My Booking',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Mybooking()),
              );
            },
          ),

          DrawerButtonItem(
            icon: Icons.contact_page,
            label: 'Contact Us',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactUsScreen()),
              );
            },
          ),
          DrawerButtonItem(
            icon: Icons.policy,
            label: 'Privacy Policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Privacy()),
              );
            },
          ),

          // const DrawerButtonItem(icon: Icons.contact_emergency_outlined, label: 'Contact us'),
          DrawerButtonItem(
            icon: Icons. terminal_sharp,
            label: 'Terms and Service',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsScreen()),
              );
            },
          ),

          // const DrawerButtonItem(icon: Icons.policy, label: 'Privacy Policy'),





          const Spacer(),

          // 🔴 Logout
          DrawerButtonItem(
            icon: Icons.logout,
            label: 'Logout',
            color: Colors.white,
            backgroundColor: const Color(0xFF033564),
            onTap: _handleLogout,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class DrawerButtonItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const DrawerButtonItem({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? const Color(0xFF033564);
    final bgColor = backgroundColor ?? const Color(0xFFE8F0FA);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: iconColor,
            ),
          ),
          onTap: onTap ?? () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class DoubleWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 40);

    final secondControlPoint = Offset(size.width * 0.75, size.height - 80);
    final secondEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
