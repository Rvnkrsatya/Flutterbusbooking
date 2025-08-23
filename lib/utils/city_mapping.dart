// lib/Service/appservice/city_mapping.dart
final Map<String, List<String>> cityMapping = {
  "hubli": ["hubli", "hubballi"],
  "hubballi": ["hubli", "hubballi"],
  "bangalore": ["bangalore", "bengaluru"],
  "bengaluru": ["bangalore", "bengaluru"],
  "belgaum": ["belgaum", "belagavi"],
  "belagavi": ["belgaum", "belagavi"],
  "mysore": ["mysore", "mysuru"],
  "mysuru": ["mysore", "mysuru"],
  "bombay": ["mumbai", "bombay"],
  "mumbai": ["mumbai", "bombay"],
  "goa": ["goa", "madgaon", "margao", "panaji", "panjim"],
  "madgaon": ["goa", "madgaon", "margao"],
  "margao": ["goa", "madgaon", "margao"],

  "nidugundi": ["Nidugundi", "Nidagundi", "Nidgundi"],

  "panaji": ["goa", "panaji", "panjim"],
  "panjim": ["goa", "panaji", "panjim"],
  "pune": ["pune", "poona"],
  "poona": ["pune", "poona"],
  "trivandrum": ["trivandrum", "thiruvananthapuram"],
  "thiruvananthapuram": ["trivandrum", "thiruvananthapuram"],
  "cochin": ["cochin", "kochi", "ernakulam"],
  "kochi": ["cochin", "kochi", "ernakulam"],
  "ernakulam": ["cochin", "kochi", "ernakulam"],
  "calicut": ["calicut", "kozhikode"],
  "kozhikode": ["calicut", "kozhikode"],
  "tirupati": ["tirupati", "tirupathi"],
  "tirupathi": ["tirupati", "tirupathi"],
  "madras": ["chennai", "madras"],
  "chennai": ["chennai", "madras"],
  "ahmedabad": ["ahmedabad", "amdavad"],
  "amdavad": ["ahmedabad", "amdavad"],
  "baroda": ["baroda", "vadodara"],
  "vadodara": ["baroda", "vadodara"],
  "trichy": ["trichy", "tiruchirappalli"],
  "tiruchirappalli": ["trichy", "tiruchirappalli"],
  "pondicherry": ["pondicherry", "puducherry"],
  "puducherry": ["pondicherry", "puducherry"],
};

String normalizeCity(String city) {
  final key = city.trim().toLowerCase();
  if (cityMapping.containsKey(key)) {
    return cityMapping[key]!.first;
  }
  return city;
}

// Returns the alternate city name for API use
String getMappedCity(String userInput) {
  if (userInput.trim().isEmpty) return userInput;

  final key = userInput.toLowerCase().trim();
  final mappedList = cityMapping[key] ?? [userInput];

  // Flip: if user typed first element, return second; else return first
  if (mappedList.length > 1) {
    return mappedList[0].toLowerCase() == key ? mappedList[1] : mappedList[0];
  } else {
    return mappedList[0];
  }
}
