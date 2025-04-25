import 'dart:convert';
import 'package:donor_mate/donor_details_screen.dart';
import 'package:donor_mate/models/blood_loader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FindDonorsPage extends StatefulWidget {
  const FindDonorsPage({Key? key}) : super(key: key);

  @override
  State<FindDonorsPage> createState() => _FindDonorsPageState();
}

class _FindDonorsPageState extends State<FindDonorsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _donors = [];
  List<Map<String, dynamic>> _filteredDonors = [];
  bool _isLoading = true;

  // Filter variables
  String _selectedBloodGroup = 'All';
  String _location = '';
  String _latitude = "12.901836572567824";
  String _longitude = "77.55847677976726";
  double _distanceRange = 10.0; // Default 5km
  final List<String> _bloodGroups = [
    'All',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('userData');
      print(userData);

      if (userData != null) {
        Map<String, dynamic> user = jsonDecode(userData);
        print(user);

        setState(() {
          _selectedBloodGroup = user['bloodGroup'] ?? "A+";
          _location = user['address'] ?? "Electronic City, Bangalore, India";
          _latitude = user['latitude'] ?? "12.901836572567824";
          _longitude = user['longitude'] ?? "77.55847677976726";
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      fetchDonors(
        bloodGroup: _selectedBloodGroup,
        distance: _distanceRange,
        lat: _latitude,
        lng: _longitude,
      );
    }
  }

  Future<void> fetchDonors(
      {String? bloodGroup,
      double? distance = 10.0,
      String? lat,
      String? lng}) async {
    setState(() => _isLoading = true);
    try {
      // Base URL
      String url =
          'https://blood-donation-backend-082i.onrender.com/api/home/default-donors';

      final Map<String, dynamic> body = {
        if (bloodGroup != null && bloodGroup != "All") "bloodGroup": bloodGroup,
        if (distance != null) "distance": distance,
        if (lat != null) "lat": lat,
        if (lng != null) "lng": lng,
      };

      print("Request Body: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(jsonData);
        final donorsData = List<Map<String, dynamic>>.from(jsonData['donors']);
        setState(() {
          _donors = donorsData;
          _filteredDonors = donorsData;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load donors");
      }
    } catch (e) {
      print("Error fetching donors: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterDonors(String query) {
    setState(() {
      _filteredDonors = _donors.where((donor) {
        final name = donor['name'].toLowerCase();
        final city = donor['city']?.toLowerCase() ?? '';
        final bloodGroup = donor['bloodGroup']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase()) ||
            city.contains(query.toLowerCase()) ||
            bloodGroup.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _applyFilters() {
    Navigator.pop(context); // Close the drawer
    fetchDonors(
      bloodGroup: _selectedBloodGroup,
      distance: _distanceRange,
      lat: _latitude,
      lng: _longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        title: const Text(
          'Find Donors',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white), // 👈 makes end drawer icon red

      ),
      endDrawer: _buildFilterDrawer(),
      
      body: Column(
        children: [
          // Search bar with filter icon
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(Icons.search, color: Color(0xFFD32F2F)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: _filterDonors,
                    ),
                  ),
                  // Filter icon button
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.filter_list,
                            color: Color(0xFFD32F2F)),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Donors list
          _isLoading
              ? BloodDonorSearchLoader(
                  bloodGroup: "", // Replace with your selected blood group
                  duration:
                      const Duration(seconds: 1), // 2 seconds as requested
                  onComplete: () {
                    // Handle completion, perhaps navigate to results page
                    // or update UI to show donor results
                  },
                )
              : Expanded(
                  child: _filteredDonors.isEmpty
                      ? const Center(child: Text('No donors found'))
                      : ListView.builder(
                          itemCount: _filteredDonors.length,
                          itemBuilder: (context, index) {
                            final donor = _filteredDonors[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DonorDetailsPage(
                                                  donor: donor,
                                                  lat: _latitude,
                                                  long: _longitude),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Donor Image
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            donor['profilePicture'] ??
                                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQIf4R5qPKHPNMyAqV-FjS_OTBB8pfUV29Phg&s',
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 70,
                                                height: 70,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.person,
                                                    size: 40,
                                                    color: Colors.white),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Donor Info - Flexible to avoid overflow
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.person,
                                                      color: Color(0xFFD32F2F),
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      donor['name'] ??
                                                          'Username',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on,
                                                      color: Color(0xFFD32F2F),
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      donor['address'] ??
                                                          'Location',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        // Blood Type Section
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              donor['bloodGroup'] ??
                                                  'Blood Type',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Icon(
                                              Icons.water_drop,
                                              color: Color(0xFFD32F2F),
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }

  // Filter drawer widget
  Widget _buildFilterDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75, // 75% of screen width
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Donors',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),

              // Blood group filter
              const SizedBox(height: 16),
              const Text(
                'Blood Group',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _bloodGroups.map((group) {
                  return FilterChip(
                    label: Text(group),
                    selected: _selectedBloodGroup == group,
                    selectedColor: Colors.red.shade100,
                    checkmarkColor: Colors.red,
                    onSelected: (selected) {
                      setState(() {
                        _selectedBloodGroup = group;
                      });
                    },
                  );
                }).toList(),
              ),

              // Distance range filter
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Distance Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_distanceRange.toInt()} km',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _distanceRange,
                min: 1,
                max: 50,
                divisions: 49,
                activeColor: const Color(0xFFD32F2F),
                inactiveColor: Colors.red.shade100,
                label: '${_distanceRange.toInt()} km',
                onChanged: (value) {
                  setState(() {
                    _distanceRange = value;
                  });
                },
              ),

              // Apply button
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
