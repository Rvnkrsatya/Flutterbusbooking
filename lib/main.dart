import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_application_yesgobus/screens/SplashScreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ Add this
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // 👈 Use the design size you created your UI for
      minTextAdapt: true, // 👈 Auto-scale text
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'YesGoBus',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),

          // 👇 For date formatting in UK (dd/MM/yyyy)
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'GB'),
          ],

          home: const SplashScreen(),
        );
      },
    );
  }
}
