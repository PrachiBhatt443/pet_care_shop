import 'package:flutter/material.dart';
import '../models/vet_clinic.dart';
import '../screens/clinic_map_screen.dart';

class AllClinicsList extends StatelessWidget {
  final List<VetClinic> clinics;
  final double userLat;
  final double userLng;

  const AllClinicsList({
    Key? key,
    required this.clinics,
    required this.userLat,
    required this.userLng,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: clinics.length,
      itemBuilder: (context, index) {
        final clinic = clinics[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            height: 120, // Fixed height for all cards
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Clinic Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(Icons.local_hospital, color: Colors.orange),
                ),
                const SizedBox(width: 16),

                // Clinic Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Clinic Name
                      Text(
                        clinic.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Clinic Address
                      Text(
                        clinic.address,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Phone Row - Only shown if phone exists and is not empty
                      const Spacer(),
                      Row(
                        children: [
                          // Only show phone icon and number if it exists
                          if (clinic.phone.isNotEmpty) ...[
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              clinic.phone,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Map Button
                IconButton(
                  icon: Icon(Icons.map, color: Colors.orange[700]),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClinicMapScreen(
                          clinic: clinic,
                          userLat: userLat,
                          userLng: userLng,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}