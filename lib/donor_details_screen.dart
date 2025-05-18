import 'package:donor_mate/blood_req.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorDetailsPage extends StatelessWidget {
  final Map<String, dynamic> donor;
  final String lat;
  final String long;

  const DonorDetailsPage({
    Key? key,
    required this.donor,
    required this.lat,
    required this.long,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> openMapDirections(String destinationAddress) async {
      final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin={$lat,$long}&destination=$destinationAddress&travelmode=driving',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch Google Maps';
      }
    }

    String userName = donor['name'] ?? 'User Name';
    String userEmail = donor['email'] ?? 'user@example.com';
    String userPhone = donor['phone'].toString();
    String userGender = donor['gender'] ?? 'Male';
    String userBloodGroup = donor['bloodGroup'] ?? 'A+';
    String profilePicture = donor['profilePicture'] ??
        'https://png.pngtree.com/png-clipart/20231019/original/pngtree-user-profile-avatar-png-image_13369991.png';
    String location = donor['address'] ?? 'Location not set';
    String latitude = donor['latitude']?.toString() ?? "12.8716";
    String longitude = donor['longitude']?.toString() ?? "77.5950";
    bool isAvailableForDonation = true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        title: Text('Donor Profile',
            style: GoogleFonts.nunitoSans(
                color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Edit',
              style: GoogleFonts.nunitoSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: NetworkImage(profilePicture),
                              onBackgroundImageError: (_, __) {},
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userName,
                            style: GoogleFonts.nunitoSans(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.email,
                                  color: Colors.grey[600], size: 18),
                              const SizedBox(width: 4),
                              Text(
                                userEmail,
                                style: GoogleFonts.nunitoSans(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on,
                                  color: Colors.grey[600], size: 18),
                              const SizedBox(width: 4),
                              Text(
                                location,
                                style: GoogleFonts.nunitoSans(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.phone),
                                  label: const Text('Call Now'),
                                  onPressed: () async {
                                    await FlutterPhoneDirectCaller.callNumber(
                                        userPhone);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3b5998),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.directions),
                                  label: const Text('Get Directions'),
                                  onPressed: () {
                                    openMapDirections("$latitude,$longitude");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD32F2F),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 10),
                      child: Row(
                        children: [
                          _buildStatCard(userBloodGroup, 'Blood Type'),
                          _buildStatCard('06', 'Donated'),
                          _buildStatCard('03', 'Requested'),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calendar_today,
                          color: Color(0xFFD32F2F)),
                      title: const Text('Available for donate'),
                      trailing: Switch(
                        value: isAvailableForDonation,
                        onChanged: (_) {},
                        activeColor: const Color(0xFFD32F2F),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey[400],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BloodRequestScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Request Blood',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Text(
                value,
                style: GoogleFonts.nunitoSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}