import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_yesgobus/screens/authontication/Home_screen.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import '../authentication/signup_page.dart';
import 'package:flutter/services.dart';

import '../../Service/appservice/api_urls.dart';
import '../../Service/appservice/get_store_data.dart';
import 'SignupScreen.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _showOtpField = false;
  bool _loading = false;
  String? _requestId;
  late WebViewController _webViewController;
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _otpFocus = FocusNode();



  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _clearSessionData();
    _saveDeviceId();
  }

  // Initialize Firebase
  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(); // Initialize Firebase
  }

  Future<void> _clearSessionData() async {
    print("🔹 Clearing session data...");

    // 1️⃣ Clear WebView Cookies
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();
    print("✅ Cookies cleared");

    // 2️⃣ Clear WebView Local Storage
    _webViewController = WebViewController();
    await _webViewController.runJavaScript("""

      localStorage.clear();
      sessionStorage.clear();
      document.cookie.split(";").forEach(function(c) {
          document.cookie = c.replace(/^ +/, "").replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/");
      });
    """);
    print("✅ WebView storage cleared");

    // 3️⃣ Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("✅ SharedPreferences cleared");

    // 4️⃣ Sign out of Google
    GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
      print("✅ Google Sign-Out successful");
    }

    print("🔹 Session cleanup complete!");
  }


  // Save Device ID to SharedPreferences
  Future<void> _saveDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = await _getDeviceId();
    await prefs.setString('deviceId', deviceId); // Store device ID
  }


  // Get Device ID
  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Unique device ID for Android
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'UnknownDeviceId';
    }
    return 'UnknownDeviceId';
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    // Fetch or generate device ID
    String? deviceId = prefs.getString('deviceId');
    if (deviceId == null || deviceId == 'UnknownDeviceId') {
      deviceId = await _getDeviceId();
      await prefs.setString('deviceId', deviceId); // Store device ID
    }

    log('Stored Device ID: $deviceId');
  }


  Future<void> _sendOtp() async {
    if (_mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating, // Makes it float
          margin: EdgeInsets.only(top: 200), // Position it at the top
          backgroundColor: Colors.red, // Background color
          content: Text(
            "Please enter your mobile number",
            style: TextStyle(color: Colors.white), // Red text
          ),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final response = await http.post(
        // Uri.parse('https://apis.yesgobus.com/api/user/signin'),
        Uri.parse(ApiUrls.signIn),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobileNumber': _mobileController.text}),
      );

      print("Response Body1: ${response.body}"); // Debugging line

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _requestId = responseData['data']['requestId'];
          _showOtpField = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('OTP sent successfully!  Please enter the OTP')),
        );
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['message'] ?? "Failed to send OTP")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending OTP")),
      );
      print("Error: $error");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  Future<void> _verifyOtp() async {
    setState(() {
      _loading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('deviceId') ?? 'UnknownDeviceId';

      // Fetch device ID again if it is unknown
      if (deviceId == 'UnknownDeviceId') {
        deviceId = await _getDeviceId();
        await prefs.setString('deviceId', deviceId);
      }

      // Restrict login if device ID is still unknown
      if (deviceId == 'UnknownDeviceId') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Invalid Device ID. Please restart the app.")),
        );
        setState(() {
          _loading = false;
        });
        return;
      }

      final response = await http.post(
        // Uri.parse('https://apis.yesgobus.com/api/user/verify_login_otp'),
        Uri.parse(ApiUrls.verifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobileNumber': _mobileController.text,
          "requestId": _requestId,
          'otp': _otpController.text,
          'deviceId': deviceId,
        }),
      );

      print("Response Body2: ${response.body}");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['data']['token'];
        final user = responseData['data']['user'];

        await GetStoreData.storeUserData(
          userId: user['userId'].toString(),
          Id: user['_id'],
          name: user['fullName'] ?? '',
          email: user['email'] ?? '',
          authToken: token,
          phone: user['phoneNumber'],
          role: user['role'],
          deviceId: user['deviceId'],
          createdAt: user['createdAt'],
          updatedAt: user['updatedAt'],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful!"),
              backgroundColor: Colors.green),
        );

        Get.off(() => const HomeScreen());
      }

      // if (response.statusCode == 200) {
      //   final responseData = jsonDecode(response.body);
      //   final token = responseData['data']['token'];
      //   final user = responseData['data']['user'];
      //
      //   final prefs = await SharedPreferences.getInstance();
      //   await prefs.setString('token', token);
      //   await prefs.setString('user_fullName', user['fullName'] ?? '');
      //   await prefs.setString('user_email', user['email'] ?? '');
      //   await prefs.setString('user_phone', user['phoneNumber'] ?? '');
      //
      //   //  _showSuccess("Welcome to YesGoBus, ${user['fullName']}!");
      //
      //   // Print saved values from SharedPreferences to confirm
      //   final fullName = prefs.getString('user_fullName') ?? '';
      //   final email = prefs.getString('user_email') ?? '';
      //   final phone = prefs.getString('user_phone') ?? '';
      //
      //   print('--- SharedPreferences Data ---');
      //   print('Token loginnumber: $token');
      //   print('Full Name: $fullName');
      //   print('Email loginnumber: $email');
      //   print('Phone: $phone');
      //   print('-----------------------------');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("Login Successful!"),
      //         backgroundColor: Colors.green),
      //   );
      //
      //   Get.off(() => const HomeScreen());
      // }

      else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'].toString()),
              backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error verifying OTP"), backgroundColor: Colors.red),
      );
      print("Error: $error");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _googleSignIn() async {
    try {
      print("🔵 Google Sign-In process started...");

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: "829902296577-ltq7s9enoiuco44l87ufudflr7gvk77t.apps.googleusercontent.com",
        scopes: ['email'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("🟡 User canceled Google Sign-In.");
        return;
      }

      print("✅ Google User Info: Name=${googleUser
          .displayName}, Email=${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      if (googleAuth.idToken != null) {
        print(
            "🔵 ID Token: ${googleAuth.idToken}"); // ✅ Print Token for Debugging
        print("🔵 Sending ID Token to Backend for verification...");
        await _sendGoogleTokenToApi(googleAuth.idToken!);
      } else {
        print("❌ Error: ID Token is null!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to retrieve ID token. Please try again.")),
        );
      }
    } catch (error) {
      print("❌ Google Sign-In Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed. Please try again.")),
      );
    }
  }

  Future<void> _sendGoogleTokenToApi(String idToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = await _getDeviceId();
      await prefs.setString('deviceId', deviceId);

      final requestBody = jsonEncode({
        'jwtToken': idToken,
        'deviceId': deviceId,
      });

      print("📡 Sending Request to API...");
      print("📝 Request Body: $requestBody");

      final response = await http.post(
        Uri.parse(ApiUrls.googleSignIn),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print("🛠 Response Code: ${response.statusCode}");
      print("🔵 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 200 &&
            responseData['message'] == "Google SignIn successfull") {
          final token = responseData['token'];
          final user = responseData['data'];

          await GetStoreData.storeUserData(
            userId: user['userId'].toString(),
            Id: user['_id'],
            name: user['fullName'] ?? '',
            email: user['email'] ?? '',
            authToken: token,
            phone: user['phoneNumber'],
            role: user['role'],
            deviceId: user['deviceId'],
            createdAt: user['createdAt'],
            updatedAt: user['updatedAt'],
          );

          final fullName = prefs.getString('user_fullName') ?? '';
          final email = prefs.getString('user_email') ?? '';
          final phone = prefs.getString('user_phone') ?? '';

          print('--- SharedPreferences Data ---');
          print('Token logingoogle: $token');
          print('Full Name: $fullName');
          print('Email logingoogle: $email');
          print('Phone: $phone');
          print('-----------------------------');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Welcome, $fullName!")),
          );

          Get.off(() => const HomeScreen());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text(responseData['message'] ?? "Google Sign-In failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server Error: ${response.statusCode}")),
        );
      }
    } catch (error) {
      print("❌ API Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error connecting to the server. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF033564),
      body: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) {
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Stack(
                        children: [
                          Container(
                            height: constraints.maxHeight,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF033564), Color(0xFF14bde3)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 10.h),
                                Center(
                                  child: Image.asset(
                                    'assets/images/yesgobuswhite.png',
                                    height: 150.h,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "Welcome to YesGoBus",
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 15.h),
                                Card(
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.r)),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 18.w, vertical: 22.h),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Log In",
                                          style: TextStyle(
                                            fontSize: 26.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF033564),
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        Row(
                                          children: [
                                            Text(
                                              "Do have an account?",
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                            TextButton(
                                              onPressed: () => Get.off(() =>  SignupScreen()),
                                              child: Text(
                                                "Create Account",
                                                style: TextStyle(
                                                    color: const Color(0xFF14bde3),
                                                    fontSize: 13.sp),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.h),
                                        TextField(
                                          controller: _mobileController,
                                          focusNode: _mobileFocus,
                                          decoration: InputDecoration(
                                            labelText: "Enter Mobile Number",
                                            prefixText: "+91 ",
                                            labelStyle: TextStyle(color: Colors.black, fontSize: 14.sp),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(color: Color(0xFF033564)),
                                              borderRadius: BorderRadius.circular(10.r),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(color: Color(0xFF033564), width: 2),
                                              borderRadius: BorderRadius.circular(10.r),
                                            ),
                                          ),
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(10),
                                          ],
                                          onSubmitted: (_) {
                                            // Move focus to OTP field automatically
                                            if (_mobileController.text.length == 10) {
                                              FocusScope.of(context).requestFocus(_otpFocus);
                                            }
                                          },
                                        ),

                                        if (_showOtpField) ...[
                                          SizedBox(height: 12.h),
                                          TextField(
                                            controller: _otpController,
                                            focusNode: _otpFocus,
                                            decoration: InputDecoration(
                                              labelText: "Enter OTP",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8.r),
                                              ),
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),

                                          SizedBox(height: 8.h),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: _loading ? null : _sendOtp,
                                              child: Text(
                                                "Resend OTP",
                                                style: TextStyle(
                                                  color: const Color(0xFF033564),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        SizedBox(height: 20.h),
                                        ElevatedButton(
                                          onPressed: _loading
                                              ? null
                                              : _showOtpField
                                              ? _verifyOtp
                                              : _sendOtp,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF033564),
                                            padding: EdgeInsets.symmetric(vertical: 14.h),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.r),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _loading
                                                  ? "Loading..."
                                                  : _showOtpField
                                                  ? "Verify OTP"
                                                  : "Login",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Row(
                                  children: [
                                    const Expanded(
                                        child: Divider(color: Colors.white)),
                                    Padding(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                      child: Text(
                                        "or",
                                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                      ),
                                    ),
                                    const Expanded(
                                        child: Divider(color: Colors.white)),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                ElevatedButton.icon(
                                  onPressed: _googleSignIn,
                                  icon: Image.asset(
                                    'assets/images/google.png',
                                    height: 24.h,
                                    width: 24.w,
                                  ),
                                  label: Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      side: const BorderSide(color: Colors.black),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  'Ver: 01.7',
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 14.sp),
                                ),
                                SizedBox(height: 30.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


