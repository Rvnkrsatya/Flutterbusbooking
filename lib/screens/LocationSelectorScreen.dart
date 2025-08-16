import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // Needed for ImageFilter

import 'package:shared_preferences/shared_preferences.dart';

import '../Service/appservice/api_urls.dart';

class LocationSelectorScreen extends StatefulWidget {
  final String title; // "From" or "To"
  const LocationSelectorScreen({super.key, required this.title});

  @override
  State<LocationSelectorScreen> createState() => _LocationSelectorScreenState();
}

class _LocationSelectorScreenState extends State<LocationSelectorScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  List<String> _recentSearches = [];
  bool _loading = false;
  final Color darkBlue = const Color(0xFF033564);
  final Color lightBlue = const Color(0xFF14bde3);
  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    Future.delayed(const Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(FocusNode()); // to trigger build
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final key = widget.title == "From" ? "recentFrom" : "recentTo";
    setState(() {
      _recentSearches = prefs.getStringList(key) ?? [];
    });
  }

  Future<void> _saveRecentSearch(String location) async {
    final prefs = await SharedPreferences.getInstance();
    final key = widget.title == "From" ? "recentFrom" : "recentTo";
    List<String> list = prefs.getStringList(key) ?? [];
    list.remove(location); // Avoid duplicates
    list.insert(0, location);
    if (list.length > 5) list = list.sublist(0, 5);
    await prefs.setStringList(key, list);
  }

  void _onTextChanged(String value) {
    if (value.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    Future.delayed(const Duration(milliseconds: 400), () {
      _fetchSuggestions(value);
    });
  }

  // Future<void> _fetchSuggestions(String query) async {
  //   setState(() => _loading = true);
  //   try {
  //     final response = await http.get(Uri.parse(ApiUrls.searchCity(query)));
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body)['data'];
  //       setState(() {
  //         _suggestions = data
  //             .map((item) => item['name'].toString().replaceAll(RegExp(r'Package.*'), '').trim())
  //             .toList();
  //       });
  //     }
  //   } catch (e) {
  //     print("Error fetching cities: $e");
  //   }
  //   setState(() => _loading = false);
  // }
  Future<void> _fetchSuggestions(String query) async {
    setState(() => _loading = true);
    final Map<String, String> _preferredCities = {
      'b': 'Bangalore',
      'h': 'Hubli',
      'd': 'Delhi',
      'm': 'Mumbai',
      'c': 'Chennai',
      'k': 'Kolkata',
    };

    try {
      final response = await http.get(Uri.parse(ApiUrls.searchCity(query)));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        List<String> results = data
            .map((item) => item['name'].toString().replaceAll(RegExp(r'Package.*'), '').trim())
            .toList();

        String firstLetter = query.toLowerCase()[0];
        String? preferred = _preferredCities[firstLetter];

        if (preferred != null &&
            results.any((r) => r.toLowerCase() != preferred.toLowerCase()) &&
            preferred.toLowerCase().startsWith(firstLetter)) {
          results.removeWhere((item) => item.toLowerCase() == preferred.toLowerCase());
          results.insert(0, preferred); // Put preferred city on top
        }

        setState(() {
          _suggestions = results;
        });
      }
    } catch (e) {
      print("Error fetching cities: $e");
    }

    setState(() => _loading = false);
  }

  void _selectLocation(String location) async {
    final key = widget.title == "From" ? "sourceCity" : "destinationCity";
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, location);
    await _saveRecentSearch(location);

    if (!mounted) return;
    Navigator.pop(context, location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Set scaffold background to white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF033564),
              Color(0xFF14bde3),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            'Select ${widget.title} Location',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade300, // You can change the color here
          ),
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.title == "From" ? "Search Boarding Point" : "Search Dropping Point",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF033564)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),

              onChanged: _onTextChanged,
            ),
            if (_loading) const LinearProgressIndicator(),
            if (_suggestions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (_, index) {
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(_suggestions[index]),
                      onTap: () => _selectLocation(_suggestions[index]),
                    );
                  },
                ),
              )
            else if (_recentSearches.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Recent Searches", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _recentSearches.length,
                        itemBuilder: (_, index) {
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(_recentSearches[index]),
                            onTap: () => _selectLocation(_recentSearches[index]),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
