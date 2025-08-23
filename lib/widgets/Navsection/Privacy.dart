import 'package:flutter/material.dart';

class Privacy extends StatelessWidget {
  const Privacy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF033564),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome header
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
                        'This Privacy Policy explains how we collect, use, and protect the personal information you provide while using our website or mobile application.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      ..._buildSection('1. Information We Collect', [
                        'We collect personal information when you use our platform to book bus tickets. This information may include:',
                        '- Contact information (name, email, phone)',
                        '- Payment information',
                        '- Travel preferences',
                        '- Booking history',
                        '- Device information',
                      ]),
                      ..._buildSection('2. How We Use Your Information', [
                        '- To facilitate bookings',
                        '- To process payments',
                        '- To communicate updates',
                        '- To offer customer support',
                        '- To improve services',
                      ]),
                      ..._buildSection('3. Privacy Policy for YesGo Cab Driver', [
                        'We collect information such as:',
                        '- Driver and vehicle details',
                        '- Location and trip history',
                        '- Ratings and earnings',
                        '',
                        'We use it to:',
                        '- Improve services',
                        '- Process payments',
                        '- Ensure safety',
                        '- Fulfill legal requirements',
                      ]),
                      ..._buildSection('4. Data Security', [
                        'We take data protection seriously with industry-standard security practices.',
                      ]),
                      ..._buildSection('5. Third-Party Services', [
                        'We use third parties (e.g., for payments) who access only what is necessary and are contractually restricted.',
                      ]),
                      ..._buildSection('6. Cookies and Tracking', [
                        'We use cookies to enhance your experience. You can manage them in your browser settings.',
                      ]),
                      ..._buildSection('7. Children\'s Privacy', [
                        'We do not knowingly collect data from individuals under 18.',
                      ]),
                      ..._buildSection('8. Changes to Privacy Policy', [
                        'We may update this policy and notify users through the app.',
                      ]),
                      ..._buildSection('9. Contact Information', [
                        'Email: support@yesgobus.com',
                        'Phone: +91-9964376733',
                        'Thank you for trusting YesGoBus!',
                      ]),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildSection(String title, List<String> lines) {
    return [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF033564),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        lines.join('\n'),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 16),
    ];
  }
}
