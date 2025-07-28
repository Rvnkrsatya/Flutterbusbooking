
import 'package:flutter/material.dart';
import 'package:flutter_application_yesgobus/screens/Home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'LoginPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkDeviceLoginStatus();
  }

  Future<String> getDeviceId() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      final deviceId = androidInfo.id ?? 'UnknownDeviceId';
      await _saveDeviceId(deviceId);
      print('Android Device ID: $deviceId');
      return deviceId;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      final deviceId = iosInfo.identifierForVendor ?? 'UnknownDeviceId';
      await _saveDeviceId(deviceId);
      return deviceId;
    } else {
      return 'UnsupportedPlatform';
    }
  }

  Future<void> _saveDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceId', deviceId);
    print('Device ID saved: $deviceId');
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<void> checkDeviceLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    final savedToken = prefs.getString('token');
    final savedUserId = prefs.getString('userId');

    if (savedEmail != null && savedToken != null) {
      print('--- SharedPreferences (Login Detected) ---');
      print('Email: $savedEmail');
      print('Token: $savedToken');
      print('User ID: $savedUserId');
      print('------------------------------------------');

      Get.off(() => const HomeScreen());
      return;
    }

    // Fallback to device-based API login check
    try {
      final deviceId = await getDeviceId();
      final response = await http.get(
        Uri.parse('https://apis.yesgobus.com/api/user/isLoggedIn?deviceId=$deviceId'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('API Response (Splash): $responseData');

        if (responseData['success'] == true &&
            responseData['data']['isLoggedIn'] == true) {
          final userId = responseData['data']['userId'].toString();
          await _saveUserId(userId);
          print('User ID from API saved: $userId');

          Get.off(() => const HomeScreen());
        } else {
          Get.off(() => const LoginPage());
        }
      } else {
        print('API Error: ${response.statusCode}');
        Get.off(() => const LoginPage());
      }
    } catch (e) {
      print('Exception during login check: $e');
      Get.off(() => const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: Get.height,
          width: Get.width,
          color:Color(0xFF033564),
          child: Center(
            child: Image.asset(
              'assets/images/yesgobuswhite.png',
              height: 110,
              width: 170,
            ),
          ),
        ),
      ),
    );
  }
}
























//
// //splash_page.dart
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import '../01BUSAPP/busapp_view.dart'; // Update with your actual file path
// import 'login_page.dart'; // Update with your actual file path
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     checkDeviceLoginStatus();
//   }
//
//
//
//   Future<String> getDeviceId() async {
//     final deviceInfoPlugin = DeviceInfoPlugin();
//
//     if (Platform.isAndroid) {
//       final androidInfo = await deviceInfoPlugin.androidInfo;
//       final deviceId = androidInfo.id ?? 'UnknownDeviceId'; // Unique Android ID
//       await _saveDeviceId(deviceId);
//       print('Android Device ID is123: $deviceId');
//       return deviceId;
//     } else if (Platform.isIOS) {
//       final iosInfo = await deviceInfoPlugin.iosInfo;
//       final deviceId = iosInfo.identifierForVendor ?? 'UnknownDeviceId'; // Unique iOS ID
//       await _saveDeviceId(deviceId);
//       return deviceId;
//     } else {
//       return 'UnsupportedPlatform';
//     }
//   }
//
//   Future<void> _saveDeviceId(String deviceId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('deviceId', deviceId);
//     print('Device ID saved: $deviceId');
//   }
//
//
//
//   // Future<void> checkDeviceLoginStatus() async {
//   //   try {
//   //     final deviceId = await getDeviceId();
//   //     final response = await http.get(
//   //       Uri.parse('https://apis.yesgobus.com/api/user/isLoggedIn?deviceId=$deviceId'),
//   //     );
//   //
//   //     if (response.statusCode == 200) {
//   //       final responseData = json.decode(response.body);
//   //       print('Response Data (Splash): $responseData'); // Debugging print
//   //
//   //       if (responseData['success'] == true && responseData['data']['isLoggedIn'] == true) {
//   //         final userId = responseData['data']['userId'].toString(); // Ensure it's stored as a string
//   //         await _saveUserId(userId); // Save userId in SharedPreferences
//   //         print('User ID saved: $userId');
//   //
//   //         Get.off(() => const LandingBusAppScreen());
//   //       } else {
//   //         Get.off(() => const LoginPage());
//   //       }
//   //     } else {
//   //       print('API error: ${response.statusCode}');
//   //       Get.off(() => const LoginPage());
//   //     }
//   //   } catch (e) {
//   //     print('Error occurred: $e');
//   //     Get.off(() => const LoginPage());
//   //   }
//   // }
//
// // Function to save userId in SharedPreferences
//   Future<void> _saveUserId(String userId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userId', userId);
//   }
//
//   Future<void> checkDeviceLoginStatus() async {
//     try {
//       final deviceId = await getDeviceId();
//       final response = await http.get(
//         Uri.parse('https://apis.yesgobus.com/api/user/isLoggedIn?deviceId=$deviceId'),
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         print('Response Datasplash: $responseData'); // Print the response data for debugging
//
//         if (responseData['success'] == true && responseData['data']['isLoggedIn'] == true) {
//           // Navigate to the landing page
//           Get.off(() => const LandingBusAppScreen());
//         }
//
//         else {
//           // Navigate to the login page
//           Get.off(() => const LoginPage());
//         }
//
//       } else {
//         print('API error: ${response.statusCode}');
//         Get.off(() => const LoginPage());
//       }
//
//     } catch (e) {
//       print('Error occurred: $e');
//       Get.off(() => const LoginPage());
//     }
//   }
//
//   // Future<void> checkDeviceLoginStatus() async {
//   //   try {
//   //     final deviceId = await getDeviceId();
//   //     final response = await http.get(
//   //       Uri.parse('https://apis.yesgobus.com/user/isLoggedIn?deviceId=$deviceId'),
//   //     );
//   //
//   //     if (response.statusCode == 200) {
//   //       final responseData = json.decode(response.body);
//   //       print('Response Data: $responseData');
//   //
//   //       if (responseData['isLoggedIn'] == true) {
//   //         // Navigate to the landing page
//   //         Get.off(() => const LandingBusAppScreen());
//   //       } else {
//   //         // Navigate to the login page
//   //         Get.off(() => const LoginPage());
//   //       }
//   //     } else {
//   //       print('API error: ${response.statusCode}');
//   //       Get.off(() => const LoginPage());
//   //     }
//   //   } catch (e) {
//   //     print('Error occurred: $e');
//   //     Get.off(() => const LoginPage());
//   //   }
//   // }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           height: Get.height,
//           width: Get.width,
//           color: Colors.orange[800],
//           child: Center(
//             child: Image.asset(
//               'assets/images/png/splashloo_white.png',
//               height: 110,
//               width: 170,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// // import 'dart:developer';
// //
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:travel_booking/Screens/01BUSAPP/busapp_view.dart';
// // import 'package:travel_booking/Screens/onboardingScreen/onboarding_1.dart';
// // import 'package:travel_booking/utils/constant/png_asset_constant.dart';
// // import 'package:travel_booking/widget/textwidget/text_widget.dart';
// //
// // import '../../config/routes/app_routes.dart';
// // import '../../utils/getStore/get_store.dart';
// //
// // class SplashScreen extends StatefulWidget {
// //   const SplashScreen({super.key});
// //
// //   @override
// //   State<SplashScreen> createState() => _SplashScreenState();
// // }
// //
// // class _SplashScreenState extends State<SplashScreen> {
// //   @override
// //   void initState() {
// //     navigateToLogin();
// //     super.initState();
// //   }
// //
// //   void navigateToLogin() async {
// //     await Future.delayed(const Duration(seconds: 1)).then((value) {
// //       // if (GetStoreData.getStore.read('access_token') == null) {
// //       //   Get.offAll(() => const OnboardingScreen1());
// //       // } else {
// //       //   log(GetStoreData.getStore.read('access_token').toString());
// //       Get.offAll(LandingBusAppScreen());
// //       // }
// //     });
// //   }
// //
// //
// // //satya
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SafeArea(
// //         child: Container(
// //           height: Get.height,
// //           width: Get.width,
// //           color: Colors.orange[900], // Set the background color to orange
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Image.asset(
// //                 PngAssetPath.splashLogo,
// //                 height: 110,
// //                 width: 170,
// //               ),
// //               /*TextWidget(
// //                 text: "",
// //                 textSize: 16,
// //                 fontWeight: FontWeight.w500,
// //               ),*/
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// // /*
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SafeArea(
// //         child: Container(
// //             height: Get.height,
// //             width: Get.width,
// //             decoration: BoxDecoration(
// //                 image: DecorationImage(
// //                     fit: BoxFit.cover, image: AssetImage(PngAssetPath.bgImg))),
// //             child: Column(mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Image.asset(
// //                   PngAssetPath.splashLogo,
// //                   height: 110,
// //                   width: 170,
// //                 ),
// //                 TextWidget(text: "Welcome To YesGo Bus", textSize:16,fontWeight: FontWeight.w500,),
// //               ],
// //             )),
// //       ),
// //     );
// //   }
// // */
// // }
