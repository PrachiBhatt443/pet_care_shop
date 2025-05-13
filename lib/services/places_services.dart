import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  final String _apiKey = 'AIzaSyDNQp8p0gdVEUriv3R8RyLHSIJpmy7IyRw'; // Replace with your key

  // Function to get phone number for a place using the Place Details API
  Future<String> getPhoneNumber(String placeId) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
            '?placeid=$placeId'
            '&fields=formatted_phone_number'
            '&key=$_apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data['result'];

      if (result != null && result['formatted_phone_number'] != null) {
        return result['formatted_phone_number'];
      } else {
        return '';
      }
    } else {
      throw Exception('Failed to fetch phone number: ${response.statusCode}');
    }
  }

  // Function to get nearby vet clinics
  Future<Map<String, List<Map<String, dynamic>>>> getNearbyVetClinics(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
            '?location=$lat,$lng'
            '&radius=50000'
            '&keyword=veterinary+clinic'
            '&type=veterinary_care'
            '&key=$_apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;

      // Lists to hold clinics with and without images
      List<Map<String, dynamic>> clinicsWithImages = [];
      List<Map<String, dynamic>> clinicsWithoutImages = [];

      for (var place in results) {
        final location = place['geometry']['location'];
        final placeId = place['place_id'];

        // Fetch phone number
        String phoneNumber = await getPhoneNumber(placeId);

        // Determine if photo is available
        bool hasImage = place['photos'] != null && place['photos'].isNotEmpty;

        String imageUrl = hasImage
            ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place['photos'][0]['photo_reference']}&key=$_apiKey'
            : 'https://via.placeholder.com/400';

        Map<String, dynamic> clinicData = {
          'name': place['name'],
          'latitude': location['lat'],
          'longitude': location['lng'],
          'address': place['vicinity'] ?? 'No address',
          'phone': phoneNumber,
          'image': imageUrl,
        };

        if (hasImage) {
          clinicsWithImages.add(clinicData);
        } else {
          clinicsWithoutImages.add(clinicData);
        }
      }

      // Return both lists in a map
      return {
        'withImages': clinicsWithImages,
        'withoutImages': clinicsWithoutImages,
      };
    } else {
      throw Exception('Failed to fetch vet clinics: ${response.statusCode}');
    }
  }
}
