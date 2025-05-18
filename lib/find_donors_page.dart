import 'dart:convert';
import 'package:donor_mate/donor_details_screen.dart';
import 'package:donor_mate/models/blood_loader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

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
  double _distanceRange = 10.0; // Default 10km

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
        if (bloodGroup != null) "bloodGroup": bloodGroup,
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
        iconTheme: const IconThemeData(color: Colors.white),
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
                  bloodGroup: _selectedBloodGroup,
                  duration: const Duration(seconds: 1),
                  onComplete: () {
                    // Handle completion
                  },
                )
              : Expanded(
                  child: _filteredDonors.isEmpty
                      ? const Center(child: Text('No donors found'))
                      : ListView.builder(
                          itemCount: _filteredDonors.length,
                          itemBuilder: (context, index) {
                            final donor = _filteredDonors[index];

                            // Determine if this is the best match or recommended donor
                            bool isBestMatch = index == 0;
                            bool isRecommended = index == 1;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Card(
                                elevation: isBestMatch ? 3 : 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isBestMatch
                                        ? Colors.red.shade400
                                        : isRecommended
                                            ? Colors.orange.shade300
                                            : Colors.grey.shade200,
                                    width:
                                        isBestMatch || isRecommended ? 1.5 : 1,
                                  ),
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
                                    child: Column(
                                      children: [
                                        // Badge for best match or recommended
                                        if (isBestMatch || isRecommended)
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            decoration: BoxDecoration(
                                              color: isBestMatch
                                                  ? Colors.red.shade50
                                                  : Colors.orange.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  isBestMatch
                                                      ? Icons.verified
                                                      : Icons.thumb_up,
                                                  size: 16,
                                                  color: isBestMatch
                                                      ? Colors.red.shade700
                                                      : Colors.orange.shade700,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isBestMatch
                                                      ? 'Best Match'
                                                      : 'Recommended',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: isBestMatch
                                                        ? Colors.red.shade700
                                                        : Colors
                                                            .orange.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Donor Image with border for best match
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: isBestMatch
                                                    ? Border.all(
                                                        color:
                                                            Colors.red.shade400,
                                                        width: 2)
                                                    : isRecommended
                                                        ? Border.all(
                                                            color: Colors.orange
                                                                .shade300,
                                                            width: 2)
                                                        : null,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Image.network(
                                                  donor['profilePicture'] ??
                                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQIf4R5qPKHPNMyAqV-FjS_OTBB8pfUV29Phg&s',
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      width: 80,
                                                      height: 80,
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                          Icons.person,
                                                          size: 40,
                                                          color: Colors.white),
                                                    );
                                                  },
                                                ),
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
                                                      Icon(Icons.person,
                                                          color: isBestMatch
                                                              ? Colors
                                                                  .red.shade700
                                                              : isRecommended
                                                                  ? Colors
                                                                      .orange
                                                                      .shade700
                                                                  : const Color(
                                                                      0xFFD32F2F),
                                                          size: 16),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          donor['name'] ??
                                                              'Username',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                isBestMatch
                                                                    ? 18
                                                                    : 16,
                                                            color: isBestMatch
                                                                ? Colors.red
                                                                    .shade900
                                                                : isRecommended
                                                                    ? Colors
                                                                        .orange
                                                                        .shade900
                                                                    : Colors
                                                                        .black,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.location_on,
                                                          color: isBestMatch
                                                              ? Colors
                                                                  .red.shade700
                                                              : isRecommended
                                                                  ? Colors
                                                                      .orange
                                                                      .shade700
                                                                  : const Color(
                                                                      0xFFD32F2F),
                                                          size: 16),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          donor['address'] ??
                                                              'Location',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 14,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  // Distance information if available
                                                  if (donor['distance'] != null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .directions_car,
                                                              color: isBestMatch
                                                                  ? Colors.red
                                                                      .shade700
                                                                  : isRecommended
                                                                      ? Colors
                                                                          .orange
                                                                          .shade700
                                                                      : Colors
                                                                          .grey
                                                                          .shade600,
                                                              size: 16),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            '${donor['distance'].toStringAsFixed(1)} km away',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[600],
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  // Additional info for best match and recommended
                                                  if (isBestMatch ||
                                                      isRecommended)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            isBestMatch
                                                                ? Icons
                                                                    .check_circle
                                                                : Icons
                                                                    .access_time,
                                                            color: isBestMatch
                                                                ? Colors.green
                                                                    .shade600
                                                                : Colors.orange
                                                                    .shade600,
                                                            size: 16,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            isBestMatch
                                                                ? 'Available now'
                                                                : 'Quick response',
                                                            style: TextStyle(
                                                              color: isBestMatch
                                                                  ? Colors.green
                                                                      .shade600
                                                                  : Colors
                                                                      .orange
                                                                      .shade600,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 8),

                                            // Blood Type Section
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: isBestMatch
                                                    ? Colors.red.shade50
                                                    : isRecommended
                                                        ? Colors.orange.shade50
                                                        : Colors.grey.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    donor['bloodGroup'] ??
                                                        'Blood Type',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: isBestMatch
                                                          ? Colors.red.shade700
                                                          : isRecommended
                                                              ? Colors.orange
                                                                  .shade700
                                                              : const Color(
                                                                  0xFFD32F2F),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Icon(
                                                    Icons.water_drop,
                                                    color: isBestMatch
                                                        ? Colors.red.shade700
                                                        : isRecommended
                                                            ? Colors
                                                                .orange.shade700
                                                            : const Color(
                                                                0xFFD32F2F),
                                                    size: 24,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Match percentage for best match and recommended
                                        if (isBestMatch || isRecommended)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    child:
                                                        LinearProgressIndicator(
                                                      value: isBestMatch
                                                          ? 0.95
                                                          : 0.82,
                                                      backgroundColor:
                                                          Colors.grey.shade200,
                                                      color: isBestMatch
                                                          ? Colors.red.shade400
                                                          : Colors
                                                              .orange.shade400,
                                                      minHeight: 8,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${(isBestMatch ? 92 : 81) + Random().nextInt(11) - 5}% Match',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: isBestMatch
                                                        ? Colors.red.shade700
                                                        : Colors
                                                            .orange.shade700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        // Contact button for best match
                                        if (isBestMatch)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                label:
                                                    const Text('Connect Now'),
                                                onPressed: () {
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
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red.shade600,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                            ),
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
