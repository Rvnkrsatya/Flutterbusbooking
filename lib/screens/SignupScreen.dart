import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_yesgobus/screens/Home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Service/appservice/api_urls.dart';
import 'LoginPage.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  String? _gender;
  String _requestId = '';
  String _deviceId = '';
  bool _showOtpField = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initDeviceId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      if (_showOtpField) {
        setState(() {
          _showOtpField = false;
          _otpController.clear();
        });
        return false;
      }
      return true;
    });
  }

  Future<void> _initDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (await Permission.phone.request().isGranted) {
      try {
        final androidInfo = await deviceInfo.androidInfo;
        setState(() {
          _deviceId = androidInfo.id ?? 'UNKNOWN_DEVICE_ID';
        });
      } catch (_) {
        setState(() => _deviceId = 'UNKNOWN_DEVICE_ID');
      }
    } else {
      setState(() => _deviceId = 'UNKNOWN_DEVICE_ID');
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final signupUrl = Uri.parse(ApiUrls.signUp);

    final body = {
      'phoneNumber': _mobileController.text,
      'email': _emailController.text,
      if (_nameController.text.trim().isNotEmpty)
        'fullName': _nameController.text.trim(),
      if (_gender != null) 'gender': _gender,
    };

    setState(() => _loading = true);

    try {
      final response = await http.post(
        signupUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      setState(() => _loading = false);
      final data = jsonDecode(response.body);
      final message = data['message'] ?? 'No message';

      if (response.statusCode == 200 && data['data']?['requestId'] != null) {
        _showSuccess("OTP sent to your number.");
        setState(() {
          _requestId = data['data']['requestId'];
          _showOtpField = true;
          _otpController.clear();
        });
      } else {
        _showError(message);
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError("Unexpected error. Please try again.");
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length < 4) {
      _showError("Please enter a valid OTP.");
      return;
    }

    setState(() => _loading = true);

    final verifyOtpUrl = Uri.parse(ApiUrls.verifyOtpsign);

    try {
      final response = await http.post(
        verifyOtpUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobileNumber': _mobileController.text.trim(),
          'requestId': _requestId,
          'otp': _otpController.text.trim(),
          'deviceId': _deviceId,
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        }),
      );

      setState(() => _loading = false);
      final data = jsonDecode(response.body);
      final message = data['message'] ?? '';

      if (data['status'] == 200 && data['data']?['token'] != null) {
        final token = data['data']['token'];
        final user = data['data']['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_fullName', user['fullName'] ?? '');
        await prefs.setString('user_email', user['email'] ?? '');
        await prefs.setString('user_phone', user['phoneNumber'] ?? '');

        _showSuccess("Welcome to YesGoBus, ${user['fullName']}!");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        _showError(message);
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError("Unexpected error. Please try again.");
    }
  }

  void _showError(String msg) {
    Get.snackbar('Error', msg,
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  void _showSuccess(String msg) {
    Get.snackbar('Success', msg,
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  InputDecoration _inputDecoration(String label, {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return WillPopScope(
      onWillPop: () async {
        if (_showOtpField) {
          setState(() {
            _showOtpField = false;
            _otpController.clear();
          });
          return false;
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => LoginPage()));
          return false;
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF033564),
                    Color(0xFF033564),
                    Color(0xFF033564),
                    Color(0xFF14bde3),
                    Color(0xFF033564)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 100 : 20, vertical: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              Image.asset('assets/images/yesgobuswhite.png', height: 100),
                              const SizedBox(height: 10),
                              const Text(
                                'Create an Account',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _nameController,
                                decoration: _inputDecoration('Full Name'),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _mobileController,
                                decoration: _inputDecoration('Mobile Number', prefixText: '+91 '),
                                keyboardType: TextInputType.phone,
                                validator: (value) => value!.length != 10 ? 'Enter valid mobile number' : null,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _emailController,
                                decoration: _inputDecoration('Email'),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter valid email' : null,
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                decoration: _inputDecoration('Gender'),
                                items: ['Male', 'Female', 'Other']
                                    .map((value) => DropdownMenuItem(
                                    value: value, child: Text(value)))
                                    .toList(),
                                onChanged: (value) => setState(() => _gender = value),
                                validator: (value) => value == null ? 'Select gender' : null,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'By continuing, I agree to the Terms of Use & Privacy Policy',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              if (_showOtpField) ...[
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _otpController,
                                  decoration: _inputDecoration("Enter OTP"),
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value!.length < 4 ? "Enter valid OTP" : null,
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: _loading ? null : _createAccount,
                                  child: const Text(
                                    "Resend OTP",
                                    style: TextStyle(color: Color(0xFF033564), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _loading
                                    ? null
                                    : _showOtpField
                                    ? _verifyOtp
                                    : _createAccount,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF033564),
                                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(
                                  _loading
                                      ? "Loading..."
                                      : _showOtpField
                                      ? "Verify OTP"
                                      : "Signup",
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
