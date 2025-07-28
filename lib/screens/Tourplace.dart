import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Tourplace extends StatefulWidget {
  const Tourplace({super.key});

  @override
  State<Tourplace> createState() => _TourplaceState();
}

class _TourplaceState extends State<Tourplace> {
  late ScrollController _scrollController;
  late double _scrollPos;
  late Timer _timer;

  final List<Map<String, dynamic>> tours = [
    {'image': 'assets/images/tour/Coorg.png', 'name': 'Coorg'},
    {'image': 'assets/images/tour/Goa.png', 'name': 'Goa'},
    {'image': 'assets/images/tour/Himachal.png', 'name': 'Himachal'},
    {'image': 'assets/images/tour/kashmir.png', 'name': 'Kashmir'},
    {'image': 'assets/images/tour/Thailand.png', 'name': 'Thailand'},
    {'image': 'assets/images/tour/karnataka.png', 'name': 'Karnataka'},
    {'image': 'assets/images/tour/Uttarakhand.png', 'name': 'Uttarakhand'},
    {'image': 'assets/images/tour/Kerala.png', 'name': 'Kerala'},
    // {'image': 'assets/images/tour/Ooty.png', 'name': 'Ooty'},
    // {'image': 'assets/images/tour/Andaman.png', 'name': 'Andaman'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollPos = 0;
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      _scrollPos += 1;
      if (_scrollController.hasClients) {
        if (_scrollPos >= _scrollController.position.maxScrollExtent) {
          _scrollPos = 0;
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(_scrollPos);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Widget _buildCard(String imagePath, String name, double imageHeight) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: ClipPath(
        clipper: ZigZagClipper(),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFCECFD3), // Light grey/white background
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(0)),
                child: Image.asset(
                  imagePath,
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.13;

    final duplicatedList = [...tours, ...tours]; // Loop effect

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            'Popular Tour Places',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: imageHeight + 50,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: duplicatedList.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final item = duplicatedList[index % tours.length];
              return _buildCard(item['image'], item['name'], imageHeight);
            },
          ),
        ),
      ],
    );
  }
}

class ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const zigZagHeight = 10.0;
    const zigZagCount = 20;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - zigZagHeight);

    for (int i = 0; i < zigZagCount; i++) {
      final x = i * size.width / zigZagCount;
      final nextX = (i + 1) * size.width / zigZagCount;
      final y = i % 2 == 0
          ? size.height - zigZagHeight
          : size.height; // alternate up/down
      path.lineTo(x, y);
      path.lineTo(nextX, i % 2 == 0 ? size.height : size.height - zigZagHeight);
    }

    path.lineTo(size.width, size.height - zigZagHeight);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
