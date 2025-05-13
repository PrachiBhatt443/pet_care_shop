// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class OSMPlacesService {
//   Future<List<Map<String, dynamic>>> getNearbyVetClinics(double lat, double lng) async {
//     final query = '''
//       [out:json];
//       (
//         node["amenity"="veterinary"](around:500000,$lat,$lng);
//         way["amenity"="veterinary"](around:500000,$lat,$lng);
//         relation["amenity"="veterinary"](around:500000,$lat,$lng);
//       );
//       out center;
//     ''';
//
//     final url = Uri.parse('https://overpass-api.de/api/interpreter');
//
//     final response = await http.post(
//       url,
//       body: {'data': query},
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       List results = data['elements'];
//
//       print("Found ${results.length} vet clinics.");
//
//       return results.map<Map<String, dynamic>>((place) {
//         final tags = place['tags'] ?? {};
//         return {
//           'name': tags['name'] ?? 'Unknown',
//           'latitude': place['lat'] ?? place['center']?['lat'],
//           'longitude': place['lon'] ?? place['center']?['lon'],
//           'phone': tags['phone'] ?? 'N/A',
//           'address': tags['addr:street'] ?? 'N/A',
//         };
//       }).toList();
//     } else {
//       throw Exception('Failed to load vet clinics: ${response.statusCode}');
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;

class FoursquareService {
  final String _apiKey = 'fsq3MMvmN6hXnLVKwBBLsxqsue2FSnn1YCj2Z7nfBTHjFeQ='; // Replace with your actual API key

  Future<List<Map<String, dynamic>>> getNearbyVetClinics(double lat, double lng) async {
    final url = Uri.parse('https://api.foursquare.com/v3/places/search?query=veterinary&ll=$lat,$lng&radius=5000&limit=10');

    final response = await http.get(
      url,
      headers: {
        'Authorization': _apiKey,
        'accept': 'application/json',
      },
    );

    print('response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      print('Found ${results.length} vet clinics.');
      return results.map<Map<String, dynamic>>((place) {
        return {

          'name': place['name'],
          'latitude': place['geocodes']['main']['latitude'],
          'longitude': place['geocodes']['main']['longitude'],
          'address': place['location']['formatted_address'] ?? 'N/A',
          'categories': place['categories']?.map((c) => c['name'])?.join(', ') ?? 'N/A',
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch vet clinics: ${response.statusCode}');
    }
  }
}

