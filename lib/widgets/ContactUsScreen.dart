import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'QueryFormScreen.dart'; // Make sure this file exists and is correctly imported

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        "image": "assets/images/mail.png",
        "title": "Write to us and our support team will get back to you shortly.",
        "buttonText": "Send Mail",
      },
      {
        "image": "assets/images/call.png",
        "title": "Call Mon–Fri using your registered number.",
        "buttonText": "Call Us",
      },
      {
        "image": "assets/images/location.png",
        "title": "No. 17074, BasavanaBagewadi, Nidagundi,Vijayapura, Karnataka - 586213",
        "buttonText": "Location",
      },
      {
        "image": "assets/images/raise-hand.png",
        "title": "Raise a query and our agent will revert back to you as soon as possible.",
        "buttonText": "Raise Now",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Help Desk", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF033564),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            const Text(
              "How can we help you Today?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF033564),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              "Our experts are happy to help you",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14bde3),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 26),
            Expanded(
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 26,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final item = items[index];
                  return _buildCard(context, item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF14bde3), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Image.asset(
                    item['image'],
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF033564),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF033564), Color(0xFF14bde3)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      if (item['buttonText'] == 'Send Mail') {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'support@yesgobus.com',
                          query: Uri.encodeFull('subject=Support Request&body=Hi, I need help with...'),
                        );
                        await launchUrl(emailLaunchUri);
                      } else if (item['buttonText'] == 'Call Us') {
                        final Uri phoneUri = Uri(scheme: 'tel', path: '9888417555');
                        await launchUrl(phoneUri);
                      } else if (item['buttonText'] == 'Location') {
                        const String address = 'No. 17074, BasavanaBagewadi, Nidagundi,Vijayapura, Karnataka - 586213';
                        final Uri mapUri = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
                        );
                        await launchUrl(mapUri, mode: LaunchMode.externalApplication);
                      } else if (item['buttonText'] == 'Raise Now') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  QueryFormScreen(),
                          ),
                        );
                      }
                    },
                    child: Text(
                      item['buttonText'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
