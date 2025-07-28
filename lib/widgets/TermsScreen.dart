import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkBlue = const Color(0xFF033564);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text(
          'Terms & Service',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [

            Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome to ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF033564),
                      ),
                    ),
                    TextSpan(
                      text: 'YesGo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF14bde3), // Sky Blue
                      ),
                    ),
                    TextSpan(
                      text: 'Bus',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF033564),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'By using YesGoBus, you agree to our Terms & Conditions.Please read them carefully before continuing.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            SectionTitle('1. Acceptance of Terms'),
            SectionText(
                'By accessing or using our platform, you acknowledge that you have read, understood, and agree to be bound by these terms of service. If you do not agree with any part of these terms, you may not use our services.'),

            SectionTitle('2. Booking and Reservations'),
            SectionText(
                'Our platform provides a convenient and user-friendly interface for booking bus tickets. By making a reservation through our platform, you agree to abide by the terms and conditions set by the bus service providers.'),

            SectionTitle('3. Payment and Pricing'),
            SectionText(
                'All transactions on our platform are subject to transparent pricing. By making a payment for your bus ticket, you agree to the pricing terms and conditions specified by the respective bus service provider. We reserve the right to update or modify pricing information at any time.'),

            SectionTitle('4. Cancellations and Refunds'),
            SectionText(
                'Cancellations and refund policies are determined by the individual bus service providers. Please review the cancellation and refund policies of the specific bus service you choose. We are not responsible for refunds or disputes related to cancellations.'),

            SectionTitle('5. User Conduct'),
            SectionText(
                'You agree to use our platform for lawful purposes only and in a manner consistent with all applicable laws and regulations. Any unauthorized use or violation of these terms may result in the suspension or termination of your account.'),

            SectionTitle('6. Limitation of Liability'),
            SectionText(
                'We strive to provide a reliable and seamless service; however, we are not liable for any direct, indirect, incidental, consequential, or special damages arising out of or in connection with your use of our platform or the bus services booked through it.'),

            SectionTitle('7. Changes to Terms'),
            SectionText(
                'We reserve the right to update, modify, or replace these terms of service at any time. It is your responsibility to check this page periodically for changes. Your continued use of the platform after any modifications will constitute your acknowledgment of the changes and your consent to abide and be bound by the modified terms.'),

            SectionTitle('8. Privacy Policy'),
            SectionText(
                'Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and disclose your personal information.'),

            SectionTitle('9. Contact Information'),
            SectionText(
                'If you have any questions about these terms of service, please contact us at support@yesgobus.com.'),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF033564), // Dark Blue
        ),
      ),
    );
  }
}

class SectionText extends StatelessWidget {
  final String text;
  const SectionText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.5,
        color: Colors.black87,
      ),
    );
  }
}
