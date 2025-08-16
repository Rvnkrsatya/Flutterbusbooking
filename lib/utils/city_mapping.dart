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

List<String> getMappedCities(String? city) {
  if (city == null || city.trim().isEmpty) return [];
  final key = city.toLowerCase().trim();
  return cityMapping[key] ?? [city];
}
