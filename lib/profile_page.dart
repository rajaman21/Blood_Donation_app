import 'package:donor_mate/widgets/profile_info_item.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'find_donors_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = "User Name";
  String _userEmail = "user@example.com";
  String _userAge = "25";
  String _userGender = "Male";
  String _userBloodGroup = "A+";
  String _userPhone = "1234567890";
  String _profilePicture =
      "https://png.pngtree.com/png-clipart/20231019/original/pngtree-user-profile-avatar-png-image_13369991.png";
  String _location = "Location not set";
  bool _isAvailableForDonation = true;
  bool _isLoading = true; // To show a loading indicator
  int _donatedCount = 0;
  int _requestedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<Map<String, dynamic>?> fetchUserProfile(userId) async {
  try {
   String url =
          'https://blood-donation-backend-082i.onrender.com/api/auth/getuser/${userId}';
      final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Failed to load profile: ${response.statusCode}");
    }
  } catch (e) {
    print("Error in API call: $e");
  }
  return null;
}


  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('userData');
      print(userData);


      if (userData != null) {
        
      final userDav = await fetchUserProfile("67e99111eb32dbea224507ab");
      print(userDav);
        Map<String, dynamic> user = jsonDecode(userData);
        print(userData);

        print(user);
        setState(() {
          _userName = user['name'] ?? "User Name";
          _userEmail = user['email'] ?? "user@example.com";
          _userPhone = user['phone'] ?? "1234567890";
          _userAge = user['age']?.toString() ?? "25";
          _userGender = user['gender'] ?? "Male";
          _userBloodGroup = user['bloodGroup'] ?? "A+";
          _profilePicture = user['profilePicture'] ??
              "https://png.pngtree.com/png-clipart/20231019/original/pngtree-user-profile-avatar-png-image_13369991.png";
          _location = user['address'] ?? "Electronic City, Bangalore, India";
          _isAvailableForDonation = user['isAvailableForDonation'] ?? true;
          _donatedCount = user['donatedCount'] ?? 4;
          _requestedCount = user['requestedCount'] ?? 6;
        });
      }
      
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _updateAvailabilityStatus(bool isAvailable) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('userData');
      
      if (userData != null) {
        Map<String, dynamic> user = jsonDecode(userData);
        user['isAvailableForDonation'] = isAvailable;
        
        await prefs.setString('userData', jsonEncode(user));
      }
    } catch (e) {
      print("Error updating availability status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        title: Text(
          'Profile',
          style: GoogleFonts.nunitoSans(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserData,
          ),
          TextButton(
            onPressed: () {
              // Navigate to edit profile
            },
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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
        : RefreshIndicator(
            onRefresh: _loadUserData,
            color: const Color(0xFFD32F2F),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Profile Image
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: NetworkImage(
                              _profilePicture, // Use the variable, not hardcoded URL
                            ),
                            onBackgroundImageError: (exception, stackTrace) {
                              print("Error loading profile image: $exception");
                            },
                            child: _profilePicture.isEmpty 
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name
                        Text(
                          _userName,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Location
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.grey[600], size: 18),
                            const SizedBox(width: 4),
                            Text(
                              _location,
                              style: GoogleFonts.nunitoSans(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // Stats Cards
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                    child: Row(
                      children: [
                        _buildStatCard(_userBloodGroup, 'Blood Type'),
                        _buildStatCard(_donatedCount.toString(), 'Donated'),
                        _buildStatCard(_requestedCount.toString(), 'Requested'),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  _buildAboutTab({
                    'age': _userAge,
                    'gender': _userGender,
                    'city': _location,
                    'country': 'India',
                    'phone': _userPhone,
                    'email': _userEmail,
                  }),

                  // Available for donation toggle
                  ListTile(
                    leading:
                        const Icon(Icons.calendar_today, color: Color(0xFFD32F2F)),
                    title: const Text('Available for donate'),
                    trailing: Switch(
                      value: _isAvailableForDonation,
                      onChanged: (value) {
                        setState(() {
                          _isAvailableForDonation = value;
                        });
                        _updateAvailabilityStatus(value);
                      },
                      activeColor: _isAvailableForDonation
                          ? const Color(0xFFD32F2F)
                          : Colors.grey,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[400],
                    ),
                  ),

                  const Divider(height: 1),

                  // Menu Items
                  _buildMenuItem(
                    icon: Icons.share,
                    title: 'Invite a friend',
                    onTap: () {
                      // Invite a friend
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      // Edit profile
                    },
                  ),
                ],
              ),
            ),
          ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Find Donors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FindDonorsPage()),
            );
          }
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFD32F2F),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab(Map<String, dynamic> profile) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About User',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ProfileInfoItem(
              icon: Icons.cake,
              iconBackgroundColor: Colors.red,
              label: 'Age',
              value: profile['age']?.toString() ?? 'N/A',
            ),
            ProfileInfoItem(
              icon: Icons.person,
              iconBackgroundColor: Colors.red,
              label: 'Gender',
              value: profile['gender'] ?? 'Not specified',
            ),
            ProfileInfoItem(
              icon: Icons.location_city,
              iconBackgroundColor: Colors.red,
              label: 'City',
              value: profile['city'] ?? 'Unknown',
            ),
            ProfileInfoItem(
              icon: Icons.public,
              iconBackgroundColor: Colors.red,
              label: 'Country',
              value: profile['country'] ?? 'Not provided',
            ),
            ProfileInfoItem(
              icon: Icons.phone,
              iconBackgroundColor: Colors.red,
              label: 'Mobile',
              value: profile['phone'] ?? 'Not available',
            ),
            ProfileInfoItem(
              icon: Icons.email,
              iconBackgroundColor: Colors.red,
              label: 'Email',
              value: profile['email'] ?? 'Not available',
            ),
            const SizedBox(height: 24),
          ],
        ));
  }
}