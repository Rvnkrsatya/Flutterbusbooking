import 'package:flutter/material.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      foregroundColor: Colors.black,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF86A9C0),
              Color(0xFFB3CDE0),
            ],
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🔵 Left: Logos
            Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/buslogo.png',
                      height: 55,
                      fit: BoxFit.contain,
                    ),
                    Transform.translate(
                      offset: const Offset(0, -6),
                      child: const Text(
                        'Bus',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/tour_travel.png',
                      height: 43,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Tour & Travel',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ☰ Right: Menu Icon (Opens left drawer)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                iconSize: 38,
                color: Colors.black,
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // ⬅️ Opens left-side drawer
                },
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          height: 1.0,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}
