import 'package:flutter/material.dart';
import '../models/vet_clinic.dart';

class NearbyClinicsList extends StatelessWidget {
  final List<VetClinic> clinics;

  const NearbyClinicsList({Key? key, required this.clinics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: clinics.length,
        itemBuilder: (context, index) {
          final clinic = clinics[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                  child: clinic.image.isNotEmpty // Ensure the image URL is not empty
                      ? Image.network(
                    clinic.image,
                    height: 90,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 90,
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.pets, color: Colors.grey[400]),
                      ),
                    ),
                  )
                      : Container(
                    height: 90,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.pets, color: Colors.grey[400]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (clinic.distance != null)
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              clinic.distance!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
