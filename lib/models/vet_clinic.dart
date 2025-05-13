class VetClinic {
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final String image;
  String? distance;

  VetClinic({
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.image,
  });

  factory VetClinic.fromMap(Map<String, dynamic> map) {
    return VetClinic(
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      image: map['image'],
    );
  }
}
